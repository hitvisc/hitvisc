import { IsNotEmpty } from 'class-validator';
import { TypeOfUse } from '../../core/enums/type-of-use';

export class UpdateSearchDto {
  @IsNotEmpty()
  readonly name: string;

  @IsNotEmpty()
  readonly typeOfUse: TypeOfUse;

  readonly description: string;
}