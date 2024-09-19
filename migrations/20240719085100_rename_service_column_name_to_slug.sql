alter table "public"."services" drop constraint "projects_name_key";

drop index if exists "public"."projects_name_key";

ALTER TABLE "public"."services" RENAME COLUMN "name" to "slug";

CREATE UNIQUE INDEX services_slug_key ON public.services USING btree (slug);

alter table "public"."services" add constraint "services_slug_key" UNIQUE using index "services_slug_key";


