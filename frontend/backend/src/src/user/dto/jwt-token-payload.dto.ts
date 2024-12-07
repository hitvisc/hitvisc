import { IsNotEmpty } from 'class-validator';

/** Данные для тела токена пользователя */
export class JwtTokenPayloadDto {
  @IsNotEmpty()
  readonly email: string;

  @IsNotEmpty()
  readonly id: number;
}
