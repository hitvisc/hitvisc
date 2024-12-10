import { ConfigService } from '@nestjs/config';
import { config } from 'dotenv';
import { UserEntityAddIsEmailConfirmed1691524538264 } from './migrations/1691524538264-UserEntityAddIsEmailConfirmed';
import { DataSource } from 'typeorm';

config();

const configService = new ConfigService();

/** Настройки подключения к базе */
export default new DataSource({
  type: 'postgres',
  url: configService.get('DB_URL'),
  schema: configService.get('DB_SCHEMA'),
  entities: [],
  migrations: [UserEntityAddIsEmailConfirmed1691524538264],
});
