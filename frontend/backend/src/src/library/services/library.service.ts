import { In, Repository } from 'typeorm';
import { join } from 'path';
import { InjectRepository } from '@nestjs/typeorm';
import { Injectable, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FilesService } from '../../files/services/files.service';
import { CreateLibraryDto } from '../dto/create-library.dto';
import { UpdateLibraryDto } from '../dto/update-library.dto';
import { LibraryEntity } from '../entities/library.entity';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { ShellService } from '../../shell/services/shell.service';
import { EntityState } from '../../core/enums/entity-state';
import { FileReferenceEntity } from '../../files/entities/file-reference.entity';
import { mapBooleanToFlag } from '../../shell/util';

const ONE_MEGABYTE = 1_000_000;

@Injectable()
export class LibraryService {
  private readonly logger = new Logger(LibraryService.name);

  constructor(
    @InjectRepository(LibraryEntity)
    private readonly libraryRepository: Repository<LibraryEntity>,
    private readonly configService: ConfigService,
    private readonly filesService: FilesService,
    private readonly shellService: ShellService,
  ) {}

  async uploadLibraryFile(file: Express.Multer.File, userId: number) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['zip', 'sdf'],
      mimeTypes: [
        'application/zip',
        'application/x-zip',
        'application/octet-stream',
        'application/x-zip-compressed',
        'application/vnd.stardivision.math',
        'chemical/x-mdl-sdfile',
        'application/octet-stream',
      ],
      maxSize:
        Math.max(
          this.configService.get<number>('MAX_LIB_LIG_SDF'),
          this.configService.get<number>('MAX_LIB_LIG_ZIP'),
        ) * ONE_MEGABYTE,
    });
  }

  async createLibrary(
    createLibraryDto: CreateLibraryDto,
    userId: number,
  ): Promise<LibraryEntity> {
    const library = new LibraryEntity({
      name: createLibraryDto.name,
      description: createLibraryDto.description,
      authors: createLibraryDto.authors,
      source: createLibraryDto.source,
      typeOfUse: createLibraryDto.typeOfUse,
      fileId: createLibraryDto.fileId,
      createdBy: userId,
    });

    let libraryFileReference = null;
    if (createLibraryDto.fileId) {
      libraryFileReference = await this.filesService.getFileReferenceOrThrow(
        createLibraryDto.fileId,
      );
      this.filesService.ensureFileReferenceIsOwnedBy(
        libraryFileReference,
        userId,
      );
    }

    await this.libraryRepository.save(library);

    const libraryDirectory = `libraries/${library.id}`;
    const libraryPath = join(
      FilesService.getStorageDirectory(),
      libraryDirectory,
    );
    FilesService.ensureDirectoryExists(libraryPath);

    if (libraryFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        libraryFileReference,
        libraryDirectory,
      );
    }

    const ok = await this.runCreateLibraryScript(
      library,
      libraryPath,
      createLibraryDto,
      libraryFileReference,
    );
    library.state = ok ? EntityState.Ready : EntityState.Locked;
    await this.libraryRepository.save(library);

    return library;
  }

  private async runCreateLibraryScript(
    library: LibraryEntity,
    libraryPath: string,
    createLibraryDto: CreateLibraryDto,
    libraryFileReference: FileReferenceEntity | null,
  ): Promise<boolean> {
    const scriptPath = this.configService.get<string>(
      'CREATE_LIBRARY_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('create library script path is not set');
    }

    const command = [
      scriptPath,
      libraryPath,
      library.id,
      `"${library.name}"`,
      `"${library.description}"`,
      `"${library.authors}"`,
      `"${library.source}"`,
      library.typeOfUse,
      mapBooleanToFlag(!!libraryFileReference),
      this.filesService.getFileReferenceScriptParams(libraryFileReference),
      libraryFileReference ? 'NULL' : createLibraryDto.fileUrl,
    ].join(' ');
    this.logger.debug('create library command:', command);

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('create library stderr:', stderr);
        return false;
      } else {
        this.logger.log('create library stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('create library error:', e);
      return false;
    }

    return true;
  }

  async findById(id: LibraryEntity['id']): Promise<LibraryEntity | null> {
    return await this.libraryRepository.findOneBy({ id });
  }

  async findByIds(ids: LibraryEntity['id'][]): Promise<LibraryEntity[]> {
    return await this.libraryRepository.findBy({ id: In(ids) });
  }

  async findForUser(userId: number): Promise<LibraryEntity[]> {
    return await this.libraryRepository.find({
      where: [
        {
          typeOfUse: In([TypeOfUse.Private, TypeOfUse.Public]),
        },
        {
          createdBy: userId,
        },
      ],
      order: {
        id: -1,
      },
      take: 500,
    });
  }

  async findReadyForSearch(userId: number): Promise<LibraryEntity[]> {
    return await this.libraryRepository.find({
      where: [
        {
          state: In([EntityState.Ready, EntityState.InUse]),
          typeOfUse: TypeOfUse.Public,
        },
        {
          state: In([EntityState.Ready, EntityState.InUse]),
          createdBy: userId,
        },
      ],
      order: {
        id: -1,
      },
      take: 500,
    });
  }

  async updateLibraryState(id: number, state: EntityState): Promise<void> {
    const library = await this.libraryRepository.findOneBy({ id });
    if (!library) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: `Library with id ${id} not found`,
        },
        HttpStatus.NOT_FOUND,
      );
    }
    library.state = state;
    await this.libraryRepository.save(library);
  }

  async updateLibrary(id: number, updateDto: UpdateLibraryDto) {
    const library = await this.libraryRepository.findOneBy({ id });
    if (!library) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: `Library with id ${id} not found`,
        },
        HttpStatus.NOT_FOUND,
      );
    }

    if (library.state !== EntityState.Ready) {
      throw new HttpException(
        {
          statusCode: HttpStatus.FORBIDDEN,
          message: `Library with id ${id} not allowed to update`,
        },
        HttpStatus.FORBIDDEN,
      );
    }

    const ok = await this.runUpdateLibaryScript(
      library,
      updateDto,
    );

    if (ok) {
      library.name = updateDto.name;
      library.typeOfUse = updateDto.typeOfUse;
      library.description = updateDto.description;
      library.authors = updateDto.authors;
      library.source = updateDto.source;

      await this.libraryRepository.save(library);
    } else {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: `Libary with id ${id} not update`,
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  async runUpdateLibaryScript(library: LibraryEntity, updateDto: UpdateLibraryDto) {
    const scriptPath = this.configService.get<string>(
      'UPDATE_LIBRARY_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('update library script path is not set');
    }
    const command = [
      scriptPath,
      library.id,
      `"${updateDto.name}"`,
      updateDto.typeOfUse,
      `"${updateDto.description}"`,
      `"${updateDto.authors}"`,
      `"${updateDto.source}"`,
    ].join(' ');
    this.logger.debug('update library command:', command);

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('update library stderr:', stderr);
        return false;
      } else {
        this.logger.log('update library stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('update library error:', e);
      return false;
    }

    return true;
  }

  async deleteLibrary(id: number) {
    const library = await this.libraryRepository.findOneBy({ id });
    if (!library) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: `Library with id ${id} not found`,
        },
        HttpStatus.NOT_FOUND,
      );
    }

    const ok = await this.runDeleteLibaryScript(id);

    if (ok) {
      library.state = EntityState.Archived;
      await this.libraryRepository.save(library);
    } else {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: `Libary with id ${id} not delete`,
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  async runDeleteLibaryScript(id: number) {
    const scriptPath = this.configService.get<string>(
      'DELETE_LIBRARY_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('delete library script path is not set');
    }
    const command = [
      scriptPath,
      id,
    ].join(' ');
    this.logger.debug('delete library command:', command);

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('delete library stderr:', stderr);
        return false;
      } else {
        this.logger.log('delete library stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('delete library error:', e);
      return false;
    }

    return true;
  }
}
