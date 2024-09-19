set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_invoices_limit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$DECLARE
    max_invoices INT;
    current_invoice_count INT;
BEGIN

    -- Retrieve the maximum allowed invoices per day per service from the settings table
    SELECT (value::JSONB)::INT INTO max_invoices
    FROM settings
    WHERE key = 'MAX_INVOICES_PER_DAY_PER_SERVICE';

    -- Count the existing invoices for the given service_id on the current day (UTC)
    SELECT COUNT(*) INTO current_invoice_count
    FROM invoices
    WHERE service_id = NEW.service_id
      AND created_at >= date_trunc('day', CURRENT_TIMESTAMP AT TIME ZONE 'UTC');

    -- Check if the current invoice count meets or exceeds the maximum allowed invoices
    IF current_invoice_count >= max_invoices THEN
        RAISE EXCEPTION 'The maximum number of invoices (%) for service_id (%) on this day has been reached.', max_invoices, NEW.service_id;
    END IF;

    -- Allow the insert if the limit is not reached
    RETURN NEW;
END;$function$
;

CREATE TRIGGER invoice_insert_trigger BEFORE INSERT ON public.invoices FOR EACH ROW EXECUTE FUNCTION check_invoices_limit();


