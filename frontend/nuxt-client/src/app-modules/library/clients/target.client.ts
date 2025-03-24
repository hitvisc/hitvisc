import { AuthorizedClient } from '~/app-modules/core/clients/authorized-client';
import { HttpConnection } from '~/app-modules/core/clients/http-connection';
import { AuthService } from '~/app-modules/auth/services/auth.service';
import {
  CreateTargetDto,
  TargetCardDto,
  TargetCardDtoSchema,
  TargetDto,
} from '~/app-modules/library/clients/dto/target.dto';

@singleton()
export class TargetClient extends AuthorizedClient {
  constructor(http: HttpConnection, authService: AuthService) {
    super(http, authService);
  }

  async createTarget(data: CreateTargetDto): Promise<void> {
    return await this.executeRequest({
      method: 'post',
      url: '/api/target',
      data,
    });
  }

  async updateTarget(id: number, data: TargetDto): Promise<void> {
    await this.executeRequest({
      method: 'put',
      url: `/api/target/${id}`,
      data,
    });
  }

  async deleteTarget(id: number): Promise<void> {
    await this.executeRequest({
      method: 'delete',
      url: `/api/target/${id}`,
    });
  }

  async getTargets(): Promise<TargetCardDto[]> {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/target',
      },
      TargetCardDtoSchema.array(),
    );
  }

  async getSearchReadyTargets(): Promise<TargetCardDto[]> {
    return await this.executeRequest(
      {
        method: 'get',
        url: '/api/target/search/ready',
      },
      TargetCardDtoSchema.array(),
    );
  }

  async uploadPdbFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/target/files/pdb', file);
  }

  async uploadReferenceLigandFile(file: File): Promise<string> {
    return await this.uploadSingleFile('/api/target/files/reference-ligand', file);
  }
}
