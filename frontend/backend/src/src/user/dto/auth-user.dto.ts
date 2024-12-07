import { IsNotEmpty } from 'class-validator';

/** Данные пользователя для авторизации */
export class AuthUserDto {
  @IsNotEmpty()
  readonly email: string;

  @IsNotEmpty()
  readonly password: string;
}
