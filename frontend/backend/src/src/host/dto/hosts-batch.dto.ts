import { HostDto } from './host.dto';

export class HostsBatchDto {
  readonly totalCount: number;
  readonly hosts: HostDto[];
}
