import { IsNotEmpty } from 'class-validator';

/** Данные для сброса пароля */
export class ResetPasswordDto {
  @IsNotEmpty()
  readonly email: string;
}
