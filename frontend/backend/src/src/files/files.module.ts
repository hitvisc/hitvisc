import { TypeOrmModule } from '@nestjs/typeorm';
import { Module } from '@nestjs/common';
import { FilesService } from './services/files.service';
import { FileReferenceEntity } from './entities/file-reference.entity';
import { ConfigModule } from '@nestjs/config';

@Module({
  exports: [FilesService],
  imports: [TypeOrmModule.forFeature([FileReferenceEntity]), ConfigModule],
  providers: [FilesService],
})
export class FilesModule {
  constructor() {
    FilesService.ensureDirectoryExists(FilesService.getStorageDirectory());
  }
}
