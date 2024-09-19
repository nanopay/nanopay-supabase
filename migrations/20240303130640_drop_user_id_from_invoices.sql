drop policy "invoices_insert_policy" on "public"."invoices";

drop policy "invoices_read_policy" on "public"."invoices";

alter table "public"."invoices" drop constraint "invoices_user_id_fkey";

alter table "public"."invoices" drop column "user_id";

alter table "public"."invoices" alter column "service_id" set not null;

create policy "invoices_insert_policy"
on "public"."invoices"
as permissive
for insert
to authenticated
with check ((EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = invoices.service_id)))));


create policy "invoices_read_policy"
on "public"."invoices"
as permissive
for select
to authenticated
using ((EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = invoices.service_id)))));



