drop policy "api_keys_delete_policy" on "public"."api_keys";

drop policy "api_keys_read_policy" on "public"."api_keys";

drop policy "hook_deliveries_read_policy" on "public"."hook_deliveries";

drop policy "hooks_policy" on "public"."hooks";

drop policy "invoices_insert_policy" on "public"."invoices";

drop policy "invoices_read_policy" on "public"."invoices";

alter table "public"."payments" drop constraint "payments_to_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.is_hook_owner(hook_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM services
    JOIN hooks ON services.id = hooks.service_id
    WHERE services.user_id = auth.uid()
      AND hooks.id = hook_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_invoice_owner(invoice_id text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM services
    WHERE services.user_id = auth.uid()
      AND services.id = (SELECT service_id FROM invoices WHERE id = invoice_id)
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_invoice_owner(invoice_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
  service_user_id uuid;
BEGIN
  SELECT services.user_id INTO service_user_id
  FROM services
  JOIN invoices ON services.id = invoices.service_id
  WHERE invoices.id = invoice_id;

  RETURN service_user_id = auth.uid();
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_service_owner(service_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM services
    WHERE services.user_id = auth.uid()
      AND services.id = service_id
  );
END;
$function$
;

create policy "api_keys_insert_policy"
on "public"."api_keys"
as permissive
for insert
to authenticated
with check (is_service_owner(service_id));


create policy "payments_read_policy"
on "public"."payments"
as permissive
for select
to authenticated
using (is_invoice_owner(invoice_id));


create policy "api_keys_delete_policy"
on "public"."api_keys"
as permissive
for delete
to authenticated
using (is_service_owner(service_id));


create policy "api_keys_read_policy"
on "public"."api_keys"
as permissive
for select
to authenticated
using (is_service_owner(service_id));


create policy "hook_deliveries_read_policy"
on "public"."hook_deliveries"
as permissive
for select
to authenticated
using (is_hook_owner(hook_id));


create policy "hooks_policy"
on "public"."hooks"
as permissive
for all
to authenticated
using (is_service_owner(service_id))
with check (is_service_owner(service_id));


create policy "invoices_insert_policy"
on "public"."invoices"
as permissive
for insert
to authenticated
with check (is_service_owner(service_id));


create policy "invoices_read_policy"
on "public"."invoices"
as permissive
for select
to authenticated
using (is_invoice_owner(id));



