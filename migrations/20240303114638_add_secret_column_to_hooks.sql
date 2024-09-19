alter table "public"."hooks" add column "secret" text;

alter table "public"."hooks" add constraint "hooks_secret_check" CHECK ((length(secret) < 256)) not valid;

alter table "public"."hooks" validate constraint "hooks_secret_check";
