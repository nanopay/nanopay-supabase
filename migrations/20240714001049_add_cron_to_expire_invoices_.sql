set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_status_of_expired_invoices()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE invoices
    SET status = 'expired'
    WHERE expires_at < CURRENT_TIMESTAMP AND status = 'pending';
END;
$function$
;

SELECT cron.schedule('expires_invoices', '* * * * *', $$ SELECT update_status_of_expired_invoices() $$);