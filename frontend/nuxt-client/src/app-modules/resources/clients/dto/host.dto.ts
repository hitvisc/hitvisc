import { z } from 'zod';
import { HostUsageType } from '~/app-modules/resources/enums/HostUsageType';

export const HostDtoSchema = z.object({
  /** Идентификатор ресурса */
  id: z.number(),

  /** Имя узла ресурса */
  name: z.string().nullable(),

  /** Дата последнего обращения */
  lastRequestAt: z.string().datetime().nullable(),

  /** Вычислений в последнее обращение */
  tasksInProgress: z.number(),

  /** Общее число вычислений */
  tasksCompleted: z.number(),

  /** Тип использования ресурса */
  usageType: z.nativeEnum(HostUsageType),

  /** Владелец вычислительного узла */
  userId: z.number(),
});

export type HostDto = z.infer<typeof HostDtoSchema>;
