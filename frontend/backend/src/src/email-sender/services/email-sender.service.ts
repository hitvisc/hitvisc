import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createTransport } from 'nodemailer';
import Mail from 'nodemailer/lib/mailer';

/** Сервис для отправки писем */
@Injectable()
export default class EmailSenderService {
  /**
   * Подключает зависимости
   * @param configService сервис настроек
   */
  constructor(configService: ConfigService) {
    this.sender = createTransport({
      host: configService.get('EMAIL_HOST'),
      port: configService.get('EMAIL_PORT'),
      pool: true,
      secure: true,
      auth: {
        user: configService.get('EMAIL_USER'),
        pass: configService.get('EMAIL_PASSWORD'),
      },
    });
  }

  /** Отправитель */
  private sender: Mail;

  /**
   * Отправляет письмо
   * @param options настройки отправителя
   * @returns результат отправки
   */
  sendMail(options: Mail.Options) {
    return this.sender.sendMail(options);
  }
}
