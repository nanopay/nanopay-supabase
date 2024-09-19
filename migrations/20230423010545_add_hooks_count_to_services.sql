
alter table "public"."services" add column "hooks_count" bigint not null default '0'::bigint;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.decrease_hooks_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE services
    SET hooks_count = hooks_count - 1
    WHERE id = OLD.service_id;
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.increase_hooks_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE services
    SET hooks_count = hooks_count + 1
    WHERE id = NEW.service_id;
    RETURN NULL;
END;
$$;

CREATE TRIGGER update_on_delete_hook AFTER DELETE ON public.hooks FOR EACH ROW EXECUTE FUNCTION decrease_hooks_count();

CREATE TRIGGER update_on_insert_hook AFTER INSERT ON public.hooks FOR EACH ROW EXECUTE FUNCTION increase_hooks_count();
