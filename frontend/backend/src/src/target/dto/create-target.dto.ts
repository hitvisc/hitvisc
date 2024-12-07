import { IsNotEmpty } from 'class-validator';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { PdbSource } from '../enums/pdb-source';

export class CreateTargetDto {
  @IsNotEmpty()
  readonly name: string;

  readonly description: string;

  @IsNotEmpty()
  readonly authors: string;

  readonly source: string;

  readonly typeOfUse: TypeOfUse;

  readonly pdbSource: PdbSource;

  readonly pdbFileId: string | null;

  readonly pdbId: string | null;

  readonly extractReferenceLigands: boolean;

  readonly referenceLigandsFileId: string | null;
}
