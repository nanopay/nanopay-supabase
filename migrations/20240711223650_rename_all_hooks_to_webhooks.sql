drop trigger if exists "update_on_delete_hook" on "public"."hooks";

drop trigger if exists "update_on_insert_hook" on "public"."hooks";

drop policy "hook_deliveries_read_policy" on "public"."hook_deliveries";

drop policy "hooks_policy" on "public"."hooks";

revoke delete on table "public"."hook_deliveries" from "anon";

revoke insert on table "public"."hook_deliveries" from "anon";

revoke references on table "public"."hook_deliveries" from "anon";

revoke select on table "public"."hook_deliveries" from "anon";

revoke trigger on table "public"."hook_deliveries" from "anon";

revoke truncate on table "public"."hook_deliveries" from "anon";

revoke update on table "public"."hook_deliveries" from "anon";

revoke delete on table "public"."hook_deliveries" from "authenticated";

revoke insert on table "public"."hook_deliveries" from "authenticated";

revoke references on table "public"."hook_deliveries" from "authenticated";

revoke select on table "public"."hook_deliveries" from "authenticated";

revoke trigger on table "public"."hook_deliveries" from "authenticated";

revoke truncate on table "public"."hook_deliveries" from "authenticated";

revoke update on table "public"."hook_deliveries" from "authenticated";

revoke delete on table "public"."hook_deliveries" from "service_role";

revoke insert on table "public"."hook_deliveries" from "service_role";

revoke references on table "public"."hook_deliveries" from "service_role";

revoke select on table "public"."hook_deliveries" from "service_role";

revoke trigger on table "public"."hook_deliveries" from "service_role";

revoke truncate on table "public"."hook_deliveries" from "service_role";

revoke update on table "public"."hook_deliveries" from "service_role";

revoke delete on table "public"."hooks" from "anon";

revoke insert on table "public"."hooks" from "anon";

revoke references on table "public"."hooks" from "anon";

revoke select on table "public"."hooks" from "anon";

revoke trigger on table "public"."hooks" from "anon";

revoke truncate on table "public"."hooks" from "anon";

revoke update on table "public"."hooks" from "anon";

revoke delete on table "public"."hooks" from "authenticated";

revoke insert on table "public"."hooks" from "authenticated";

revoke references on table "public"."hooks" from "authenticated";

revoke select on table "public"."hooks" from "authenticated";

revoke trigger on table "public"."hooks" from "authenticated";

revoke truncate on table "public"."hooks" from "authenticated";

revoke update on table "public"."hooks" from "authenticated";

revoke delete on table "public"."hooks" from "service_role";

revoke insert on table "public"."hooks" from "service_role";

revoke references on table "public"."hooks" from "service_role";

revoke select on table "public"."hooks" from "service_role";

revoke trigger on table "public"."hooks" from "service_role";

revoke truncate on table "public"."hooks" from "service_role";

revoke update on table "public"."hooks" from "service_role";

alter table "public"."hook_deliveries" drop constraint "hook_deliveries_hook_id_fkey";

alter table "public"."hooks" drop constraint "hooks_secret_check";

alter table "public"."hooks" drop constraint "hooks_service_id_fkey";

drop function if exists "public"."decrease_hooks_count"();

drop function if exists "public"."increase_hooks_count"();

drop function if exists "public"."is_hook_owner"(hook_id uuid);

alter table "public"."hook_deliveries" drop constraint "hook_deliveries_pkey";

alter table "public"."hooks" drop constraint "hooks_pkey";

drop index if exists "public"."hook_deliveries_pkey";

drop index if exists "public"."hooks_pkey";

drop table "public"."hook_deliveries";

drop table "public"."hooks";

create table "public"."webhooks" (
    "id" uuid not null default uuid_generate_v4(),
    "created_at" timestamp with time zone not null default now(),
    "url" text not null,
    "event_types" text[] not null,
    "service_id" uuid not null,
    "name" text not null,
    "description" text,
    "active" boolean not null default true,
    "secret" text
);


alter table "public"."webhooks" enable row level security;

create table "public"."webhooks_deliveries" (
    "created_at" timestamp with time zone not null default now(),
    "status_code" smallint not null,
    "started_at" timestamp with time zone not null,
    "completed_at" timestamp with time zone not null,
    "redelivery" boolean not null default false,
    "request_body" jsonb not null,
    "success" boolean not null,
    "url" text not null,
    "request_headers" jsonb not null,
    "response_headers" jsonb not null,
    "type" text not null,
    "webhook_id" uuid not null,
    "response_body" text,
    "id" uuid not null
);


alter table "public"."webhooks_deliveries" enable row level security;

alter table "public"."services" drop column "hooks_count";

alter table "public"."services" add column "webhooks_count" bigint not null default '0'::bigint;

CREATE UNIQUE INDEX hook_deliveries_pkey ON public.webhooks_deliveries USING btree (id);

CREATE UNIQUE INDEX hooks_pkey ON public.webhooks USING btree (id);

alter table "public"."webhooks" add constraint "hooks_pkey" PRIMARY KEY using index "hooks_pkey";

alter table "public"."webhooks_deliveries" add constraint "hook_deliveries_pkey" PRIMARY KEY using index "hook_deliveries_pkey";

alter table "public"."webhooks" add constraint "hooks_secret_check" CHECK ((length(secret) < 256)) not valid;

alter table "public"."webhooks" validate constraint "hooks_secret_check";

alter table "public"."webhooks" add constraint "hooks_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE not valid;

alter table "public"."webhooks" validate constraint "hooks_service_id_fkey";

alter table "public"."webhooks_deliveries" add constraint "webhook_deliveries_webhook_id_fkey" FOREIGN KEY (webhook_id) REFERENCES webhooks(id) ON DELETE CASCADE not valid;

alter table "public"."webhooks_deliveries" validate constraint "webhook_deliveries_webhook_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.decrease_webhooks_count()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$BEGIN
    UPDATE services
    SET webhooks_count = webhooks_count - 1
    WHERE id = OLD.service_id;
    RETURN NULL;
END;$function$
;

CREATE OR REPLACE FUNCTION public.increase_webhooks_count()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$BEGIN
    UPDATE services
    SET webhooks_count = webhooks_count + 1
    WHERE id = NEW.service_id;
    RETURN NULL;
END;$function$
;

CREATE OR REPLACE FUNCTION public.is_webhook_owner(webhook_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM services
    JOIN webhooks ON services.id = webhooks.service_id
    WHERE services.user_id = auth.uid()
      AND webhooks.id = webhook_id
  );
END;$function$
;

grant delete on table "public"."webhooks" to "anon";

grant insert on table "public"."webhooks" to "anon";

grant references on table "public"."webhooks" to "anon";

grant select on table "public"."webhooks" to "anon";

grant trigger on table "public"."webhooks" to "anon";

grant truncate on table "public"."webhooks" to "anon";

grant update on table "public"."webhooks" to "anon";

grant delete on table "public"."webhooks" to "authenticated";

grant insert on table "public"."webhooks" to "authenticated";

grant references on table "public"."webhooks" to "authenticated";

grant select on table "public"."webhooks" to "authenticated";

grant trigger on table "public"."webhooks" to "authenticated";

grant truncate on table "public"."webhooks" to "authenticated";

grant update on table "public"."webhooks" to "authenticated";

grant delete on table "public"."webhooks" to "service_role";

grant insert on table "public"."webhooks" to "service_role";

grant references on table "public"."webhooks" to "service_role";

grant select on table "public"."webhooks" to "service_role";

grant trigger on table "public"."webhooks" to "service_role";

grant truncate on table "public"."webhooks" to "service_role";

grant update on table "public"."webhooks" to "service_role";

grant delete on table "public"."webhooks_deliveries" to "anon";

grant insert on table "public"."webhooks_deliveries" to "anon";

grant references on table "public"."webhooks_deliveries" to "anon";

grant select on table "public"."webhooks_deliveries" to "anon";

grant trigger on table "public"."webhooks_deliveries" to "anon";

grant truncate on table "public"."webhooks_deliveries" to "anon";

grant update on table "public"."webhooks_deliveries" to "anon";

grant delete on table "public"."webhooks_deliveries" to "authenticated";

grant insert on table "public"."webhooks_deliveries" to "authenticated";

grant references on table "public"."webhooks_deliveries" to "authenticated";

grant select on table "public"."webhooks_deliveries" to "authenticated";

grant trigger on table "public"."webhooks_deliveries" to "authenticated";

grant truncate on table "public"."webhooks_deliveries" to "authenticated";

grant update on table "public"."webhooks_deliveries" to "authenticated";

grant delete on table "public"."webhooks_deliveries" to "service_role";

grant insert on table "public"."webhooks_deliveries" to "service_role";

grant references on table "public"."webhooks_deliveries" to "service_role";

grant select on table "public"."webhooks_deliveries" to "service_role";

grant trigger on table "public"."webhooks_deliveries" to "service_role";

grant truncate on table "public"."webhooks_deliveries" to "service_role";

grant update on table "public"."webhooks_deliveries" to "service_role";

create policy "webhooks_policy"
on "public"."webhooks"
as permissive
for all
to authenticated
using (is_service_owner(service_id))
with check (is_service_owner(service_id));


create policy "webhooks_deliveries_hooks_policy"
on "public"."webhooks_deliveries"
as permissive
for select
to authenticated
using (is_webhook_owner(webhook_id));


CREATE TRIGGER update_on_delete_hook AFTER DELETE ON public.webhooks FOR EACH ROW EXECUTE FUNCTION decrease_webhooks_count();

CREATE TRIGGER update_on_insert_hook AFTER INSERT ON public.webhooks FOR EACH ROW EXECUTE FUNCTION increase_webhooks_count();


