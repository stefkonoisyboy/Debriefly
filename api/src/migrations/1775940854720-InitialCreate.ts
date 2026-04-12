import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialCreate1775940854720 implements MigrationInterface {
  name = 'InitialCreate1775940854720';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "debriefs" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "clientName" character varying(255) NOT NULL, "meetingDate" date NOT NULL, "participants" text, "summary" text, "decisionsMade" text, "actionItems" jsonb NOT NULL DEFAULT '[]', "risksConcerns" text, "createdBy" character varying(255) NOT NULL, "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), CONSTRAINT "PK_19724c5ab009dd0bae12eb718f2" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_3fbd0571920ee1d7aa427cbb52" ON "debriefs" ("clientName") `,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_5971ee24819a1c583aee484f28" ON "debriefs" ("meetingDate") `,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_3e0457785a6200bf5a019a4ba1" ON "debriefs" ("createdBy") `,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX "public"."IDX_3e0457785a6200bf5a019a4ba1"`,
    );
    await queryRunner.query(
      `DROP INDEX "public"."IDX_5971ee24819a1c583aee484f28"`,
    );
    await queryRunner.query(
      `DROP INDEX "public"."IDX_3fbd0571920ee1d7aa427cbb52"`,
    );
    await queryRunner.query(`DROP TABLE "debriefs"`);
  }
}
