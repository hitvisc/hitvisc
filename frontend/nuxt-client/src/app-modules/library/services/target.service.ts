import { TargetClient } from '~/app-modules/library/clients/target.client';
import { CreateTargetDto, TargetDto } from '~/app-modules/library/clients/dto/target.dto';

@singleton()
export class TargetService {
  constructor(protected targetClient: TargetClient) {}

  async createTarget(dto: CreateTargetDto) {
    return await this.targetClient.createTarget(dto);
  }

  async updateTarget(id: number, dto: TargetDto) {
    return await this.targetClient.updateTarget(id, dto);
  }

  async deleteTarget(id: number) {
    return await this.targetClient.deleteTarget(id);
  }

  async getTargets() {
    return await this.targetClient.getTargets();
  }

  async getSearchReadyTargets() {
    return await this.targetClient.getSearchReadyTargets();
  }

  async uploadPdbFile(file: File) {
    return await this.targetClient.uploadPdbFile(file);
  }

  async uploadReferenceLigandFile(file: File) {
    return await this.targetClient.uploadReferenceLigandFile(file);
  }
}
