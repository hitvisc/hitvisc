import { TypeOrmModule } from '@nestjs/typeorm';
import { Module } from '@nestjs/common';
import { EntityMappingEntity } from './entities/entity-mapping.entity';
import { EntityMappingService } from './services/entity-mapping.service';

@Module({
  exports: [EntityMappingService],
  imports: [TypeOrmModule.forFeature([EntityMappingEntity])],
  providers: [EntityMappingService],
})
export class EntityMappingModule {}
