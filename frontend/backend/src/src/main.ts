import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import dataSource from '../typeorm-config';
import { ValidationPipe } from '@nestjs/common';

/** Входная точка для приложения */
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  app.useGlobalPipes(new ValidationPipe());
  app.enableCors({
    origin: configService.get('CORS_ORIGIN_HOSTS').split(' '),
    credentials: true,
  });
  await dataSource.initialize();
  await app.listen(configService.get('APP_PORT'));
}

bootstrap();
