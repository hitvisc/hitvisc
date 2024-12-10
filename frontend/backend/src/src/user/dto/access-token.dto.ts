import { IsNotEmpty } from 'class-validator';

/** Данные токена пользователя */
export class AccessTokenDto {
  @IsNotEmpty()
  readonly accessToken: string;
}
