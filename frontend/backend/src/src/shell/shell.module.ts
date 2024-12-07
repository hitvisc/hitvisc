import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ShellService } from './services/shell.service';

@Module({
  exports: [ShellService],
  imports: [ConfigModule],
  providers: [ShellService],
})
export class ShellModule {}
