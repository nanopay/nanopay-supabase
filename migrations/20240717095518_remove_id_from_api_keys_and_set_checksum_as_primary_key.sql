alter table "public"."api_keys" drop constraint "api_keys_checksum_key";

alter table "public"."api_keys" drop constraint "api_keys_pkey";

drop index if exists "public"."api_keys_checksum_key";

drop index if exists "public"."api_keys_pkey";

alter table "public"."api_keys" drop column "id";

CREATE UNIQUE INDEX api_keys_pkey ON public.api_keys USING btree (checksum);

alter table "public"."api_keys" add constraint "api_keys_pkey" PRIMARY KEY using index "api_keys_pkey";


