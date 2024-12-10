import { IsNotEmpty } from 'class-validator';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { LibrarySource } from '../enums/library-source';

export class CreateLibraryDto {
  @IsNotEmpty()
  readonly name: string;

  readonly description: string;

  @IsNotEmpty()
  readonly authors: string;

  readonly source: string;

  readonly typeOfUse: TypeOfUse;

  readonly fileSource: LibrarySource;

  readonly fileId: string | null;

  readonly fileUrl: string | null;
}
