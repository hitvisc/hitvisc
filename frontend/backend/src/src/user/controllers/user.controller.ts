import {
  Body,
  ClassSerializerInterceptor,
  Controller,
  Get,
  HttpCode,
  HttpException,
  HttpStatus,
  Logger,
  Post,
  Request,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthUserDto } from '../dto/auth-user.dto';
import { ConfirmEmailDto } from '../dto/confirm-email.dto';
import { RegisterUserDto } from '../dto/register-user.dto';
import { UserEntity } from '../entities/user.entity';
import { EmailConfirmationService } from '../services/email-confirmation.service';
import { UserService } from '../services/user.service';
import { ResetPasswordDto } from '../dto/reset-password.dto';
import { NewPasswordDto } from '../dto/new-password.dto';
import { PasswordResetService } from '../services/password-reset.service';

/** Контроллер для пользователей */
@Controller('api/users')
export class UserController {
  /**
   * Подключает зависимости
   * @param userService сервис пользователей
   * @param emailConfirmationService сервис отправки письма подтверждения регистрации
   * @param passwordResetService сервис для сброса пароля
   */
  constructor(
    private userService: UserService,
    private emailConfirmationService: EmailConfirmationService,
    private passwordResetService: PasswordResetService,
  ) {}

  /** Авторизует пользователя */
  @Post('login')
  @HttpCode(200)
  @UseGuards(AuthGuard('local'))
  async login(@Body() auth: AuthUserDto) {
    const user = await this.userService.findByEmail(auth.email);
    const jwt = this.userService.generateToken(user);

    return {
      ...user,
      jwt,
    };
  }

  /** Получает данные текущего пользователя */
  @Get('current')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async getCurrent(@Request() req): Promise<UserEntity> {
    return await this.userService.findByEmail(req.user.email);
  }

  /** Получает спискок пользователей */
  @Get()
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findAll(): Promise<UserEntity[]> {
    return await this.userService.findAll();
  }

  /**
   * Регистрирует нового пользователя
   * @param userData данные для пользователя
   * @returns созданный пользователь
   */
  @Post('register')
  @HttpCode(200)
  @UseInterceptors(ClassSerializerInterceptor)
  async create(@Body() userData: RegisterUserDto) {
    const user = await this.userService.create(userData);
    const sendEmailResp =
      await this.emailConfirmationService.sendVerificationLink(user.email);

    Logger.log(sendEmailResp);

    if (sendEmailResp.response.substr(0, 3) == '250') {
      Logger.log(`Письмо успешно отправлено на адрес ${user.email}!`);

      return user;
    }

    throw new HttpException(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message: [`Ошибка отправки письма на адрес ${user.email}!`],
      },
      HttpStatus.BAD_REQUEST,
    );
  }

  /**
   * Проверяет и подтверждает адрес почты по присланному токену
   * @param confirmationData данные для подтверждения
   */
  @Post('confirm')
  @HttpCode(200)
  @UseInterceptors(ClassSerializerInterceptor)
  async confirm(@Body() confirmationData: ConfirmEmailDto) {
    const email = await this.emailConfirmationService.decodeConfirmationToken(
      confirmationData.token,
    );
    await this.emailConfirmationService.confirmEmail(email);
  }

  /**
   * Запрос на сброс пароля
   * @param resetPasswordRequest данные для подтверждения
   */
  @Post('reset-password')
  @HttpCode(200)
  @UseInterceptors(ClassSerializerInterceptor)
  async resetPassword(@Body() resetPasswordRequest: ResetPasswordDto) {
    const { email } = resetPasswordRequest;
    const sendEmailResp = await this.passwordResetService.sendResetPasswordLink(
      email,
    );

    // если пользователь не найден, то sendEmailResp = undefined
    // защита от перебора пользовательских адресов
    if (!sendEmailResp) return;

    Logger.log(sendEmailResp);

    if (sendEmailResp.response.substr(0, 3) == '250') {
      Logger.log(`Письмо успешно отправлено на адрес ${email}!`);

      return;
    }

    throw new HttpException(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message: `Ошибка отправки письма на адрес ${email}!`,
      },
      HttpStatus.BAD_REQUEST,
    );
  }

  /**
   * Установка нового пароля после перехода по ссылке из письма
   * @param newPasswordRequest данные для установки нового пароля
   */
  @Post('new-password')
  @HttpCode(200)
  @UseInterceptors(ClassSerializerInterceptor)
  async setPassword(@Body() newPasswordRequest: NewPasswordDto) {
    const email = await this.passwordResetService.decodeResetToken(
      newPasswordRequest.token,
    );
    await this.passwordResetService.resetUserPassword(
      email,
      newPasswordRequest.password,
    );
  }

  /**
   * Повторно отправляет ссылку для подтверждения адреса эл. почты
   * @param req тело запроса
   */
  @Post('resend-confirmation-link')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  async resendConfirmationLink(@Request() req) {
    await this.emailConfirmationService.resendConfirmationLink(req.user.email);
  }
}
