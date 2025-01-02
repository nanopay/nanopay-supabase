drop policy "notifications_update_policy" on "public"."notifications";

create policy "notifications_update_policy"
on "public"."notifications"
as permissive
for update
to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



