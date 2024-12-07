import './config';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmailSenderModule } from './email-sender/email-sender.module';
import { EntityMappingModule } from './entity-mapping/entity-mapping.module';
import { UserModule } from './user/user.module';
import { LibraryModule } from './library/library.module';
import { TargetModule } from './target/target.module';
import { SearchModule } from './search/search.module';
import { FilesModule } from './files/files.module';
import { HostModule } from './host/host.module';

/** Основной модуль приложения */
@Module({
  imports: [
    ConfigModule.forRoot(),
    ScheduleModule.forRoot(),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        url: configService.get('DB_URL'),
        schema: configService.get('DB_SCHEMA'),
        synchronize: configService.get('DB_SYNC_MODELS') === 'true',
        autoLoadEntities: true,
      }),
      inject: [ConfigService],
    }),
    FilesModule,
    UserModule,
    EmailSenderModule,
    EntityMappingModule,
    LibraryModule,
    TargetModule,
    SearchModule,
    HostModule,
  ],
})
export class AppModule {}
