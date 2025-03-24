import { In, Repository } from 'typeorm';
import { join } from 'path';
import { InjectRepository } from '@nestjs/typeorm';
import { Injectable, Logger, NotFoundException, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FilesService } from '../../files/services/files.service';
import { CreateSearchDto } from '../dto/create-search.dto';
import { UpdateSearchDto } from '../dto/update-search.dto';
import { SearchEntity } from '../entities/search.entity';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { ShellService } from '../../shell/services/shell.service';
import { EntityState } from '../../core/enums/entity-state';
import { HitSelectionCriterion } from '../enums/hit-selection-criterion';
import { StoppingCriterion } from '../enums/stopping-criterion';
import { ApplicationId } from '../enums/application-id';
import { FileReferenceEntity } from '../../files/entities/file-reference.entity';
import { AutoDockVinaProtocolSource } from '../enums/auto-dock-vina-protocol-source';
import { CmDockProtocolSource } from '../enums/cm-dock-protocol-source';
import { mapBooleanToFlag } from '../../shell/util';
import { HitviscSearchEntity } from '../entities/hitvisc-search.entity';
import { EntityMappingService } from '../../entity-mapping/services/entity-mapping.service';
import { LibraryService } from '../../library/services/library.service';
import { TargetService } from '../../target/services/target.service';

const ONE_MEGABYTE = 1_000_000;

@Injectable()
export class SearchService {
  private readonly logger = new Logger(SearchService.name);

  constructor(
    @InjectRepository(SearchEntity)
    private readonly searchRepository: Repository<SearchEntity>,
    @InjectRepository(HitviscSearchEntity)
    private readonly hitviscSearchRepository: Repository<HitviscSearchEntity>,
    private readonly entityMappingService: EntityMappingService,
    private readonly configService: ConfigService,
    private readonly filesService: FilesService,
    private readonly shellService: ShellService,
    private readonly libraryService: LibraryService,
    private readonly targetService: TargetService,
  ) {}

  async uploadAutoDockVinaProtocolFile(
    file: Express.Multer.File,
    userId: number,
  ) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['txt', 'conf'],
      mimeTypes: [
        'text/plain',
        'text/*',
        'application/x-config',
        'application/octet-stream',
      ],
      maxSize: this.configService.get<number>('MAX_PRM_ADV') * ONE_MEGABYTE,
    });
  }

  async uploadCmDockReferenceLigandFile(
    file: Express.Multer.File,
    userId: number,
  ) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['sdf', 'sd'],
      mimeTypes: [
        'application/vnd.stardivision.math',
        'chemical/x-mdl-sdfile',
        'application/octet-stream',
      ],
      maxSize:
        Math.max(
          this.configService.get<number>('MAX_REF_LIG_SDF'),
          this.configService.get<number>('MAX_REF_LIG_SD'),
        ) * ONE_MEGABYTE,
    });
  }

  async uploadCmDockProtocolFile(file: Express.Multer.File, userId: number) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['prm'],
      mimeTypes: ['application/octet-stream'],
      maxSize: this.configService.get<number>('MAX_PRM_CMD') * ONE_MEGABYTE,
    });
  }

  async uploadCmDockSiteParamsFile(file: Express.Multer.File, userId: number) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['as'],
      mimeTypes: [
        'application/x-applix-spreadsheet',
        'application/octet-stream',
      ],
      maxSize: this.configService.get<number>('MAX_AS_CMD') * ONE_MEGABYTE,
    });
  }

  async uploadCmDockFilterParamsFile(
    file: Express.Multer.File,
    userId: number,
  ) {
    return await this.filesService.uploadTemporaryFile(file, userId, {
      extensions: ['ptc'],
      mimeTypes: ['application/octet-stream'],
      maxSize: this.configService.get<number>('MAX_PTC_CMD') * ONE_MEGABYTE,
    });
  }

  async createSearch(
    createSearchDto: CreateSearchDto,
    userId: number,
  ): Promise<SearchEntity> {
    const search = new SearchEntity({
      name: createSearchDto.name,
      typeOfUse: createSearchDto.typeOfUse,
      description: createSearchDto.description,
      targetId: createSearchDto.targetId,
      libraryId: createSearchDto.libraryId,
      applicationId: createSearchDto.applicationId,
      hitSelectionCriterion: createSearchDto.hitSelectionCriterion,
      hitSelectionValue: createSearchDto.hitSelectionValue,
      stoppingCriterion: createSearchDto.stoppingCriterion,
      stoppingValue: createSearchDto.stoppingValue,
      resourcesType: createSearchDto.resourcesType,
      createdBy: userId,
    });

    let autoDockVinaProtocolFileReference = null;
    if (createSearchDto.autoDockVinaParameters?.protocolFileId) {
      autoDockVinaProtocolFileReference =
        await this.filesService.getFileReferenceOrThrow(
          createSearchDto.autoDockVinaParameters.protocolFileId,
        );
      this.filesService.ensureFileReferenceIsOwnedBy(
        autoDockVinaProtocolFileReference,
        userId,
      );
    }

    let cmDockReferenceLigandFileReference = null;
    if (createSearchDto.cmDockParameters?.referenceLigandFileId) {
      cmDockReferenceLigandFileReference =
        await this.filesService.getFileReferenceOrThrow(
          createSearchDto.cmDockParameters.referenceLigandFileId,
        );
      this.filesService.ensureFileReferenceIsOwnedBy(
        cmDockReferenceLigandFileReference,
        userId,
      );
    }

    let cmDockProtocolFileReference = null;
    if (createSearchDto.cmDockParameters?.protocolFileId) {
      cmDockProtocolFileReference =
        await this.filesService.getFileReferenceOrThrow(
          createSearchDto.cmDockParameters.protocolFileId,
        );
      this.filesService.ensureFileReferenceIsOwnedBy(
        cmDockProtocolFileReference,
        userId,
      );
    }

    let cmDockSiteParamsFileReference = null;
    if (createSearchDto.cmDockParameters?.siteParamsFileId) {
      cmDockSiteParamsFileReference =
        await this.filesService.getFileReferenceOrThrow(
          createSearchDto.cmDockParameters.siteParamsFileId,
        );
      this.filesService.ensureFileReferenceIsOwnedBy(
        cmDockSiteParamsFileReference,
        userId,
      );
    }

    let cmDockFilterParamsFileReference = null;
    if (createSearchDto.cmDockParameters?.filterParamsFileId) {
      cmDockFilterParamsFileReference =
        await this.filesService.getFileReferenceOrThrow(
          createSearchDto.cmDockParameters.filterParamsFileId,
        );
      this.filesService.ensureFileReferenceIsOwnedBy(
        cmDockFilterParamsFileReference,
        userId,
      );
    }

    await this.searchRepository.save(search);

    const searchDirectory = `searches/${search.id}`;
    const searchPath = join(
      FilesService.getStorageDirectory(),
      searchDirectory,
    );
    FilesService.ensureDirectoryExists(searchPath);

    if (autoDockVinaProtocolFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        autoDockVinaProtocolFileReference,
        searchDirectory,
      );
    }

    if (cmDockReferenceLigandFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        cmDockReferenceLigandFileReference,
        searchDirectory,
      );
    }

    if (cmDockProtocolFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        cmDockProtocolFileReference,
        searchDirectory,
      );
    }

    if (cmDockSiteParamsFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        cmDockSiteParamsFileReference,
        searchDirectory,
      );
    }

    if (cmDockFilterParamsFileReference) {
      await this.filesService.moveUploadedFileToPersistentStorage(
        cmDockFilterParamsFileReference,
        searchDirectory,
      );
    }

    const ok = await this.runCreateSearchScript(
      search,
      searchPath,
      createSearchDto,
      autoDockVinaProtocolFileReference,
      cmDockReferenceLigandFileReference,
      cmDockProtocolFileReference,
      cmDockSiteParamsFileReference,
      cmDockFilterParamsFileReference,
    );
    search.state = ok ? EntityState.Ready : EntityState.Locked;
    await this.searchRepository.save(search);

    if (ok) {
      this.libraryService.updateLibraryState(search.libraryId, EntityState.InUse);
      this.targetService.updateTargetState(search.targetId, EntityState.InUse);
    }

    return search;
  }

  private async runCreateSearchScript(
    search: SearchEntity,
    searchPath: string,
    createSearchDto: CreateSearchDto,
    autoDockVinaProtocolFileReference: FileReferenceEntity,
    cmDockReferenceLigandFileReference: FileReferenceEntity,
    cmDockProtocolFileReference: FileReferenceEntity,
    cmDockSiteParamsFileReference: FileReferenceEntity,
    cmDockFilterParamsFileReference: FileReferenceEntity,
  ): Promise<boolean> {
    const scriptPath = this.configService.get<string>(
      'CREATE_SEARCH_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('create search script path is not set');
    }

    const dockerName = search.applicationId;

    const dockerParametersInput =
      (search.applicationId === ApplicationId.AutoDockVina &&
        createSearchDto.autoDockVinaParameters.inputType ===
          AutoDockVinaProtocolSource.File) ||
      (search.applicationId === ApplicationId.CmDock &&
        createSearchDto.cmDockParameters.inputType ===
          CmDockProtocolSource.File)
        ? 'F'
        : 'M';

    const dockerParametersFiles = `"${this.getApplicationParametersFiles(
      createSearchDto,
      autoDockVinaProtocolFileReference,
      cmDockProtocolFileReference,
      cmDockSiteParamsFileReference,
      cmDockFilterParamsFileReference,
    )}"`;

    const dockerParameters =
      {
        [ApplicationId.AutoDockVina]: () =>
          this.getAutoDockParameters(
            createSearchDto,
            autoDockVinaProtocolFileReference,
          ),
        [ApplicationId.CmDock]: () =>
          this.getCmDockParameters(
            createSearchDto,
            cmDockReferenceLigandFileReference,
            cmDockProtocolFileReference,
            cmDockSiteParamsFileReference,
            cmDockFilterParamsFileReference,
          ),
      }[search.applicationId as string]?.() ?? '"NULL"';

    const searchParameters = this.getSearchParameters(search, createSearchDto);

    const command = [
      scriptPath,
      searchPath,
      search.id,
      `"${search.name}"`,
      search.typeOfUse,
      `"${search.description}"`,
      search.targetId,
      search.libraryId,
      dockerName,
      dockerParametersInput,
      dockerParametersFiles,
      dockerParameters,
      searchParameters,
      search.resourcesType,
    ].join(' ');
    this.logger.debug('create search command:', command);

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('create search stderr:', stderr);
        return false;
      } else {
        this.logger.log('create search stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('create search error:', e);
      return false;
    }

    return true;
  }

  private getApplicationParametersFiles(
    createSearchDto: CreateSearchDto,
    autoDockVinaProtocolFileReference: FileReferenceEntity | null,
    cmDockProtocolFileReference: FileReferenceEntity | null,
    siteParamsFileReference: FileReferenceEntity | null,
    filterParamsFileReference: FileReferenceEntity | null,
  ): string {
    if (
      createSearchDto.applicationId === ApplicationId.AutoDockVina &&
      createSearchDto.autoDockVinaParameters.inputType ===
        AutoDockVinaProtocolSource.File
    ) {
      return this.filesService.getFileReferenceScriptParams(
        autoDockVinaProtocolFileReference,
      );
    }

    if (
      createSearchDto.applicationId === ApplicationId.CmDock &&
      createSearchDto.cmDockParameters.inputType === CmDockProtocolSource.File
    ) {
      return [
        this.filesService.getFileReferenceScriptParams(
          cmDockProtocolFileReference,
        ),
        this.filesService.getFileReferenceScriptParams(siteParamsFileReference),
        this.filesService.getFileReferenceScriptParams(
          filterParamsFileReference,
        ),
      ].join(' ');
    }

    return 'NULL';
  }

  private getAutoDockParameters(
    createSearchDto: CreateSearchDto,
    protocolFileReference: FileReferenceEntity | null,
  ): string {
    if (
      createSearchDto.autoDockVinaParameters.inputType ===
      AutoDockVinaProtocolSource.File
    ) {
      return '"NULL"';
    }

    const args = [
      createSearchDto.autoDockVinaParameters.centerX,
      createSearchDto.autoDockVinaParameters.centerY,
      createSearchDto.autoDockVinaParameters.centerZ,
      createSearchDto.autoDockVinaParameters.sizeX,
      createSearchDto.autoDockVinaParameters.sizeY,
      createSearchDto.autoDockVinaParameters.sizeZ,
      createSearchDto.autoDockVinaParameters.exhaustiveness,
      createSearchDto.autoDockVinaParameters.nmodes,
      createSearchDto.autoDockVinaParameters.erange,
    ].join(' ');

    return `"${args}"`;
  }

  private getCmDockParameters(
    createSearchDto: CreateSearchDto,
    referenceLigandFileReference: FileReferenceEntity | null,
    protocolFileReference: FileReferenceEntity | null,
    siteParamsFileReference: FileReferenceEntity | null,
    filterParamsFileReference: FileReferenceEntity | null,
  ): string {
    if (
      createSearchDto.cmDockParameters.inputType === CmDockProtocolSource.File
    ) {
      return '"NULL"';
    }

    if (
      createSearchDto.cmDockParameters.inputType ===
      CmDockProtocolSource.ManualLigand
    ) {
      const args = [
        createSearchDto.cmDockParameters.cavRadius,
        createSearchDto.cmDockParameters.smallSphereRadius,
        createSearchDto.cmDockParameters.maxCav,
        createSearchDto.cmDockParameters.minVol,
        createSearchDto.cmDockParameters.volInc,
        this.filesService.getFileReferenceScriptParams(
          referenceLigandFileReference,
        ),
      ].join(' ');

      return `"${args}"`;
    }

    const args = [
      createSearchDto.cmDockParameters.cavRadius,
      createSearchDto.cmDockParameters.smallSphereRadius,
      createSearchDto.cmDockParameters.maxCav,
      createSearchDto.cmDockParameters.minVol,
      createSearchDto.cmDockParameters.volInc,
      createSearchDto.cmDockParameters.centerX,
      createSearchDto.cmDockParameters.centerY,
      createSearchDto.cmDockParameters.centerZ,
      createSearchDto.cmDockParameters.largeSphereRadius,
      createSearchDto.cmDockParameters.step,
    ].join(' ');

    return `"${args}"`;
  }

  private getSearchParameters(
    search: SearchEntity,
    createSearchDto: CreateSearchDto,
  ): string {
    const hitSelectionCriterion =
      {
        [HitSelectionCriterion.BindingEnergy]: 'N',
        [HitSelectionCriterion.LigandEfficiency]: 'F',
      }[search.hitSelectionCriterion] ?? 'NULL';

    const bindingEnergyValue =
      search.hitSelectionCriterion === HitSelectionCriterion.BindingEnergy
        ? search.hitSelectionValue
        : 'NULL';
    const ligandEfficiencyValue =
      search.hitSelectionCriterion === HitSelectionCriterion.LigandEfficiency
        ? search.hitSelectionValue
        : 'NULL';

    const stoppingCriterion =
      {
        [StoppingCriterion.PercentOfCheckedLigands]: 'L',
        [StoppingCriterion.NumberOfFoundHits]: 'H',
        [StoppingCriterion.PercentOfHitsAmongLigands]: 'F',
      }[search.stoppingCriterion] ?? 'NULL';

    const percentOfCheckedLigands =
      search.stoppingCriterion === StoppingCriterion.PercentOfCheckedLigands
        ? search.stoppingValue / 100
        : 'NULL';
    const numberOfFoundHits =
      search.stoppingCriterion === StoppingCriterion.NumberOfFoundHits
        ? search.stoppingValue
        : 'NULL';
    const percentOfHitsAmongLigands =
      search.stoppingCriterion === StoppingCriterion.PercentOfHitsAmongLigands
        ? search.stoppingValue / 100
        : 'NULL';

    const completedLigandsPercent = createSearchDto.notifyMeCompletionOf
      ? createSearchDto.completedLigandsPercent / 100
      : 'NULL';

    const args = [
      hitSelectionCriterion,
      bindingEnergyValue,
      ligandEfficiencyValue,
      stoppingCriterion,
      percentOfCheckedLigands,
      numberOfFoundHits,
      percentOfHitsAmongLigands,
      mapBooleanToFlag(createSearchDto.notifyMeOfFoundHits),
      mapBooleanToFlag(createSearchDto.notifyMeCompletionOf),
      completedLigandsPercent,
    ].join(' ');

    return `"${args}"`;
  }

  async findSearch(
    searchId: number,
    userId: number,
  ): Promise<SearchEntity | null> {
    return await this.searchRepository.findOneBy([
      {
        id: searchId,
        typeOfUse: In([TypeOfUse.Private, TypeOfUse.Public]),
      },
      {
        id: searchId,
        createdBy: userId,
      },
    ]);
  }

  async findForUser(userId: number): Promise<SearchEntity[]> {
    return await this.searchRepository.find({
      where: [
        {
          typeOfUse: In([TypeOfUse.Private, TypeOfUse.Public]),
        },
        {
          createdBy: userId,
        },
      ],
      order: {
        id: -1,
      },
      take: 500,
    });
  }

  async getHitviscSearchByFrontId(frontSearchId: number) {
    const hitviscSearchId =
      await this.entityMappingService.getBackSearchIdByFrontSearchId(
        frontSearchId,
      );
    if (!hitviscSearchId) {
      return null;
    }

    return await this.getHitviscSearchById(hitviscSearchId);
  }

  async getHitviscSearchById(id: number) {
    return await this.hitviscSearchRepository.findOneBy({ id });
  }

  async getHitviscSearchesByIds(ids: number[]) {
    if (!ids.length) return [];

    return await this.hitviscSearchRepository.findBy({
      id: In(ids),
    });
  }

  async updateSearch(id: number, updateDto: UpdateSearchDto, userId: number) {
    const search = await this.searchRepository.findOneBy([
      {
        id,
        createdBy: userId,
      },
    ])
    if (!search) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: `Project with id ${id} not found`,
        },
        HttpStatus.NOT_FOUND,
      );
    }

    if (search.state !== EntityState.Ready) {
      throw new HttpException(
        {
          statusCode: HttpStatus.FORBIDDEN,
          message: `Project with id ${id} not allowed to update`,
        },
        HttpStatus.FORBIDDEN,
      );
    }

    const ok = await this.runUpdateSearchScript(
      search,
      updateDto,
    );

    if (ok) {
      search.name = updateDto.name;
      search.typeOfUse = updateDto.typeOfUse;
      search.description = updateDto.description;

      await this.searchRepository.save(search);
    } else {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: `Project with id ${id} not update`,
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  async runUpdateSearchScript(search: SearchEntity, updateDto: UpdateSearchDto) {
    const scriptPath = this.configService.get<string>(
      'UPDATE_SEARCH_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('update search script path is not set');
    }
    const command = [
      scriptPath,
      search.id,
      `"${updateDto.name}"`,
      updateDto.typeOfUse,
      `"${updateDto.description}"`,
    ].join(' ');
    this.logger.debug('update search command:', command);

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('update search stderr:', stderr);
        return false;
      } else {
        this.logger.log('update search stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('update search error:', e);
      return false;
    }

    return true;
  }

  async deleteSearch(id: number, userId: number) {
    const search = await this.searchRepository.findOneBy([
      {
        id,
        createdBy: userId,
      },
    ])
    if (!search) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: `Project with id ${id} not found`,
        },
        HttpStatus.NOT_FOUND,
      );
    }

    const ok = await this.runDeleteSearchScript(id);

    if (ok) {
      search.state = EntityState.Archived;
      await this.searchRepository.save(search);
    } else {
      throw new HttpException(
        {
          statusCode: HttpStatus.BAD_REQUEST,
          message: `Project with id ${id} not delete`,
        },
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  async runDeleteSearchScript(id: number) {
    const scriptPath = this.configService.get<string>(
      'DELETE_SEARCH_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('delete search script path is not set');
    }
    const command = [
      scriptPath,
      id,
    ].join(' ');
    this.logger.debug('delete search command:', command);

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('delete search stderr:', stderr);
        return false;
      } else {
        this.logger.log('delete search stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('delete search error:', e);
      return false;
    }

    return true;
  }
}
