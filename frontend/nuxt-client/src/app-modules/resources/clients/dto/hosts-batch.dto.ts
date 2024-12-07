import { z } from 'zod';
import { HostDtoSchema } from '~/app-modules/resources/clients/dto/host.dto';

export const HostsBatchDtoSchema = z.object({
  totalCount: z.number(),
  hosts: HostDtoSchema.array(),
});

export type HostsBatchDto = z.infer<typeof HostsBatchDtoSchema>;
