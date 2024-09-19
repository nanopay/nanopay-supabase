set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_unique_pay_addresses()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check if pay_address already exists
    IF EXISTS (
        SELECT 1 FROM invoices 
        WHERE pay_address = NEW.pay_address 
        AND id != NEW.id
    ) THEN
        RAISE EXCEPTION 'pay_address already exists in another invoice';
    END IF;

    -- Check if recipient_address already exists
    IF EXISTS (
        SELECT 1 FROM invoices 
        WHERE pay_address = NEW.recipient_address 
        AND id != NEW.id
    ) THEN
        RAISE EXCEPTION 'recipient_address already exists as a pay_address in another invoice';
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE TRIGGER ensure_unique_pay_addresses_for_invoices BEFORE INSERT OR UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION check_unique_pay_addresses();


