import { HostUsageType } from '../enums/host-usage-type';

export class HostsCountDto {
  readonly [HostUsageType.Public]: number;
  readonly [HostUsageType.Private]: number;
  readonly [HostUsageType.Test]: number;
}
