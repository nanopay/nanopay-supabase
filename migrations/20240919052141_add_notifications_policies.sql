revoke update on table "public"."notifications" from "authenticated";

alter table "public"."notifications" enable row level security;

alter table "public"."notifications_events" enable row level security;

create policy "notifications_read_policy"
on "public"."notifications"
as permissive
for select
to authenticated
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "notifications_update_policy"
on "public"."notifications"
as permissive
for update
to authenticated
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "notifications_events_read_policy"
on "public"."notifications_events"
as permissive
for select
to authenticated
using (is_service_owner(service_id));



