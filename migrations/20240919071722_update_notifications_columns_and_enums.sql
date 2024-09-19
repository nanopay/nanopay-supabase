alter type "public"."notification_type" rename to "notification_type__old_version_to_be_dropped";

create type "public"."notification_type" as enum ('INVOICE_PAID', 'INVOICE_ERROR', 'INVOICE_EXPIRED', 'WEBHOOK_FAILURE');

alter table "public"."notifications_events" alter column type type "public"."notification_type" using type::text::"public"."notification_type";

drop type "public"."notification_type__old_version_to_be_dropped";

alter table "public"."notifications" add column "created_at" timestamp with time zone not null default (now() AT TIME ZONE 'utc'::text);

alter table "public"."notifications" add column "service_id" uuid not null;

alter table "public"."notifications_events" alter column "created_at" set default (now() AT TIME ZONE 'utc'::text);

alter table "public"."notifications" add constraint "notifications_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_service_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_notifications_from_events()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$BEGIN    
    INSERT INTO notifications (id, notification_event_id, service_id, user_id, created_at, read, archived)
    SELECT gen_random_uuid(), NEW.id, NEW.service_id, u.id, NEW.created_at, FALSE, FALSE
    FROM auth.users u
    JOIN services s ON s.user_id = u.id
    WHERE s.id = NEW.service_id;

    RETURN NEW;
END;$function$
;


