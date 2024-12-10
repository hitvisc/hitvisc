import { z } from 'zod';
import { ApplicationType } from '~/app-modules/library/enums/ApplicationType';
import { HitSelectionCriterion } from '~/app-modules/projects/enums/HitSelectionCriterion';
import { StoppingCriterion } from '~/app-modules/projects/enums/StoppingCriterion';
import { ResourcesType } from '~/app-modules/library/enums/ResourcesType';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';
import { EntityState } from '~/app-modules/core/enums/EntityState';
import { AutoDockVinaProtocolSource } from '~/app-modules/projects/enums/AutoDockVinaProtocolSource';
import { CmDockProtocolSource } from '~/app-modules/projects/enums/CmDockProtocolSource';

const AutoDockVinaParametersSchema = z.object({
  inputType: z.nativeEnum(AutoDockVinaProtocolSource),
  protocolFileId: z.string().nullable(),
  centerX: z.number().nullable(),
  centerY: z.number().nullable(),
  centerZ: z.number().nullable(),
  sizeX: z.number().nullable(),
  sizeY: z.number().nullable(),
  sizeZ: z.number().nullable(),
  exhaustiveness: z.number().nullable(),
  nmodes: z.number().nullable(),
  erange: z.number().nullable(),
});

const CmDockParametersSchema = z.object({
  inputType: z.nativeEnum(CmDockProtocolSource),
  referenceLigandFileId: z.string().nullable(),
  protocolFileId: z.string().nullable(),
  siteParamsFileId: z.string().nullable(),
  filterParamsFileId: z.string().nullable(),
  cavRadius: z.number().nullable(),
  smallSphereRadius: z.number().nullable(),
  maxCav: z.number().nullable(),
  minVol: z.number().nullable(),
  volInc: z.number().nullable(),
  centerX: z.number().nullable(),
  centerY: z.number().nullable(),
  centerZ: z.number().nullable(),
  largeSphereRadius: z.number().nullable(),
  step: z.number().nullable(),
});

export const createSearchDtoSchema = z.object({
  launch: z.boolean(),
  name: z.string(),
  typeOfUse: z.nativeEnum(TypeOfUse),
  description: z.string(),
  targetId: z.number(),
  libraryId: z.number(),
  applicationId: z.nativeEnum(ApplicationType),
  resourcesType: z.nativeEnum(ResourcesType),
  hitSelectionCriterion: z.nativeEnum(HitSelectionCriterion),
  hitSelectionValue: z.number(),
  stoppingCriterion: z.nativeEnum(StoppingCriterion),
  stoppingValue: z.number(),
  notifyMeOfFoundHits: z.boolean(),
  notifyMeCompletionOf: z.boolean(),
  completedLigandsPercent: z.number().nullable(),
  autoDockVinaParameters: AutoDockVinaParametersSchema.nullable(),
  cmDockParameters: CmDockParametersSchema.nullable(),
});

export const SearchCardDtoSchema = z.object({
  id: z.number(),
  name: z.string(),
  typeOfUse: z.nativeEnum(TypeOfUse),
  description: z.string(),
  targetId: z.number(),
  targetName: z.string(),
  libraryId: z.number(),
  libraryName: z.string(),
  applicationId: z.nativeEnum(ApplicationType),
  hitSelectionCriterion: z.nativeEnum(HitSelectionCriterion),
  hitSelectionValue: z.number(),
  stoppingCriterion: z.nativeEnum(StoppingCriterion),
  stoppingValue: z.number(),
  resourcesType: z.nativeEnum(ResourcesType),
  creatorId: z.number(),
  creatorName: z.string(),
  state: z.nativeEnum(EntityState),
  isCompleted: z.boolean(),
});

export type createSearchDto = z.infer<typeof createSearchDtoSchema>;

export type SearchCardDto = z.infer<typeof SearchCardDtoSchema>;
