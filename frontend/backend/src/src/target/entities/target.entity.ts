import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { TypeOfUse } from '../../core/enums/type-of-use';
import { EntityState } from '../../core/enums/entity-state';

@Entity('front_target')
export class TargetEntity {
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
    enum: EntityState,
    default: EntityState.Preparing,
  })
  state: EntityState;

  @Column({
    type: 'enum',
    name: 'type_of_use',
    enum: TypeOfUse,
    default: TypeOfUse.Restricted,
  })
  typeOfUse: TypeOfUse;

  @Column({
    name: 'pdb_file_id',
    nullable: true,
  })
  pdbFileId: string | null;

  @Column({
    name: 'reference_ligands_file_id',
    nullable: true,
  })
  referenceLigandsFileId: string | null;

  @Column({
    name: 'created_by',
  })
  createdBy: number;

  constructor(partial: Partial<TargetEntity>) {
    Object.assign(this, partial);
  }
}
