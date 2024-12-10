import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { UserEntity } from '../entities/user.entity';
import EmailSenderService from './../../email-sender/services/email-sender.service';
import { UserService } from './user.service';
import { UserState } from '../enums/user-state';

/** Сервис для отправки письма для подтверждения регистрации */
@Injectable()
export class EmailConfirmationService {
  /**
   * Подключает зависимости
   * @param jwtService сервис токенов
   * @param configService сервис настроек
   * @param emailSenderService сервис отправки писем
   * @param userService сервис пользователя
   */
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly emailSenderService: EmailSenderService,
    private readonly userService: UserService,
  ) {}

  /**
   * Посылает на указанный емайл письмо подтверждения регистрации
   * @param email емайл
   * @returns результат отправки письма
   */
  public sendVerificationLink(email: string): Promise<any> {
    const payload: { email: string } = { email };
    const token = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_VERIFICATION_TOKEN_SECRET'),
      expiresIn: '10m',
    });

    const url = `${this.configService.get(
      'EMAIL_CONFIRMATION_URL',
    )}?token=${token}`;

    const text = `Welcome to the application. To confirm the email address, click here: ${url}`;

    return this.emailSenderService.sendMail({
      from: this.configService.get('EMAIL_USER'),
      to: email,
      subject: 'Email confirmation',
      text,
    });
  }

  /**
   * Подтверждает адрес эл. почты пользователя
   * @param email почта
   */
  public async confirmEmail(email: string): Promise<void> {
    const user = await this.userService.findByEmail(email);

    if (user.state !== UserState.New) {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: 'Email already confirmed',
        },
        HttpStatus.BAD_REQUEST,
      );
    }

    await this.userService.markEmailAsConfirmed(email);
  }

  /**
   * Декодирует токен подтверждения адреса эл. почты
   * @param token токен
   * @returns почта
   */
  public async decodeConfirmationToken(
    token: string,
  ): Promise<UserEntity['email']> {
    try {
      const payload = await this.jwtService.verify(token, {
        secret: this.configService.get('JWT_VERIFICATION_TOKEN_SECRET'),
      });

      if (typeof payload === 'object' && 'email' in payload) {
        return payload.email;
      }

      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: 'Decode confirmation token error',
        },
        HttpStatus.BAD_REQUEST,
      );
    } catch (error) {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message:
            error?.name === 'TokenExpiredError'
              ? 'Email confirmation token expired'
              : 'Bad confirmation token',
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  /**
   * Повторно отправляет ссылку для подтверждения адреса эл. почты по
   * идентификатору пользователя
   * @param email email пользователя
   */
  public async resendConfirmationLink(email: UserEntity['email']) {
    const user = await this.userService.findByEmail(email);
    if (user.state !== UserState.New) {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: 'Email already confirmed',
        },
        HttpStatus.BAD_REQUEST,
      );
    }
    await this.sendVerificationLink(user.email);
  }
}
