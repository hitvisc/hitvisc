import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-local';
import { AuthUserDto } from '../dto/auth-user.dto';
import { UserEntity } from '../entities/user.entity';
import { UserService } from '../services/user.service';

/** Локальная стратегия для авторизации пользователя */
@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  /**
   * Подключает зависимости
   * @param userService сервис авторизации
   */
  constructor(private userService: UserService) {
    super({
      usernameField: 'email',
      passwordField: 'password',
    });
  }

  /**
   * Валидирует данные пользователя
   * @param auth данные для авторизации
   * @returns данные пользователя
   */
  async validate(
    email: AuthUserDto['email'],
    password: AuthUserDto['password'],
  ): Promise<UserEntity> {
    const user = await this.userService.validateUser({ email, password });

    if (!user) {
      throw new UnauthorizedException();
    }

    return user;
  }
}
