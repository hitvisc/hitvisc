import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('front_file_reference')
export class FileReferenceEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: false })
  name: string;

  @Column({ nullable: false })
  extension: string;

  @Column({
    name: 'mime_type',
    nullable: false,
  })
  mimeType: string;

  @Column({
    name: 'size_in_bytes',
  })
  sizeInBytes: number;

  @Column({
    name: 'directory_in_storage',
    nullable: false,
  })
  directoryInStorage: string;

  @Column({
    name: 'persistent',
    nullable: false,
  })
  isPersistent: boolean;

  @Column({
    name: 'owner_id',
    nullable: false,
  })
  ownerId: number;

  @CreateDateColumn({
    type: 'timestamp',
    name: 'created_at',
  })
  public createdAt: Date;

  @UpdateDateColumn({
    type: 'timestamp',
    name: 'updated_at',
    onUpdate: 'CURRENT_TIMESTAMP(6)',
  })
  public updatedAt: Date;

  constructor(partial: Partial<FileReferenceEntity>) {
    Object.assign(this, partial);
  }
}
