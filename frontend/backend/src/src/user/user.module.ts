import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmailSenderModule } from '../email-sender/email-sender.module';
import { UserController } from './controllers/user.controller';
import { UserEntity } from './entities/user.entity';
import { EmailConfirmationService } from './services/email-confirmation.service';
import { UserService } from './services/user.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { LocalStrategy } from './strategies/local.strategy';
import { PasswordResetService } from './services/password-reset.service';
import { ShellModule } from '../shell/shell.module';

/** Подмодуль для пользователя */
@Module({
  imports: [
    TypeOrmModule.forFeature([UserEntity]),
    PassportModule,
    ConfigModule,
    ShellModule,
    EmailSenderModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secretOrPrivateKey: configService.get('JWT_TOKEN_SECRET'),
        signOptions: {
          expiresIn: configService.get('JWT_TOKEN_EXPIRES_IN'),
        },
      }),
      inject: [ConfigService],
    }),
  ],
  providers: [
    UserService,
    LocalStrategy,
    JwtStrategy,
    EmailConfirmationService,
    PasswordResetService,
  ],
  controllers: [UserController],
  exports: [UserService],
})
export class UserModule {}
