import { z } from 'zod';

export const SuccessLoginDtoSchema = z.object({
  jwt: z.string(),
});

export type SuccessLoginDto = z.infer<typeof SuccessLoginDtoSchema>;
