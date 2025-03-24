import { FileInterceptor } from '@nestjs/platform-express';
import { CreateLibraryDto } from '../dto/create-library.dto';
import {
  Body,
  ClassSerializerInterceptor,
  Controller,
  Delete,
  Get,
  HttpCode,
  Post,
  Param,
  Put,
  Request,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { UserService } from '../../user/services/user.service';
import { FilesService } from '../../files/services/files.service';
import { AuthGuard } from '@nestjs/passport';
import { LibraryService } from '../services/library.service';
import { LibraryEntity } from '../entities/library.entity';
import { LibraryCardDto } from '../dto/library-card.dto';
import { UpdateLibraryDto } from '../dto/update-library.dto';

@Controller('api/library')
export class LibraryController {
  constructor(
    private userService: UserService,
    private libraryService: LibraryService,
  ) {}

  @Post('')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  async createLibrary(
    @Body() createLibraryRequest: CreateLibraryDto,
    @Request() req,
  ) {
    const library = await this.libraryService.createLibrary(
      createLibraryRequest,
      req.user.id,
    );
    return library.id;
  }


  @Put(':id')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async updateLibrary(
    @Param('id') id: number,
    @Body() updateDto: UpdateLibraryDto,
  ): Promise<void> {
    await this.libraryService.updateLibrary(id, updateDto);
  }

  @Delete(':id')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async deleteLibrary(
    @Param('id') id: number,
  ): Promise<void> {
    await this.libraryService.deleteLibrary(id);
  }

  @Post('files')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadLibraryFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.libraryService.uploadLibraryFile(file, req.user.id);
  }

  @Get()
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findForUser(@Request() req): Promise<LibraryCardDto[]> {
    const libraries = await this.libraryService.findForUser(req.user.id);
    const userIds = new Set(libraries.map((ligand) => ligand.createdBy));
    const users = await this.userService.findByIds([...userIds]);
    const userByIds = users.reduce((acc, user) => {
      acc[user.id] = user;
      return acc;
    }, {});
    return libraries.map((library: LibraryEntity) => ({
      id: library.id,
      name: library.name,
      description: library.description,
      authors: library.authors,
      source: library.source,
      typeOfUse: library.typeOfUse,
      creatorId: library.createdBy,
      creatorName:
        userByIds[library.createdBy]?.username ?? library.createdBy.toString(),
      isFavourite: false,
      state: library.state,
    }));
  }

  @Get('search/ready')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findReadyForSearch(@Request() req): Promise<LibraryCardDto[]> {
    const libraries = await this.libraryService.findReadyForSearch(req.user.id);
    const userIds = new Set(libraries.map((ligand) => ligand.createdBy));
    const users = await this.userService.findByIds([...userIds]);
    const userByIds = users.reduce((acc, user) => {
      acc[user.id] = user;
      return acc;
    }, {});
    return libraries.map((library: LibraryEntity) => ({
      id: library.id,
      name: library.name,
      description: library.description,
      authors: library.authors,
      source: library.source,
      typeOfUse: library.typeOfUse,
      creatorId: library.createdBy,
      creatorName:
        userByIds[library.createdBy]?.username ?? library.createdBy.toString(),
      isFavourite: false,
      state: library.state,
    }));
  }
}
