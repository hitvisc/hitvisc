import { createReadStream, existsSync, promises } from 'fs';
import { join } from 'path';
import { CreateSearchDto } from '../dto/create-search.dto';
import {
  BadRequestException,
  Body,
  ClassSerializerInterceptor,
  Controller,
  Get,
  HttpCode,
  NotFoundException,
  Param,
  Post,
  Query,
  Request,
  Res,
  StreamableFile,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import type { Response } from 'express';
import { UserService } from '../../user/services/user.service';
import { AuthGuard } from '@nestjs/passport';
import { SearchService } from '../services/search.service';
import { SearchEntity } from '../entities/search.entity';
import { SearchCardDto } from '../dto/search-card.dto';
import { TargetService } from '../../target/services/target.service';
import { LibraryService } from '../../library/services/library.service';
import { ConfigService } from '@nestjs/config';
import { FilesService } from '../../files/services/files.service';
import { FileInterceptor } from '@nestjs/platform-express';
import { EntityMappingService } from '../../entity-mapping/services/entity-mapping.service';
import { HitviscSearchStatus } from '../enums/hitvisc-search-status';

@Controller('api/search')
export class SearchController {
  private hitviscDataDir: string;

  constructor(
    configService: ConfigService,
    private userService: UserService,
    private entityMappingService: EntityMappingService,
    private searchService: SearchService,
    private targetService: TargetService,
    private libraryService: LibraryService,
  ) {
    this.hitviscDataDir = configService.get('HITVISC_DATA_DIR');
  }

  @Post('files/autodockvina/protocol')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadAutoDockVinaProtocolFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.searchService.uploadAutoDockVinaProtocolFile(
      file,
      req.user.id,
    );
  }

  @Post('files/cmdock/reference-ligand')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadCmDockReferenceLigandFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.searchService.uploadCmDockReferenceLigandFile(
      file,
      req.user.id,
    );
  }

  @Post('files/cmdock/protocol')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadCmDockProtocolFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.searchService.uploadCmDockProtocolFile(file, req.user.id);
  }

  @Post('files/cmdock/site-parameters')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadCmDockSiteParamsFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.searchService.uploadCmDockSiteParamsFile(
      file,
      req.user.id,
    );
  }

  @Post('files/cmdock/filter-parameters')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadCmDockFilterParamsFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.searchService.uploadCmDockFilterParamsFile(
      file,
      req.user.id,
    );
  }

  @Post()
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  async createSearch(
    @Body() createSearchRequest: CreateSearchDto,
    @Request() req,
  ) {
    const search = await this.searchService.createSearch(
      createSearchRequest,
      req.user.id,
    );
    return search.id;
  }

  @Get(':searchId/results/hits/:type')
  async downloadSearchResultsAllHits(
    @Res({ passthrough: true }) res: Response,
    @Param('searchId') searchId: number,
    @Param('type') type: string,
    @Query('userId') userId: number,
  ): Promise<StreamableFile> {
    if (!['all', 'div', 'viz'].includes(type)) {
      throw new NotFoundException(
        'Результаты проекта не доступны для скачивания. Пожалуйста, обратитесь к администратору системы.',
      );
    }

    const search = await this.searchService.findSearch(searchId, userId);
    if (!search) {
      throw new NotFoundException(
        'Результаты проекта не доступны для скачивания. Пожалуйста, обратитесь к администратору системы.',
      );
    }

    const hitviscSearch = await this.searchService.getHitviscSearchByFrontId(
      search.id,
    );
    if (!hitviscSearch) {
      throw new NotFoundException(
        'Результаты проекта не доступны для скачивания. Пожалуйста, обратитесь к администратору системы.',
      );
    }

    const searchSystemName = hitviscSearch.systemName;
    const filename = `hitvisc_hits_${type}.zip`;
    const resultFilePath = join(
      this.hitviscDataDir,
      `search/${searchSystemName}/hits/${type}`,
      filename,
    );
    if (!existsSync(resultFilePath)) {
      throw new NotFoundException(
        'Результаты проекта не доступны для скачивания. Пожалуйста, обратитесь к администратору системы.',
      );
    }

    const file = createReadStream(resultFilePath);
    const fileStats = await promises.stat(resultFilePath);
    return new StreamableFile(file, {
      type: 'application/zip',
      disposition: `attachment; filename="${filename}"`,
      length: fileStats.size,
    });
  }

  @Get(':searchId/results/hits/:type/available')
  async checkSearchResultsAllHits(
    @Param('searchId') searchId: number,
    @Param('type') type: string,
    @Query('userId') userId: number,
  ): Promise<boolean> {
    if (!['all', 'div', 'viz'].includes(type)) {
      throw new BadRequestException('Неизвестная группа результатов.');
    }

    const search = await this.searchService.findSearch(searchId, userId);
    if (!search) {
      throw new NotFoundException('Проект не найден.');
    }

    const hitviscSearch = await this.searchService.getHitviscSearchByFrontId(
      search.id,
    );
    if (!hitviscSearch) {
      throw new NotFoundException('Проект не найден.');
    }

    const searchSystemName = hitviscSearch.systemName;
    const filename = `hitvisc_hits_${type}.zip`;
    const resultFilePath = join(
      this.hitviscDataDir,
      `search/${searchSystemName}/hits/${type}`,
      filename,
    );

    return existsSync(resultFilePath);
  }

  @Get(':searchId')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findSearch(
    @Request() req,
    @Param('searchId') searchId: number,
  ): Promise<SearchCardDto> {
    const user = await this.userService.findByEmail(req.user.email);
    const search = await this.searchService.findSearch(searchId, user.id);
    if (!search) {
      throw new NotFoundException('Project not found');
    }

    const hitviscSearch = await this.searchService.getHitviscSearchByFrontId(
      search.id,
    );

    const target = await this.targetService.findById(search.targetId);
    const library = await this.libraryService.findById(search.libraryId);
    return {
      id: search.id,
      name: search.name,
      typeOfUse: search.typeOfUse,
      description: search.description,
      applicationId: search.applicationId,
      targetId: search.targetId,
      targetName: target?.name ?? search.targetId.toString(),
      libraryId: search.libraryId,
      libraryName: library?.name ?? search.libraryId.toString(),
      hitSelectionCriterion: search.hitSelectionCriterion,
      hitSelectionValue: search.hitSelectionValue,
      stoppingCriterion: search.stoppingCriterion,
      stoppingValue: search.stoppingValue,
      resourcesType: search.resourcesType,
      creatorId: search.createdBy,
      creatorName: user.name,
      state: search.state,
      isCompleted: hitviscSearch
        ? hitviscSearch.status === HitviscSearchStatus.Finished
        : false,
    };
  }

  @Get()
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findForUser(@Request() req): Promise<SearchCardDto[]> {
    const user = await this.userService.findByEmail(req.user.email);
    const searches = await this.searchService.findForUser(user.id);
    const userIds = new Set(searches.map((search) => search.createdBy));
    const users = await this.userService.findByIds([...userIds]);
    const userByIds = users.reduce((acc, user) => {
      acc[user.id] = user;
      return acc;
    }, {});
    const targetIds = new Set(searches.map((search) => search.targetId));
    const targets = await this.targetService.findByIds([...targetIds]);
    const targetByIds = targets.reduce((acc, target) => {
      acc[target.id] = target;
      return acc;
    }, {});
    const libraryIds = new Set(searches.map((search) => search.libraryId));
    const libraries = await this.libraryService.findByIds([...libraryIds]);
    const libraryByIds = libraries.reduce((acc, library) => {
      acc[library.id] = library;
      return acc;
    }, {});
    const searchMappings =
      await this.entityMappingService.getSearchMappingsByFrontIds(
        searches.map((search) => search.id),
      );
    const hitviscSearches = await this.searchService.getHitviscSearchesByIds(
      searchMappings.map((record) => record.backEntityId),
    );
    const hitviscSearchByIds = hitviscSearches.reduce((acc, hitviscSearch) => {
      acc[hitviscSearch.id] = hitviscSearch;
      return acc;
    }, {});
    const searchMappingByIds = searchMappings.reduce((acc, record) => {
      acc[record.frontEntityId] = record.backEntityId;
      return acc;
    }, {});
    return searches.map((search: SearchEntity) => ({
      id: search.id,
      name: search.name,
      typeOfUse: search.typeOfUse,
      description: search.description,
      applicationId: search.applicationId,
      targetId: search.targetId,
      targetName:
        targetByIds[search.targetId]?.name ?? search.targetId.toString(),
      libraryId: search.libraryId,
      libraryName:
        libraryByIds[search.libraryId]?.name ?? search.libraryId.toString(),
      hitSelectionCriterion: search.hitSelectionCriterion,
      hitSelectionValue: search.hitSelectionValue,
      stoppingCriterion: search.stoppingCriterion,
      stoppingValue: search.stoppingValue,
      resourcesType: search.resourcesType,
      creatorId: search.createdBy,
      creatorName:
        userByIds[search.createdBy]?.username ?? search.createdBy.toString(),
      state: search.state,
      isCompleted:
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        hitviscSearchByIds[searchMappingByIds[search.id]]?.status ===
          HitviscSearchStatus.Finished ?? false,
    }));
  }
}
