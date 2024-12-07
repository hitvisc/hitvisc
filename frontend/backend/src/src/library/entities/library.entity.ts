import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { EntityState } from '../../core/enums/entity-state';

@Entity('front_library')
export class LibraryEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ length: 2000 })
  description: string;

  @Column()
  authors: string;

  @Column()
  source: string;

  @Column({
    type: 'enum',
    name: 'type_of_use',
    enum: TypeOfUse,
    default: TypeOfUse.Restricted,
  })
  typeOfUse: TypeOfUse;

  @Column({
    type: 'enum',
    enum: EntityState,
    default: EntityState.Preparing,
  })
  state: EntityState;

  @Column({
    name: 'file_id',
    nullable: true,
  })
  fileId: string | null;

  @Column({
    name: 'created_by',
  })
  createdBy: number;

  constructor(partial: Partial<LibraryEntity>) {
    Object.assign(this, partial);
  }
}
