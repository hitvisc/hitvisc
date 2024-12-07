import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class UserEntityAddIsEmailConfirmed1691524538264
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn(
      'user',
      new TableColumn({
        name: 'isEmailConfirmed',
        type: 'boolean',
        default: false,
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropColumn('user', 'isEmailConfirmed');
  }
}
