create table "public"."settings" (
    "key" text not null,
    "value" jsonb not null,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."settings" enable row level security;

CREATE UNIQUE INDEX settings_pkey ON public.settings USING btree (key);

alter table "public"."settings" add constraint "settings_pkey" PRIMARY KEY using index "settings_pkey";

alter table "public"."settings" add constraint "jsonb_length" CHECK ((octet_length((value)::text) <= 1024)) not valid;

alter table "public"."settings" validate constraint "jsonb_length";

alter table "public"."settings" add constraint "key_length" CHECK ((char_length(key) <= 128)) not valid;

alter table "public"."settings" validate constraint "key_length";

alter table "public"."settings" add constraint "key_snake_case" CHECK ((key ~ '^[A-Z0-9_]+$'::text)) not valid;

alter table "public"."settings" validate constraint "key_snake_case";

grant delete on table "public"."settings" to "anon";

grant insert on table "public"."settings" to "anon";

grant references on table "public"."settings" to "anon";

grant select on table "public"."settings" to "anon";

grant trigger on table "public"."settings" to "anon";

grant truncate on table "public"."settings" to "anon";

grant update on table "public"."settings" to "anon";

grant delete on table "public"."settings" to "authenticated";

grant insert on table "public"."settings" to "authenticated";

grant references on table "public"."settings" to "authenticated";

grant select on table "public"."settings" to "authenticated";

grant trigger on table "public"."settings" to "authenticated";

grant truncate on table "public"."settings" to "authenticated";

grant update on table "public"."settings" to "authenticated";

grant delete on table "public"."settings" to "service_role";

grant insert on table "public"."settings" to "service_role";

grant references on table "public"."settings" to "service_role";

grant select on table "public"."settings" to "service_role";

grant trigger on table "public"."settings" to "service_role";

grant truncate on table "public"."settings" to "service_role";

grant update on table "public"."settings" to "service_role";


