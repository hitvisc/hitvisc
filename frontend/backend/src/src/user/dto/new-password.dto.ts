import { IsNotEmpty, IsString } from 'class-validator';

/** Объект для установки пароля после сброса */
export class NewPasswordDto {
  /** Токен для проверки */
  @IsString()
  @IsNotEmpty()
  token: string;

  /** Новый пароль */
  @IsString()
  @IsNotEmpty()
  password: string;
}
