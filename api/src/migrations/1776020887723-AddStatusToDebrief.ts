import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddStatusToDebrief1776020887723 implements MigrationInterface {
  name = 'AddStatusToDebrief1776020887723';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "debriefs" ADD "status" character varying(10) NOT NULL DEFAULT 'draft'`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "debriefs" DROP COLUMN "status"`);
  }
}
