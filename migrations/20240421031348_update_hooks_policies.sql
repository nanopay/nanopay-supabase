drop policy "hooks_delete_policy" on "public"."hooks";

drop policy "hooks_read_policy" on "public"."hooks";

drop policy "hooks_update_policy" on "public"."hooks";

create policy "hooks_policy"
on "public"."hooks"
as permissive
for all
to authenticated
using ((EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = hooks.service_id)))))
with check ((EXISTS ( SELECT 1
   FROM services
  WHERE ((services.user_id = auth.uid()) AND (services.id = hooks.service_id)))));