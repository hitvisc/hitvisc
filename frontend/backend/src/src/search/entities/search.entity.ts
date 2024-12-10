import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { ApplicationId } from '../enums/application-id';
import { ResourcesType } from '../enums/resources-type';
import { HitSelectionCriterion } from '../enums/hit-selection-criterion';
import { StoppingCriterion } from '../enums/stopping-criterion';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { EntityState } from '../../core/enums/entity-state';

@Entity('front_search')
export class SearchEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({
    type: 'enum',
    name: 'type_of_use',
    enum: TypeOfUse,
    default: TypeOfUse.Restricted,
  })
  typeOfUse: TypeOfUse;

  @Column({
    type: 'enum',
    enum: EntityState,
    default: EntityState.Preparing,
  })
  state: EntityState;

  @Column({ length: 2000 })
  description: string;

  @Column({
    name: 'target_id',
  })
  targetId: number;

  @Column({
    name: 'library_id',
  })
  libraryId: number;

  @Column({
    type: 'enum',
    name: 'application_id',
    enum: ApplicationId,
  })
  applicationId: ApplicationId;

  @Column({
    type: 'enum',
    name: 'hit_selection_criterion',
    enum: HitSelectionCriterion,
  })
  hitSelectionCriterion: HitSelectionCriterion;

  @Column({
    type: 'float',
    name: 'hit_selection_value',
  })
  hitSelectionValue: number;

  @Column({
    type: 'enum',
    name: 'stopping_criterion',
    enum: StoppingCriterion,
  })
  stoppingCriterion: StoppingCriterion;

  @Column({
    type: 'float',
    name: 'stopping_value',
  })
  stoppingValue: number;

  @Column({
    type: 'enum',
    name: 'resources_type',
    enum: ResourcesType,
  })
  resourcesType: ResourcesType;

  @Column({
    name: 'created_by',
  })
  createdBy: number;

  constructor(partial: Partial<SearchEntity>) {
    Object.assign(this, partial);
  }
}
