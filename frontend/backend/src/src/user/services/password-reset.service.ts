import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { UserEntity } from '../entities/user.entity';
import EmailSenderService from './../../email-sender/services/email-sender.service';
import { UserService } from './user.service';
import { UserState } from '../enums/user-state';

/** Сервис для отправки письма для подтверждения регистрации */
@Injectable()
export class PasswordResetService {
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
   * Посылает на указанный емайл письмо для сброса пароля
   * @param email емайл
   * @returns результат отправки письма
   */
  public async sendResetPasswordLink(email: string): Promise<any> {
    const user = await this.userService.findByEmail(email);

    if (!user) return;

    const payload: { email: string } = { email };
    const token = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_VERIFICATION_TOKEN_SECRET'),
      expiresIn: '10m',
    });

    const url = `${this.configService.get('NEW_PASSWORD_URL')}?token=${token}`;

    const text = `Password reset requested. To set new password, click here: ${url}`;

    return this.emailSenderService.sendMail({
      from: this.configService.get('EMAIL_USER'),
      to: email,
      subject: 'Reset password',
      text,
    });
  }

  /**
   * Подтверждает адрес эл. почты пользователя
   * @param email почта
   * @param password новый пароль
   */
  public async resetUserPassword(
    email: string,
    password: string,
  ): Promise<void> {
    const user = await this.userService.findByEmail(email);

    if (!user || user.state !== UserState.Unlocked) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: 'User not found',
        },
        HttpStatus.NOT_FOUND,
      );
    }

    await this.userService.setUserPassword(email, password);

    const url = this.configService.get('LOGIN_URL');

    const text = `Account password changed successfully! You can sign in with new password here ${url}`;

    return this.emailSenderService.sendMail({
      from: this.configService.get('EMAIL_USER'),
      to: email,
      subject: 'Account password changed',
      text,
    });
  }

  /**
   * Декодирует токен для сброса пароля
   * @param token токен
   * @returns почта
   */
  public async decodeResetToken(token: string): Promise<UserEntity['email']> {
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
              ? 'Reset password token expired'
              : 'Bad reset password token',
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }
}
