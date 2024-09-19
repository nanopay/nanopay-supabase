create policy "invoices_insert_policy"
on "public"."invoices"
as permissive
for insert
to authenticated
with check (((auth.uid() = user_id) OR (EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = invoices.service_id))))));



