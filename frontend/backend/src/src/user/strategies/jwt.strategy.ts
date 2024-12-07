import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { JwtTokenPayloadDto } from '../dto/jwt-token-payload.dto';

/** Стратегия для авторизации пользователя через токен */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  /**
   * Подключает зависимости
   * @param configService сервис настроек
   */
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_TOKEN_SECRET'),
    });
  }

  /**
   * Валидирует данные пользователя
   * @param payload данные из токена
   * @returns данные пользователя
   */
  async validate(payload: JwtTokenPayloadDto): Promise<JwtTokenPayloadDto> {
    return {
      id: payload.id,
      email: payload.email,
    };
  }
}
