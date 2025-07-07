import { HttpException, HttpStatus, Injectable, Logger } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { diskStorage } from 'multer';
import { existsSync, mkdirSync, realpathSync } from 'fs';
import { unlink, rename, copyFile } from 'node:fs/promises';
import { FileReferenceEntity } from '../entities/file-reference.entity';
import { join, resolve } from 'path';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

enum FileErrorCode {
  ExceedMaxSize = 'files:exceedMaxSize',
  InvalidFormat = 'files:invalidFormat',
}

@Injectable()
export class FilesService {
  private readonly logger = new Logger(FilesService.name);

  constructor(
    @InjectRepository(FileReferenceEntity)
    private readonly fileReferencerRepository: Repository<FileReferenceEntity>,
  ) {}

  static UploadsDirectory = 'tmp/uploads';

  public static getTemporaryFileMulterOptions() {
    return {
      storage: diskStorage({
        destination: join(
          FilesService.getStorageDirectory(),
          FilesService.UploadsDirectory,
        ),
        filename: (req, file, callback) => {
          callback(null, randomUUID());
        },
      }),
    };
  }

  public static ensureDirectoryExists(directory: string) {
    if (!existsSync(directory)) {
      mkdirSync(directory, { recursive: true });
    }
  }

  public static getStorageDirectory() {
    return process.env.STORAGE_DIRECTORY;
  }

  public async uploadTemporaryFile(
    file: Express.Multer.File,
    ownerId: number,
    options?: {
      extensions?: string[];
      mimeTypes?: string[];
      maxSize?: number;
    },
  ) {
    const sizeInBytes = file.size;
    const mimeType = file.mimetype;
    const extension = this.getFileExtension(file);

    try {
      if (options?.maxSize) {
        this.ensureTemporaryFileMaxSize(sizeInBytes, options.maxSize);
      }

      if (options?.mimeTypes) {
        this.ensureTemporaryFileMimeType(mimeType, options.mimeTypes);
      }

      if (options?.extensions) {
        this.ensureTemporaryFileExtension(extension, options.extensions);
      }
    } catch (e) {
      const normalizedPath = fs.realpathSync(path.resolve(FilesService.getStorageDirectory(), file.path));
       if (!normalizedPath.startsWith(FilesService.getStorageDirectory())) {
        throw new HttpException('Invalid file path', HttpStatus.FORBIDDEN);
      }
      await unlink(normalizedPath);
      const errorCode = e.getResponse()?.errorCode || null;
      if (errorCode === FileErrorCode.InvalidFormat)
        this.logger.error(
          `File with name "${file.originalname}" and mimetype "${mimeType}" does not match format.`,
          `MimeTypes: ${
            options?.mimeTypes ? options.mimeTypes.join(', ') : 'any'
          }.`,
          `Extensions: ${
            options?.extensions ? options.extensions.join(', ') : 'any'
          }.`,
          e.stack,
        );
      throw e;
    }

    const fileReference = new FileReferenceEntity({
      id: file.filename,
      name: file.originalname,
      extension,
      mimeType,
      sizeInBytes,
      directoryInStorage: FilesService.UploadsDirectory,
      isPersistent: false,
      ownerId,
    });
    await this.fileReferencerRepository.save(fileReference);
    return fileReference.id;
  }

  public getFileReferenceScriptParams(fileReference?: FileReferenceEntity) {
    if (!fileReference) {
      return 'NULL NULL NULL';
    }
    return [
      fileReference.id,
      fileReference.name.replaceAll(/\s+/g, '_'),
      fileReference.extension,
    ].join(' ');
  }

  public async getFileReference(id: string) {
    return await this.fileReferencerRepository.findOneBy({ id });
  }

  public async getFileReferenceOrThrow(id: string) {
    const fileReference = await this.getFileReference(id);
    if (!fileReference) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: 'File not found',
        },
        HttpStatus.NOT_FOUND,
      );
    }
    return fileReference;
  }

  public ensureFileReferenceIsOwnedBy(
    fileReference: FileReferenceEntity,
    userId: number,
  ) {
    if (fileReference.ownerId !== userId) {
      throw new HttpException(
        {
          statusCode: HttpStatus.FORBIDDEN,
          message: 'File access forbidden',
        },
        HttpStatus.FORBIDDEN,
      );
    }
  }

  public async moveUploadedFileToPersistentStorage(
    fileReference: FileReferenceEntity,
    directoryInStorage: string,
  ) {
    const newDirectory = join(
      FilesService.getStorageDirectory(),
      directoryInStorage,
    );
    FilesService.ensureDirectoryExists(newDirectory);
    const newPath = join(newDirectory, fileReference.id);
    const oldPath = join(
      FilesService.getStorageDirectory(),
      fileReference.directoryInStorage,
      fileReference.id,
    );
    await this.moveFile(oldPath, newPath);

    fileReference.directoryInStorage = directoryInStorage;
    fileReference.isPersistent = true;
    await this.fileReferencerRepository.save(fileReference);
  }

  private ensureTemporaryFileMaxSize(fileSize: number, maxSize: number) {
    if (fileSize > maxSize) {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          errorCode: FileErrorCode.ExceedMaxSize,
          message: 'File exceed max size',
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  private ensureTemporaryFileMimeType(mimeType: string, mimeTypes: string[]) {
    if (!mimeTypes.includes(mimeType)) {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          errorCode: FileErrorCode.InvalidFormat,
          message: 'Invalid file format',
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  private ensureTemporaryFileExtension(
    extension: string,
    extensions: string[],
  ) {
    if (!extensions.includes(extension)) {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          errorCode: FileErrorCode.InvalidFormat,
          message: 'Invalid file format',
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  private getFileExtension(file: Express.Multer.File) {
    const parts = file.originalname.split('.');
    return parts[parts.length - 1];
  }

  private async moveFile(oldPath: string, newPath: string) {
    try {
      await rename(oldPath, newPath);
    } catch (error) {
      if (error.code === 'EXDEV') {
        await copyFile(oldPath, newPath);
        await unlink(oldPath);
      } else {
        throw error;
      }
    }
  }
}
