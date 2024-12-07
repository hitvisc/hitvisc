import { FileInterceptor } from '@nestjs/platform-express';
import { CreateTargetDto } from '../dto/create-target.dto';
import {
  Body,
  ClassSerializerInterceptor,
  Controller,
  Get,
  HttpCode,
  Post,
  Request,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { UserService } from '../../user/services/user.service';
import { FilesService } from '../../files/services/files.service';
import { AuthGuard } from '@nestjs/passport';
import { TargetService } from '../services/target.service';
import { TargetEntity } from '../entities/target.entity';
import { TargetCardDto } from '../dto/target-card.dto';

@Controller('api/target')
export class TargetController {
  constructor(
    private userService: UserService,
    private targetService: TargetService,
  ) {}

  @Post('')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  async createTarget(
    @Body() createTargetRequest: CreateTargetDto,
    @Request() req,
  ) {
    const target = await this.targetService.createTarget(
      createTargetRequest,
      req.user.id,
    );
    return target.id;
  }

  @Post('files/pdb')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadPdbFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.targetService.uploadPdbFile(file, req.user.id);
  }

  @Post('files/reference-ligand')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('file', FilesService.getTemporaryFileMulterOptions()),
  )
  async uploadReferenceLigandFile(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return await this.targetService.uploadReferenceLigandFile(
      file,
      req.user.id,
    );
  }

  @Get()
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findForUser(@Request() req): Promise<TargetCardDto[]> {
    const user = await this.userService.findByEmail(req.user.email);
    const targets = await this.targetService.findForUser(user.id);
    const userIds = new Set(targets.map((target) => target.createdBy));
    const users = await this.userService.findByIds([...userIds]);
    const userByIds = users.reduce((acc, user) => {
      acc[user.id] = user;
      return acc;
    }, {});
    return targets.map((target: TargetEntity) => ({
      id: target.id,
      name: target.name,
      description: target.description,
      authors: target.authors,
      source: target.source,
      typeOfUse: target.typeOfUse,
      creatorId: target.createdBy,
      creatorName:
        userByIds[target.createdBy]?.username ?? target.createdBy.toString(),
      isFavourite: false,
      state: target.state,
    }));
  }

  @Get('search/ready')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findReadyForSearch(@Request() req): Promise<TargetCardDto[]> {
    const user = await this.userService.findByEmail(req.user.email);
    const targets = await this.targetService.findReadyForSearch(user.id);
    const userIds = new Set(targets.map((target) => target.createdBy));
    const users = await this.userService.findByIds([...userIds]);
    const userByIds = users.reduce((acc, user) => {
      acc[user.id] = user;
      return acc;
    }, {});
    return targets.map((target: TargetEntity) => ({
      id: target.id,
      name: target.name,
      description: target.description,
      authors: target.authors,
      source: target.source,
      typeOfUse: target.typeOfUse,
      creatorId: target.createdBy,
      creatorName:
        userByIds[target.createdBy]?.username ?? target.createdBy.toString(),
      isFavourite: false,
      state: target.state,
    }));
  }
}
