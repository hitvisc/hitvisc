import {
  Body,
  ClassSerializerInterceptor,
  Controller,
  Get,
  HttpCode,
  Param,
  Post,
  Put,
  Request,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { HostService } from '../services/host.service';
import { AuthGuard } from '@nestjs/passport';
import { HostsFilterDto } from '../dto/hosts-filter.dto';
import { HostsBatchDto } from '../dto/hosts-batch.dto';
import { UpdateHostDto } from '../dto/update-host.dto';
import { HostsCountDto } from '../dto/hosts-count.dto';
import { NewHostParamsDto } from '../dto/new-host-params.dto';

/** Контроллер для пользователей */
@Controller('api/hosts')
export class HostController {
  /**
   * Подключает зависимости
   * @param hostService сервис для работы с вычислительными узлами
   */
  constructor(private hostService: HostService) {}

  /** Получает список вычислительных узлов по типу использования */
  @Post('filter')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async findByUsageType(
    @Request() req,
    @Body() filterDto: HostsFilterDto,
  ): Promise<HostsBatchDto> {
    return await this.hostService.findHosts(req.user.id, filterDto);
  }

  /** Получает количество вычислительных узлов по каждому типу использования */
  @Get('count')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async getHostsCountByUsageType(@Request() req): Promise<HostsCountDto> {
    return await this.hostService.getHostsCount(req.user.id);
  }

  @Put(':id')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async updateHost(
    @Request() req,
    @Param('id') id: number,
    @Body() updateDto: UpdateHostDto,
  ): Promise<void> {
    await this.hostService.updateHost(id, updateDto, req.user.id);
  }

  /** Возвращает параметры для подключения нового хоста */
  @Get('new-host-params')
  @HttpCode(200)
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(ClassSerializerInterceptor)
  async getNewHostParams(@Request() req): Promise<NewHostParamsDto> {
    return await this.hostService.getNewHostParams(req.user.id);
  }
}
