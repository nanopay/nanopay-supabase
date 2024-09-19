create policy "hook_deliveries_read_policy"
on "public"."hook_deliveries"
as permissive
for select
to authenticated
using ((EXISTS ( SELECT 1
   FROM (services
     JOIN hooks ON ((services.id = hooks.service_id)))
  WHERE ((services.user_id = auth.uid()) AND (hooks.id = hook_deliveries.hook_id)))));




