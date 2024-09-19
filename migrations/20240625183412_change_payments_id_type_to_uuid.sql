BEGIN;

-- Add a new column for the UUID
ALTER TABLE "public"."payments" ADD COLUMN "new_id" uuid DEFAULT uuid_generate_v4();

-- Populate the new UUID column with generated UUIDs
UPDATE "public"."payments" SET "new_id" = uuid_generate_v4();

-- Drop the primary key constraint
ALTER TABLE "public"."payments" DROP CONSTRAINT "transactions_pkey";

-- Drop the existing index if it exists
DROP INDEX IF EXISTS "public"."transactions_pkey";

-- Remove the identity property from the old id column
ALTER TABLE "public"."payments" ALTER COLUMN "id" DROP IDENTITY;

-- Drop the old id column
ALTER TABLE "public"."payments" DROP COLUMN "id";

-- Rename the new_id column to id
ALTER TABLE "public"."payments" RENAME COLUMN "new_id" TO "id";

-- Create a unique index on the new id column
CREATE UNIQUE INDEX payments_pkey ON public.payments USING btree (id);

-- Add the primary key constraint using the new index
ALTER TABLE "public"."payments" ADD CONSTRAINT "payments_pkey" PRIMARY KEY USING INDEX "payments_pkey";

COMMIT;
