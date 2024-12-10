import { z } from 'zod';

export const NewHostParamsDtoSchema = z.object({
  email: z.string(),
  password: z.string(),
  projectUrl: z.string(),
});

export type NewHostParamsDto = z.infer<typeof NewHostParamsDtoSchema>;
