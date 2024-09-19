create table "public"."profiles" (
    "user_id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "avatar_url" text,
    "email" text not null,
    "name" text not null
);


alter table "public"."profiles" enable row level security;

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (user_id);

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."profiles" add constraint "profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_user_id_fkey";

create policy "All Allowed by authenticated user_id"
on "public"."profiles"
as permissive
for all
to public
using ((auth.uid() = user_id));



