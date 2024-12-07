import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HostEntity } from './entities/host.entity';
import { HostService } from './services/host.service';
import { HostController } from './controllers/host.controller';
import { ConfigModule } from '@nestjs/config';
import { ShellModule } from '../shell/shell.module';
import { UserModule } from '../user/user.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([HostEntity]),
    ConfigModule,
    UserModule,
    ShellModule,
  ],
  providers: [HostService],
  controllers: [HostController],
})
export class HostModule {}
