import { TypeOfUse } from '../../core/enums/type-of-use';
import { EntityState } from '../../core/enums/entity-state';

export class LibraryCardDto {
  readonly id: number;
  readonly name: string;
  readonly description: string;
  readonly authors: string;
  readonly source: string;
  readonly typeOfUse: TypeOfUse;
  readonly creatorId: number;
  readonly creatorName: string;
  readonly isFavourite: boolean;
  readonly state: EntityState;
}
