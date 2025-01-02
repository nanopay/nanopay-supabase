alter table "public"."notifications_events" drop constraint "notifications_events_service_id_fkey";

alter table "public"."notifications_events" add constraint "notifications_events_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."notifications_events" validate constraint "notifications_events_service_id_fkey";

create policy "notifications_delete_policy"
on "public"."notifications"
as permissive
for delete
to authenticated
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "notifications_events_delete_policy"
on "public"."notifications_events"
as permissive
for delete
to authenticated
using (is_service_owner(service_id));



