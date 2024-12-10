import { LibraryClient } from '~/app-modules/library/clients/library.client';
import { createLibraryDto } from '~/app-modules/library/clients/dto/library.dto';

@singleton()
export class LibraryService {
  constructor(protected libaryClient: LibraryClient) {}

  async createLibrary(dto: createLibraryDto) {
    return await this.libaryClient.createLibrary(dto);
  }

  async getLibraries() {
    return await this.libaryClient.getLibraries();
  }

  async getSearchReadyLibraries() {
    return await this.libaryClient.getSearchReadyLibraries();
  }

  async uploadLibraryFile(file: File) {
    return await this.libaryClient.uploadLibraryFile(file);
  }
}
