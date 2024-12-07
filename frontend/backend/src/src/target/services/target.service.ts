import { In, Repository } from 'typeorm';
import { join } from 'path';
import { InjectRepository } from '@nestjs/typeorm';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FilesService } from '../../files/services/files.service';
import { CreateTargetDto } from '../dto/create-target.dto';
import { TargetEntity } from '../entities/target.entity';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { ShellService } from '../../shell/services/shell.service';
import { FileReferenceEntity } from '../../files/entities/file-reference.entity';
import { EntityState } from '../../core/enums/entity-state';
import { mapBooleanToFlag } from '../../shell/util';

const ONE_MEGABYTE = 1_000_000;

@Injectable()
export class TargetService {
  private readonly logger = new Logger(TargetService.name);

  constructor(
    @InjectRepository(TargetEntity)
    private readonly targetRepository: Repository<TargetEntity>,
    private readonly configService: ConfigService,
    private readonly filesService: FilesService,
    private readonly shellService: ShellService,
  ) {}

  async uploadPdbFile(file: Express.Multer.File, userId: number) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['pdb'],
      mimeTypes: ['application/x-aportisdoc', 'application/octet-stream'],
      maxSize: this.configService.get<number>('MAX_PDB') * ONE_MEGABYTE,
    });
  }

  async uploadReferenceLigandFile(file: Express.Multer.File, userId: number) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['zip', 'sdf', 'sd'],
      mimeTypes: [
        'application/zip',
        'application/x-zip',
        'application/octet-stream',
        'application/x-zip-compressed',
        'application/vnd.kina', // .sdf
        'application/vnd.stardivision.math',
        'chemical/x-mdl-sdfile',
        'application/octet-stream',
      ],
      maxSize:
        Math.max(
          this.configService.get<number>('MAX_REF_LIG_ZIP'),
          this.configService.get<number>('MAX_REF_LIG_SDF'),
          this.configService.get<number>('MAX_REF_LIG_SD'),
        ) * ONE_MEGABYTE,
    });
  }

  async createTarget(
    createTargetDto: CreateTargetDto,
    userId: number,
  ): Promise<TargetEntity> {
    const target = new TargetEntity({
      name: createTargetDto.name,
      description: createTargetDto.description,
      authors: createTargetDto.authors,
      source: createTargetDto.source,
      typeOfUse: createTargetDto.typeOfUse,
      pdbFileId: createTargetDto.pdbFileId,
      referenceLigandsFileId: createTargetDto.referenceLigandsFileId,
      createdBy: userId,
    });

    let pdbFileReference = null;
    if (createTargetDto.pdbFileId) {
      pdbFileReference = await this.filesService.getFileReferenceOrThrow(
        createTargetDto.pdbFileId,
      );
      this.filesService.ensureFileReferenceIsOwnedBy(pdbFileReference, userId);
    }

    let referenceLigandsFileReference = null;
    if (createTargetDto.referenceLigandsFileId) {
      referenceLigandsFileReference =
        await this.filesService.getFileReferenceOrThrow(
          createTargetDto.referenceLigandsFileId,
        );
      this.filesService.ensureFileReferenceIsOwnedBy(
        referenceLigandsFileReference,
        userId,
      );
    }

    await this.targetRepository.save(target);

    const targetDirectory = `targets/${target.id}`;
    const targetPath = join(
      FilesService.getStorageDirectory(),
      targetDirectory,
    );
    FilesService.ensureDirectoryExists(targetPath);

    if (pdbFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        pdbFileReference,
        targetDirectory,
      );
    }

    if (referenceLigandsFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        referenceLigandsFileReference,
        `${targetDirectory}/reference_ligands`,
      );
    }

    const ok = await this.runCreateTargetScript(
      target,
      targetPath,
      createTargetDto,
      pdbFileReference,
      referenceLigandsFileReference,
    );
    target.state = ok ? EntityState.Ready : EntityState.Locked;
    await this.targetRepository.save(target);

    return target;
  }

  private async runCreateTargetScript(
    target: TargetEntity,
    targetPath: string,
    createTargetDto: CreateTargetDto,
    pdbFileRef: FileReferenceEntity,
    referenceLigandsFileRef?: FileReferenceEntity,
  ): Promise<boolean> {
    const scriptPath = this.configService.get<string>(
      'CREATE_TARGET_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('create target script path is not set');
    }

    const command = [
      scriptPath,
      targetPath,
      target.id,
      `"${target.name}"`,
      `"${target.description}"`,
      `"${target.authors}"`,
      `"${target.source}"`,
      target.typeOfUse,
      mapBooleanToFlag(!!pdbFileRef),
      this.filesService.getFileReferenceScriptParams(pdbFileRef),
      pdbFileRef ? 'NULL' : createTargetDto.pdbId,
      mapBooleanToFlag(createTargetDto.extractReferenceLigands),
      mapBooleanToFlag(!!referenceLigandsFileRef),
      this.filesService.getFileReferenceScriptParams(referenceLigandsFileRef),
    ].join(' ');
    this.logger.debug('create target command:', command);

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('create target stderr:', stderr);
        return false;
      } else {
        this.logger.log('create target stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('create target error:', e);
      return false;
    }

    return true;
  }

  async findById(id: TargetEntity['id']): Promise<TargetEntity | null> {
    return await this.targetRepository.findOneBy({ id });
  }

  async findByIds(ids: TargetEntity['id'][]): Promise<TargetEntity[]> {
    return await this.targetRepository.findBy({ id: In(ids) });
  }

  async findForUser(userId: number): Promise<TargetEntity[]> {
    return await this.targetRepository.find({
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

  async findReadyForSearch(userId: number) {
    return await this.targetRepository.find({
      where: [
        {
          state: EntityState.Ready,
          typeOfUse: TypeOfUse.Public,
        },
        {
          state: EntityState.Ready,
          createdBy: userId,
        },
      ],
      order: {
        id: -1,
      },
      take: 500,
    });
  }
}
