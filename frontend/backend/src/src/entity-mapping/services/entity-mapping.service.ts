import { InjectRepository } from '@nestjs/typeorm';
import { Injectable } from '@nestjs/common';
import { In, Repository } from 'typeorm';
import { EntityMappingEntity } from '../entities/entity-mapping.entity';
import { EntityType } from '../enums/entity-type';

@Injectable()
export class EntityMappingService {
  constructor(
    @InjectRepository(EntityMappingEntity)
    private readonly entityMappingRepository: Repository<EntityMappingEntity>,
  ) {}

  async getBackSearchIdByFrontSearchId(frontEntityId: number) {
    const result = await this.entityMappingRepository.findOneBy({
      frontEntityId,
      entityType: EntityType.Search,
    });
    return result?.backEntityId ?? null;
  }

  async getSearchMappingsByFrontIds(frontEntityIds: number[]) {
    if (!frontEntityIds.length) return [];
    return await this.entityMappingRepository.findBy({
      frontEntityId: In(frontEntityIds),
      entityType: EntityType.Search,
    });
  }
}
