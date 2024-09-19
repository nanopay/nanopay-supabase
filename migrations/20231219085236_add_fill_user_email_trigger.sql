set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fill_user_email()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$BEGIN
  NEW.email = auth.email();
  return NEW;
END;$$;

grant execute on function "public"."fill_user_email" to "authenticated";

revoke execute on function "public"."fill_user_email" from "service_role";

revoke execute on function "public"."fill_user_email" from "anon";

CREATE TRIGGER fill_email_on_user_insert BEFORE INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION fill_user_email();