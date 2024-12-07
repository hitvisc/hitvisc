import { IsNotEmpty, IsString } from 'class-validator';

/** Объект для подтверждения почты */
export class ConfirmEmailDto {
  /** Токен для проверки */
  @IsString()
  @IsNotEmpty()
  token: string;
}
