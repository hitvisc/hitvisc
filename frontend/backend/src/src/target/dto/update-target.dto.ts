import { IsNotEmpty } from 'class-validator';
import { TypeOfUse } from '../../core/enums/type-of-use';

export class UpdateTargetDto {
  @IsNotEmpty()
  readonly name: string;

  readonly description: string;

  @IsNotEmpty()
  readonly authors: string;

  readonly source: string;

  readonly typeOfUse: TypeOfUse;
}
