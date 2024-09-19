drop policy "hooks_update_policy" on "public"."hooks";

create policy "hooks_update_policy"
on "public"."hooks"
as permissive
for update
to authenticated
using ((EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = hooks.service_id)))));
