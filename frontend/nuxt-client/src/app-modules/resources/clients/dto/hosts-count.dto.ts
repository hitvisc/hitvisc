import { z } from 'zod';
import { HostUsageType } from '~/app-modules/resources/enums/HostUsageType';

export const HostsCountDtoSchema = z.record(z.nativeEnum(HostUsageType), z.number());

export type HostsCountDto = z.infer<typeof HostsCountDtoSchema>;
