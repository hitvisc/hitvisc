import { Exclude } from 'class-transformer';
import { IsEmail } from 'class-validator';
import { BeforeInsert, Column, Entity, PrimaryColumn } from 'typeorm';
import { UserState } from '../enums/user-state';
import { hash } from '../services/hash';
import { getSequenceNextValue } from '../../core/utils/db';

/** Пользователь */
@Entity('user', { synchronize: false })
export class UserEntity {
  @PrimaryColumn({
    type: 'integer',
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
  })
  login: string;

  @Column({
    type: 'varchar',
    length: 64,
  })
  @IsEmail()
  email: string;

  @Column({
    type: 'varchar',
    length: 32,
    name: 'password_hash',
  })
  @Exclude()
  passwordHash: string;

  @Column({
    type: 'varchar',
    length: 64,
  })
  name: string;

  @Column({
    type: 'varchar',
    length: 256,
  })
  description: string;

  @Column({
    type: 'char',
    comment:
      'Состояние учётной записи пользователя: ' +
      'U - не заблокирован, можно изменять и удалять (unlocked); ' +
      'L - заблокирован - используется в поисках (locked); ' +
      'A - архивация, данные выносятся в архив (archived);' +
      'N - не подтвержден (new)',
  })
  state: UserState;

  @Column({
    type: 'integer',
    name: 'boinc_user_id',
    nullable: true,
  })
  @Exclude()
  boincUserId: number | null;

  @Column({
    type: 'varchar',
    length: 32,
    name: 'boinc_authenticator',
    nullable: true,
  })
  @Exclude()
  boincAuthenticator: string | null;

  @Column({
    type: 'varchar',
    length: 32,
    name: 'boinc_password',
    nullable: true,
  })
  @Exclude()
  boincPassword: string | null;

  /** Перед созданием пользователя хэширует его пароль */
  @BeforeInsert()
  hashPassword() {
    this.passwordHash = hash(this.passwordHash);
  }

  @BeforeInsert()
  async generateId() {
    // TODO: fix hardcoded schema
    this.id = await getSequenceNextValue('registry', 'seq_user_id');
  }

  /**
   * Создает пользователя из данных
   * @param partial данные для создания пользователя
   */
  constructor(partial: Partial<UserEntity>) {
    this.createdAt = new Date();
    this.state = UserState.New;
    Object.assign(this, partial);
  }
}
