ALTER TABLE "public"."hook_deliveries" DROP COLUMN "id";

ALTER TABLE "public"."hook_deliveries" ADD COLUMN "id" uuid;

UPDATE "public"."hook_deliveries" SET "id" = uuid_generate_v4();

ALTER TABLE "public"."hook_deliveries" ADD PRIMARY KEY ("id");
