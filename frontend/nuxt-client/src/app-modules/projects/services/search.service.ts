import { SearchClient } from '~/app-modules/projects/clients/search.client';
import { createSearchDto } from '~/app-modules/projects/clients/dto/search.dto';

@singleton()
export class SearchService {
  constructor(protected searchClient: SearchClient) {}

  async createSearch(dto: createSearchDto) {
    return await this.searchClient.createSearch(dto);
  }

  async getSearch(searchId: number) {
    return await this.searchClient.getSearch(searchId);
  }

  async getSearches() {
    return await this.searchClient.getSearches();
  }

  async uploadAutoDockVinaProtocolFile(file: File) {
    return await this.searchClient.uploadAutoDockVinaProtocolFile(file);
  }

  async uploadCmDockReferenceLigandFile(file: File) {
    return await this.searchClient.uploadCmDockReferenceLigandFile(file);
  }

  async uploadCmDockProtocolFile(file: File) {
    return await this.searchClient.uploadCmDockProtocolFile(file);
  }

  async uploadCmDockSiteParamsFile(file: File) {
    return await this.searchClient.uploadCmDockSiteParamsFile(file);
  }

  async uploadCmDockFilterParamsFile(file: File) {
    return await this.searchClient.uploadCmDockFilterParamsFile(file);
  }
}
