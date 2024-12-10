import { Column, Entity, PrimaryColumn } from 'typeorm';
import { EntityType } from '../enums/entity-type';

@Entity('entity_mapping', { synchronize: false })
export class EntityMappingEntity {
  @PrimaryColumn({
    type: 'integer',
  })
  id: number;

  @Column({
    type: 'int4',
    name: 'front_entity_id',
  })
  frontEntityId: number;

  @Column({
    type: 'int4',
    name: 'back_entity_id',
  })
  backEntityId: number;

  @Column({
    type: 'char',
    name: 'entity_type',
    comment:
      'Тип сущности: ' +
      'T - мишень (target); ' +
      'L - библиотека лигандов (library); ' +
      'S - поиск (search)',
  })
  entityType: EntityType;
}
