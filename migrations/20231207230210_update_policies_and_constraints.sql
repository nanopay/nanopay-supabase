drop policy "All Allowed by authenticated user_id" on "public"."profiles";

alter table "public"."invoices" drop constraint "invoices_service_id_fkey";

alter table "public"."payments" drop constraint "payments_to_fkey";

alter table "public"."services" drop constraint "services_user_id_fkey";

alter table "public"."invoices" add constraint "invoices_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE not valid;

alter table "public"."invoices" validate constraint "invoices_service_id_fkey";

alter table "public"."payments" add constraint "payments_to_fkey" FOREIGN KEY ("to") REFERENCES invoices(pay_address) ON DELETE CASCADE not valid;

alter table "public"."payments" validate constraint "payments_to_fkey";

alter table "public"."services" add constraint "services_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."services" validate constraint "services_user_id_fkey";

create policy "All Allowed by authenticated user_id"
on "public"."profiles"
as permissive
for all
to authenticated
using ((auth.uid() = user_id));



