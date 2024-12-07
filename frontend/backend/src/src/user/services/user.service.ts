import { HttpException, HttpStatus, Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { AuthUserDto } from '../dto/auth-user.dto';
import { RegisterUserDto } from '../dto/register-user.dto';
import { UserEntity } from '../entities/user.entity';
import { UserState } from '../enums/user-state';
import { hash, verify } from './hash';
import { ConfigService } from '@nestjs/config';
import { ShellService } from '../../shell/services/shell.service';

/** Сервис для управления пользователем */
@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  /**
   * Подключает зависимсоти
   * @param userRepository репозиторий пользователя
   * @param jwtService сервис для подписи токенов
   * @param configService
   * @param shellService
   */
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly shellService: ShellService,
  ) {}

  /**
   * Проверяет пароль пользователя
   * @param auth данные пользователя для авторизации
   * @returns данные пользователя или null
   */
  async validateUser(auth: AuthUserDto): Promise<UserEntity | null> {
    const user = await this.userRepository.findOneBy({
      email: auth.email,
    });

    return !!user && verify(user.passwordHash, auth.password) ? user : null;
  }

  /**
   * Генерирует токен для авторизации пользователя
   * @param user данные пользователя
   * @returns
   */
  generateToken(user: UserEntity): string {
    return this.jwtService.sign({
      id: user.id,
      email: user.email,
    });
  }

  /**
   * Получает данные пользователя по идентификатору
   * @param id идентификатор пользователя
   * @returns данные пользователя
   */
  async findById(id: UserEntity['id']): Promise<UserEntity | null> {
    return await this.userRepository.findOneBy({ id });
  }

  /**
   * Получает данные пользователей по идентификаторам
   * @param ids идентификаторы пользователей
   * @returns данные пользователей
   */
  async findByIds(ids: UserEntity['id'][]): Promise<UserEntity[]> {
    return await this.userRepository.findBy({ id: In(ids) });
  }

  /**
   * Получает данные пользователя по значению почты
   * @param email почта пользователя
   * @returns данные пользователя
   */
  async findByEmail(email: AuthUserDto['email']): Promise<UserEntity> {
    return await this.userRepository.findOneBy({ email });
  }

  /**
   * Получение списка всех пользователей
   * @returns список пользователей
   */
  async findAll(): Promise<UserEntity[]> {
    return await this.userRepository.find();
  }

  /**
   * Создает нового пользователя
   * @param dto данные пользователя
   * @returns новый пользователь
   */
  async create(dto: RegisterUserDto): Promise<UserEntity> {
    const existUser = await this.userRepository.findOneBy({
      email: dto.email,
    });

    if (existUser) {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: ['Email must be unique.'],
        },
        HttpStatus.BAD_REQUEST,
      );
    }

    const user = new UserEntity({
      login: dto.email,
      email: dto.email,
      passwordHash: dto.password,
      name: dto.name,
    });
    const result = await this.userRepository.save(user);

    await this.syncBoincUsers();

    return result;
  }

  async syncBoincUsers() {
    const scriptPath = this.configService.get<string>('SYNC_USERS_SCRIPT_PATH');
    if (!scriptPath) {
      this.logger.error('sync users script path is not set');
      return false;
    }

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        scriptPath,
      );
      if (stderr) {
        this.logger.error('sync users stderr:', stderr);
        return false;
      } else {
        this.logger.log('sync users stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('sync users error:', e);
      return false;
    }

    return true;
  }

  /**
   * Помечает почту пользователя, когда она подтверждена
   * @param email почта
   * @returns результат обновления пользователя
   */
  async markEmailAsConfirmed(email: string) {
    return this.userRepository.update(
      { email },
      {
        state: UserState.Unlocked,
      },
    );
  }

  /**
   * Установка пароля пользователя
   * @param email почта пользователя
   * @param password новый пароль
   * @returns данные пользователя
   */
  async setUserPassword(email: string, password: string) {
    return this.userRepository.update(
      { email },
      {
        passwordHash: hash(password),
      },
    );
  }
}
