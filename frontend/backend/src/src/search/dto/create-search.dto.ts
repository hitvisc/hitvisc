import { IsNotEmpty } from 'class-validator';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { ApplicationId } from '../enums/application-id';
import { ResourcesType } from '../enums/resources-type';
import { HitSelectionCriterion } from '../enums/hit-selection-criterion';
import { StoppingCriterion } from '../enums/stopping-criterion';
import { AutoDockVinaProtocolSource } from '../enums/auto-dock-vina-protocol-source';
import { CmDockProtocolSource } from '../enums/cm-dock-protocol-source';

export class CreateSearchDto {
  @IsNotEmpty()
  readonly name: string;

  @IsNotEmpty()
  readonly typeOfUse: TypeOfUse;

  readonly description: string;

  @IsNotEmpty()
  readonly targetId: number;

  @IsNotEmpty()
  readonly libraryId: number;

  @IsNotEmpty()
  readonly applicationId: ApplicationId;

  @IsNotEmpty()
  readonly resourcesType: ResourcesType;

  @IsNotEmpty()
  readonly launch: boolean;

  @IsNotEmpty()
  readonly hitSelectionCriterion: HitSelectionCriterion;

  @IsNotEmpty()
  readonly hitSelectionValue: number;

  @IsNotEmpty()
  readonly stoppingCriterion: StoppingCriterion;

  @IsNotEmpty()
  readonly stoppingValue: number;

  @IsNotEmpty()
  readonly notifyMeOfFoundHits: boolean;

  @IsNotEmpty()
  readonly notifyMeCompletionOf: boolean;

  readonly completedLigandsPercent: number | null;

  readonly autoDockVinaParameters: AutoDockVinaParameters | null;

  readonly cmDockParameters: CmDockParameters | null;
}

class AutoDockVinaParameters {
  inputType: AutoDockVinaProtocolSource;

  protocolFileId: string | null;

  centerX: number | null;

  centerY: number | null;

  centerZ: number | null;

  sizeX: number | null;

  sizeY: number | null;

  sizeZ: number | null;

  exhaustiveness: number | null;

  nmodes: number | null;

  erange: number | null;
}

class CmDockParameters {
  inputType: CmDockProtocolSource;

  protocolFileId: string | null;

  siteParamsFileId: string | null;

  filterParamsFileId: string | null;

  referenceLigandFileId: string | null;

  cavRadius: number | null;

  smallSphereRadius: number | null;

  maxCav: number | null;

  minVol: number | null;

  volInc: number | null;

  centerX: number | null;

  centerY: number | null;

  centerZ: number | null;

  largeSphereRadius: number | null;

  step: number | null;
}
