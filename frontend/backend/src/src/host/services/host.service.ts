import { FindOptionsWhere, MoreThan, Or, Repository } from 'typeorm';
import { HttpException, HttpStatus, Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { HostEntity } from '../entities/host.entity';
import { HostsFilterDto } from '../dto/hosts-filter.dto';
import { HostUsageType } from '../enums/host-usage-type';
import { HostsBatchDto } from '../dto/hosts-batch.dto';
import { UpdateHostDto } from '../dto/update-host.dto';
import { ConfigService } from '@nestjs/config';
import { ShellService } from '../../shell/services/shell.service';
import { NewHostParamsDto } from '../dto/new-host-params.dto';
import { UserService } from '../../user/services/user.service';

/** Сервис для управления вычислительными узлами */
@Injectable()
export class HostService {
  private readonly logger = new Logger(HostService.name);

  constructor(
    @InjectRepository(HostEntity)
    private readonly hostRepository: Repository<HostEntity>,
    private readonly userService: UserService,
    private readonly configService: ConfigService,
    private readonly shellService: ShellService,
  ) {}

  /**
   * Получение списка вычислительных узлов по фильтру
   * @returns список вычислительных узлов
   */
  async findHosts(
    userId: number,
    filterDto: HostsFilterDto,
  ): Promise<HostsBatchDto> {
    const filter: FindOptionsWhere<HostEntity> = {
      hostUsageType: filterDto.usageType,
    };

    /**
     * Частные вычислительные узлы не доступны для публичного просмотра. Отдаем только свои вычислительные узлы.
     */
    if (filterDto.usageType === HostUsageType.Private) {
      filter.userId = userId;
    }

    if (!filterDto.showInactive) {
      const sinceDate = new Date();
      sinceDate.setDate(sinceDate.getDate() - 10);
      filter.lastRequestAt = Or(null, MoreThan(sinceDate));
    }

    const totalCount = await this.hostRepository.countBy(filter);
    const hosts = await this.hostRepository.find({
      where: filter,
      skip: filterDto.skip,
      take: filterDto.limit,
      order: {
        [filterDto.sortByColumn]: filterDto.sortByOrder,
      },
    });

    return {
      totalCount,
      hosts: hosts.map((host) => ({
        id: host.id,
        name: host.name,
        lastRequestAt: host.lastRequestAt?.toISOString() ?? null,
        tasksInProgress: host.tasksInProgress,
        tasksCompleted: host.tasksCompleted,
        usageType: host.hostUsageType,
        userId: host.userId,
      })),
    };
  }

  async getHostsCount(userId: number) {
    const [publicHostsCount, privateHostsCount, testHostsCount] =
      await Promise.all([
        this.hostRepository.countBy({
          hostUsageType: HostUsageType.Public,
        }),
        this.hostRepository.countBy({
          hostUsageType: HostUsageType.Private,
          userId,
        }),
        this.hostRepository.countBy({
          hostUsageType: HostUsageType.Test,
        }),
      ]);
    return {
      [HostUsageType.Public]: publicHostsCount,
      [HostUsageType.Private]: privateHostsCount,
      [HostUsageType.Test]: testHostsCount,
    };
  }

  async updateHost(id: number, updateDto: UpdateHostDto, userId: number) {
    const host = await this.hostRepository.findOneBy({ id, userId });
    if (!host) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: `Host with id ${id} not found by user with id ${userId}`,
        },
        HttpStatus.NOT_FOUND,
      );
    }

    await this.hostRepository.update(
      {
        id,
        userId,
      },
      {
        name: updateDto.name,
      },
    );

    if (
      host.hostUsageType !== HostUsageType.Test &&
      host.hostUsageType !== updateDto.usageType
    ) {
      await this.updateHostType(host, updateDto.usageType);
    }
  }

  async updateHostType(host: HostEntity, usageType: HostUsageType) {
    const scriptPath = this.configService.get<string>(
      'UPDATE_HOST_TYPE_SCRIPT_PATH',
    );
    if (!scriptPath) {
      this.logger.error('update host type script path is not set');
    }
    const command = [scriptPath, host.id, usageType].join(' ');

    try {
      const { stdout, stderr } = await this.shellService.runShellCommand(
        command,
      );
      if (stderr) {
        this.logger.error('update host type stderr:', stderr);
        return false;
      } else {
        this.logger.log('update host type stdout:', stdout);
      }
    } catch (e) {
      this.logger.error('update host type error:', e);
      return false;
    }

    return true;
  }

  async getNewHostParams(userId: number): Promise<NewHostParamsDto> {
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new HttpException(
        {
          statusCode: HttpStatus.NOT_FOUND,
          message: `User with id ${userId} not found`,
        },
        HttpStatus.NOT_FOUND,
      );
    }

    return {
      email: user.email,
      password: user.boincPassword,
      projectUrl: this.configService.get<string>('BOINC_PROJECT_NEW_HOST_URL'),
    };
  }
}
