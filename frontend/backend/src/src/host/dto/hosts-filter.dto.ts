import { IsNotEmpty, Max } from 'class-validator';
import { HostUsageType } from '../enums/host-usage-type';
import { HostSortableColumn } from '../enums/host-sortable-column';

export class HostsFilterDto {
  @IsNotEmpty()
  readonly usageType: HostUsageType;

  @IsNotEmpty()
  readonly skip: number;

  @IsNotEmpty()
  @Max(100)
  readonly limit: number;

  @IsNotEmpty()
  readonly sortByColumn: HostSortableColumn;

  @IsNotEmpty()
  readonly sortByOrder: 1 | -1;

  @IsNotEmpty()
  readonly showInactive: boolean;
}
