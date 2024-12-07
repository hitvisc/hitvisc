import { IsNotEmpty, Matches, MaxLength } from 'class-validator';
import { HostUsageType } from '../enums/host-usage-type';

export class UpdateHostDto {
  @IsNotEmpty()
  @Matches(/^[0-9a-zA-Zа-яА-ЯёË:-]+$/)
  @MaxLength(10)
  readonly name: string;

  @IsNotEmpty()
  readonly usageType: HostUsageType;
}
