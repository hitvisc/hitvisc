import { HostUsageType } from '../enums/host-usage-type';

export class HostDto {
  readonly id: number;
  readonly name: string;
  readonly lastRequestAt: string | null;
  readonly tasksInProgress: number;
  readonly tasksCompleted: number;
  readonly usageType: HostUsageType;
  readonly userId: number;
}
