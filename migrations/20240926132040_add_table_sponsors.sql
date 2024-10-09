create table "public"."sponsors" (
    "created_at" timestamp with time zone not null default now(),
    "name" text not null,
    "avatar_url" text,
    "message" text,
    "amount" numeric not null,
    "invoice_id" text not null,
    "id" uuid not null default gen_random_uuid()
);


alter table "public"."sponsors" enable row level security;

CREATE UNIQUE INDEX sponsors_pkey ON public.sponsors USING btree (id);

alter table "public"."sponsors" add constraint "sponsors_pkey" PRIMARY KEY using index "sponsors_pkey";

alter table "public"."sponsors" add constraint "sponsors_invoice_id_fkey" FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."sponsors" validate constraint "sponsors_invoice_id_fkey";

grant delete on table "public"."sponsors" to "anon";

grant insert on table "public"."sponsors" to "anon";

grant references on table "public"."sponsors" to "anon";

grant select on table "public"."sponsors" to "anon";

grant trigger on table "public"."sponsors" to "anon";

grant truncate on table "public"."sponsors" to "anon";

grant update on table "public"."sponsors" to "anon";

grant delete on table "public"."sponsors" to "authenticated";

grant insert on table "public"."sponsors" to "authenticated";

grant references on table "public"."sponsors" to "authenticated";

grant select on table "public"."sponsors" to "authenticated";

grant trigger on table "public"."sponsors" to "authenticated";

grant truncate on table "public"."sponsors" to "authenticated";

grant update on table "public"."sponsors" to "authenticated";

grant delete on table "public"."sponsors" to "service_role";

grant insert on table "public"."sponsors" to "service_role";

grant references on table "public"."sponsors" to "service_role";

grant select on table "public"."sponsors" to "service_role";

grant trigger on table "public"."sponsors" to "service_role";

grant truncate on table "public"."sponsors" to "service_role";

grant update on table "public"."sponsors" to "service_role";


