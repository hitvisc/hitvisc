import { AuthorizedClient } from '~/app-modules/core/clients/authorized-client';
import { HttpConnection } from '~/app-modules/core/clients/http-connection';
import { AuthService } from '~/app-modules/auth/services/auth.service';
import {
  createLibraryDto,
  LibraryCardDto,
  LibraryCardDtoSchema,
  LibraryDto,
} from '~/app-modules/library/clients/dto/library.dto';

@singleton()
export class LibraryClient extends AuthorizedClient {
  constructor(http: HttpConnection, authService: AuthService) {
    super(http, authService);
  }

  async createLibrary(data: createLibraryDto): Promise<void> {
    return await this.executeRequest({
      method: 'post',
      url: '/api/library',
      data,
    });
  }

  async updateLibrary(id: number, data: LibraryDto): Promise<void> {
    await this.executeRequest({
      method: 'put',
      url: `/api/library/${id}`,
      data,
    });
  }

  async deleteLibrary(id: number): Promise<void> {
    await this.executeRequest({
      method: 'delete',
      url: `/api/library/${id}`,
    });
  }

  async getLibraries(): Promise<LibraryCardDto[]> {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/library',
      },
      LibraryCardDtoSchema.array(),
    );
  }

  async getSearchReadyLibraries(): Promise<LibraryCardDto[]> {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/library/search/ready',
      },
      LibraryCardDtoSchema.array(),
    );
  }

  async uploadLibraryFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/library/files', file);
  }
}
