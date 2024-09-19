alter table "public"."services" add column "created_at" timestamp with time zone not null default now();

alter table "public"."services" add column "invoices_count" bigint not null default '0'::bigint;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.decrease_invoices_count()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$BEGIN
UPDATE services
SET invoices_count = invoices_count - 1
WHERE id = OLD.service_id;
RETURN NULL;
END;$$;

CREATE OR REPLACE FUNCTION public.increase_invoices_count()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$BEGIN
UPDATE services
SET invoices_count = invoices_count + 1
WHERE id = NEW.service_id;
RETURN NULL;
END;$$;

CREATE TRIGGER update_on_delete_invoice AFTER DELETE ON public.invoices FOR EACH ROW EXECUTE FUNCTION decrease_invoices_count();

CREATE TRIGGER update_on_insert_invoice AFTER INSERT ON public.invoices FOR EACH ROW EXECUTE FUNCTION increase_invoices_count();


