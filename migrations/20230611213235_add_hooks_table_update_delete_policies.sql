create policy "hooks_delete_policy"
on "public"."hooks"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = hooks.service_id)))));


create policy "hooks_update_policy"
on "public"."hooks"
as permissive
for update
to authenticated
using (false);




