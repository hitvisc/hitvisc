import { z } from 'zod';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';
import { LibrarySource } from '~/app-modules/library/enums/LibrarySource';
import { EntityState } from '~/app-modules/core/enums/EntityState';

export const LibraryDtoSchema = z.object({
  name: z.string(),
  description: z.string(),
  authors: z.string(),
  source: z.string(),
  typeOfUse: z.nativeEnum(TypeOfUse),
});

export const createLibraryDtoSchema = z
  .object({
    fileSource: z.nativeEnum(LibrarySource),
    fileUrl: z.string().nullable(),
    fileId: z.string().nullable(),
  })
  .merge(LibraryDtoSchema);

export const LibraryCardDtoSchema = z
  .object({
    id: z.number(),
    creatorId: z.number(),
    creatorName: z.string(),
    isFavourite: z.boolean(),
    state: z.nativeEnum(EntityState),
  })
  .merge(LibraryDtoSchema);

export type LibraryDto = z.infer<typeof LibraryDtoSchema>;

export type createLibraryDto = z.infer<typeof createLibraryDtoSchema>;

export type LibraryCardDto = z.infer<typeof LibraryCardDtoSchema>;
