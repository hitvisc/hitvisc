import { z } from 'zod';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';
import { PdbSource } from '~/app-modules/library/enums/PdbSource';
import { EntityState } from '~/app-modules/core/enums/EntityState';

export const TargetDtoSchema = z.object({
  name: z.string(),
  description: z.string(),
  // the original author(s) of the PDB structure data.
  authors: z.string(),
  // the original source of the PDB structure data (URL, DOI, PDB ID, literature citation etc.)
  source: z.string(),
  typeOfUse: z.nativeEnum(TypeOfUse),
});

export const CreateTargetDtoSchema = z
  .object({
    pdbSource: z.nativeEnum(PdbSource),
    pdbFileId: z.string().nullable(),
    pdbId: z.string().nullable(),
    extractReferenceLigands: z.boolean(),
    referenceLigandsFileId: z.string().nullable(),
  })
  .merge(TargetDtoSchema);

export const TargetCardDtoSchema = z
  .object({
    id: z.number(),
    creatorId: z.number(),
    creatorName: z.string(),
    isFavourite: z.boolean(),
    state: z.nativeEnum(EntityState),
  })
  .merge(TargetDtoSchema);

export type TargetDto = z.infer<typeof TargetDtoSchema>;

export type CreateTargetDto = z.infer<typeof CreateTargetDtoSchema>;

export type TargetCardDto = z.infer<typeof TargetCardDtoSchema>;
