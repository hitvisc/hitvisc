import { singleton } from 'tsyringe';
import { AuthorizedClient } from '~/app-modules/core/clients/authorized-client';
import { HttpConnection } from '~/app-modules/core/clients/http-connection';
import { AuthService } from '~/app-modules/auth/services/auth.service';
import { HostUsageType } from '~/app-modules/resources/enums/HostUsageType';
import {
  HostsBatchDto,
  HostsBatchDtoSchema,
} from '~/app-modules/resources/clients/dto/hosts-batch.dto';
import { HostSortableColumn } from '~/app-modules/resources/enums/HostSortableColumn';
import {
  HostsCountDto,
  HostsCountDtoSchema,
} from '~/app-modules/resources/clients/dto/hosts-count.dto';
import { NewHostParamsDto, NewHostParamsDtoSchema } from '~/app-modules/resources/clients/dto/new-host-params.dto';

@singleton()
export class HostClient extends AuthorizedClient {
  constructor(http: HttpConnection, authService: AuthService) {
    super(http, authService);
  }

  /**
   *  Получение списка вычислительных узлов
   */
  async findHosts(
    skip: number,
    limit: number,
    usageType: HostUsageType,
    sortByColumn: HostSortableColumn,
    sortByOrder: -1 | 1,
    showInactive: boolean,
  ): Promise<HostsBatchDto> {
    return await this.executeRequest(
      {
        method: 'post',
        url: '/api/hosts/filter',
        data: {
          skip,
          limit,
          usageType,
          sortByColumn,
          sortByOrder,
          showInactive,
        },
      },
      HostsBatchDtoSchema,
    );
  }

  async getResourcesCount(): Promise<HostsCountDto> {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/hosts/count',
      },
      HostsCountDtoSchema,
    );
  }

  async updateHost(id: number, name: string, usageType: HostUsageType): Promise<void> {
    await this.executeRequest({
      method: 'put',
      url: `/api/hosts/${id}`,
      data: {
        name,
        usageType,
      },
    });
  }

  async getNewHostParams(): Promise<NewHostParamsDto> {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/hosts/new-host-params',
      },
      NewHostParamsDtoSchema,
    );
  }
}
