import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import EmailSenderService from './services/email-sender.service';

/** Подмодуль для отправок писем */
@Module({
  imports: [ConfigModule],
  providers: [EmailSenderService],
  exports: [EmailSenderService],
})
export class EmailSenderModule {}
