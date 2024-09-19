set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_api_key_limit()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    max_keys INT;
    current_key_count INT;
BEGIN
    -- Retrieve the maximum allowed API keys per service from the settings table
    SELECT (value->>'max_api_keys_per_service')::INT INTO max_keys
    FROM settings
    WHERE key = 'MAX_API_KEYS_PER_SERVICE';

    -- Count the existing API keys for the given service_id
    SELECT COUNT(*) INTO current_key_count
    FROM api_keys
    WHERE service_id = NEW.service_id;

    -- Check if the current key count meets or exceeds the maximum allowed keys
    IF current_key_count >= max_keys THEN
        RAISE EXCEPTION 'The maximum number of API keys (%s) for service_id %s has been reached.', max_keys, NEW.service_id;
    END IF;

    -- Allow the insert if the limit is not reached
    RETURN NEW;
END;
$function$
;

grant execute on function "public"."check_api_key_limit" to "anon";

grant execute on function "public"."check_api_key_limit" to "authenticated";

grant execute on function "public"."check_api_key_limit" to "service_role";

CREATE TRIGGER api_key_insert_trigger BEFORE INSERT ON public.api_keys FOR EACH ROW EXECUTE FUNCTION check_api_key_limit();


