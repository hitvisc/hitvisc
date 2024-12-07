import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Module } from '@nestjs/common';
import { UserModule } from '../user/user.module';
import { HitviscSearchEntity } from './entities/hitvisc-search.entity';
import { SearchEntity } from './entities/search.entity';
import { SearchService } from './services/search.service';
import { SearchController } from './controllers/search.controller';
import { LibraryModule } from '../library/library.module';
import { TargetModule } from '../target/target.module';
import { FilesModule } from '../files/files.module';
import { ConfigModule } from '@nestjs/config';
import { ShellModule } from '../shell/shell.module';
import { EntityMappingModule } from '../entity-mapping/entity-mapping.module';

@Module({
  controllers: [SearchController],
  exports: [SearchService],
  imports: [
    TypeOrmModule.forFeature([SearchEntity, HitviscSearchEntity]),
    EntityMappingModule,
    PassportModule,
    ConfigModule,
    UserModule,
    LibraryModule,
    TargetModule,
    FilesModule,
    ShellModule,
  ],
  providers: [SearchService],
})
export class SearchModule {}
