import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from '../user/user.module';
import { FilesModule } from '../files/files.module';
import { LibraryEntity } from './entities/library.entity';
import { LibraryService } from './services/library.service';
import { LibraryController } from './controllers/library.controller';
import { ShellModule } from '../shell/shell.module';

@Module({
  controllers: [LibraryController],
  exports: [LibraryService],
  imports: [
    TypeOrmModule.forFeature([LibraryEntity]),
    ConfigModule,
    PassportModule,
    UserModule,
    FilesModule,
    ShellModule,
  ],
  providers: [LibraryService],
})
export class LibraryModule {}
