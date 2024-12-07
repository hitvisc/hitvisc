import { BeforeInsert, Column, Entity, PrimaryColumn } from 'typeorm';
import { NotImplementedException } from '@nestjs/common';
import { HitviscSearchStatus } from '../enums/hitvisc-search-status';

@Entity('search', { synchronize: false })
export class HitviscSearchEntity {
  @PrimaryColumn({
    type: 'integer',
  })
  id: number;

  @Column({
    type: 'varchar',
    length: 64,
    name: 'system_name',
  })
  systemName: string | null;

  @Column({
    type: 'char',
    length: 1,
    name: 'status',
    comment: 'Статус поиска: A - активен, F - завершен',
  })
  status: HitviscSearchStatus;

  // описаны только поля, с которыми работаем
  // в базе набор полей шире
  @BeforeInsert()
  async preventFromInsertToDatabase() {
    throw new NotImplementedException('Search insert is not supported.');
  }

  constructor(partial: Partial<HitviscSearchEntity>) {
    Object.assign(this, partial);
  }
}
