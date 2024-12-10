import { ApplicationId } from '../enums/application-id';
import { ResourcesType } from '../enums/resources-type';
import { HitSelectionCriterion } from '../enums/hit-selection-criterion';
import { StoppingCriterion } from '../enums/stopping-criterion';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { EntityState } from '../../core/enums/entity-state';

export class SearchCardDto {
  readonly id: number;
  readonly name: string;
  readonly typeOfUse: TypeOfUse;
  readonly description: string;
  readonly targetId: number;
  readonly targetName: string;
  readonly libraryId: number;
  readonly libraryName: string;
  readonly applicationId: ApplicationId;
  readonly hitSelectionCriterion: HitSelectionCriterion;
  readonly hitSelectionValue: number;
  readonly stoppingCriterion: StoppingCriterion;
  readonly stoppingValue: number;
  readonly resourcesType: ResourcesType;
  readonly creatorId: number;
  readonly creatorName: string;
  readonly state: EntityState;
  readonly isCompleted: boolean;
}
