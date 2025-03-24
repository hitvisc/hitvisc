import { z } from 'zod';
import { singleton } from 'tsyringe';
import { AuthorizedClient } from '~/app-modules/core/clients/authorized-client';
import { HttpConnection } from '~/app-modules/core/clients/http-connection';
import { AuthService } from '~/app-modules/auth/services/auth.service';
import {
  createSearchDto,
  SearchCardDto,
  SearchCardDtoSchema,
  UpdateSearchDto,
} from '~/app-modules/projects/clients/dto/search.dto';

@singleton()
export class SearchClient extends AuthorizedClient {
  constructor(http: HttpConnection, authService: AuthService) {
    super(http, authService);
  }

  async createSearch(data: createSearchDto): Promise<number> {
    return await this.executeRequest(
      {
        method: 'post',
        url: '/api/search',
        data,
      },
      z.number(),
    );
  }

  async updateSearch(id: number, data: UpdateSearchDto): Promise<void> {
    await this.executeRequest({
      method: 'put',
      url: `/api/search/${id}`,
      data,
    });
  }

  async deleteSearch(id: number): Promise<void> {
    await this.executeRequest({
      method: 'delete',
      url: `/api/search/${id}`,
    });
  }

  async getSearch(searchId: number): Promise<SearchCardDto> {
    return await this.executeRequest(
      {
        method: 'get',
        url: `/api/search/${searchId}`,
      },
      SearchCardDtoSchema,
    );
  }

  async getSearches(): Promise<SearchCardDto[]> {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/search',
      },
      SearchCardDtoSchema.array(),
    );
  }

  async isResultAvailable(searchId: number, type: string, userId?: number): Promise<boolean> {
    return await this.executeNotAuthorizedRequest(
      {
        method: 'get',
        url: `/api/search/${searchId}/results/hits/${type}/available?userId=${userId}`,
      },
      z.boolean(),
    );
  }

  async uploadAutoDockVinaProtocolFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/search/files/autodockvina/protocol', file);
  }

  async uploadCmDockReferenceLigandFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/search/files/cmdock/reference-ligand', file);
  }

  async uploadCmDockProtocolFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/search/files/cmdock/protocol', file);
  }

  async uploadCmDockSiteParamsFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/search/files/cmdock/site-parameters', file);
  }

  async uploadCmDockFilterParamsFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/search/files/cmdock/filter-parameters', file);
  }
}
