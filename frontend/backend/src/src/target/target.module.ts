import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from '../user/user.module';
import { FilesModule } from '../files/files.module';
import { TargetEntity } from './entities/target.entity';
import { TargetService } from './services/target.service';
import { TargetController } from './controllers/target.controller';
import { ShellModule } from '../shell/shell.module';

@Module({
  controllers: [TargetController],
  exports: [TargetService],
  imports: [
    TypeOrmModule.forFeature([TargetEntity]),
    ConfigModule,
    PassportModule,
    UserModule,
    FilesModule,
    ShellModule,
  ],
  providers: [TargetService],
})
export class TargetModule {}
