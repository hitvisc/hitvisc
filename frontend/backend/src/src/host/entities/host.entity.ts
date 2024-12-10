import { BeforeInsert, Column, Entity, PrimaryColumn } from 'typeorm';
import { HostUsageType } from '../enums/host-usage-type';
import { getSequenceNextValue } from '../../core/utils/db';

@Entity('host', { synchronize: false })
export class HostEntity {
  @PrimaryColumn({
    type: 'int4',
  })
  id: number;

  @Column({
    type: 'timestamp',
    name: 'create_time',
  })
  createdAt: Date;

  @Column({
    type: 'varchar',
    length: 64,
    nullable: true,
  })
  name: string;

  @Column({
    type: 'int4',
    name: 'user_id',
  })
  userId: number;

  @Column({
    type: 'int4',
    name: 'boinc_host_id',
  })
  boincHostId: number;

  @Column({
    type: 'char',
    length: 1,
    comment:
      'Тип вычислительного ресурса: ' +
      'T - тестовый (test); ' +
      'R - частный (private); ' +
      'P - общий (public)',
    name: 'host_usage_type',
  })
  hostUsageType: HostUsageType;

  @Column({
    type: 'int4',
    name: 'tasks_progress',
  })
  tasksInProgress: number;

  @Column({
    type: 'int4',
    name: 'tasks_completed',
  })
  tasksCompleted: number;

  @Column({
    type: 'timestamp',
    name: 'last_request_time',
    nullable: true,
  })
  lastRequestAt: Date;

  @BeforeInsert()
  async generateId() {
    // TODO: fix hardcoded schema
    this.id = await getSequenceNextValue('registry', 'seq_host_id');
  }

  /**
   * Создает host из данных
   * @param partial данные для создания host
   */
  constructor(partial: Partial<HostEntity>) {
    this.createdAt = new Date();
    Object.assign(this, partial);
  }
}
