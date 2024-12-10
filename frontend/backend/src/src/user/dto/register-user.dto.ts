import { IsEmail, IsNotEmpty } from 'class-validator';

/** Данные пользователя для регистрации */
export class RegisterUserDto {
  /** Имя пользователя */
  @IsNotEmpty()
  readonly name: string;

  /** Адрес эл. почты */
  @IsNotEmpty()
  @IsEmail()
  readonly email: string;

  /** Пароль */
  @IsNotEmpty()
  readonly password: string;
}
