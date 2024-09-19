create policy "All allowed to owners"
on "public"."services"
as permissive
for all
to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));