create policy "api_keys_delete_policy"
on "public"."api_keys"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = api_keys.service_id)))));



