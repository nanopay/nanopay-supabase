create type "public"."notification_type" as enum ('INVOICE_PAID', 'INVOICE_ERROR', 'INVOICE_EXPIRED', 'INVOICE_PAID_PARTIALLY', 'WEBHOOK_FAILURE');

drop trigger if exists "update_on_received_amount" on "public"."invoices";

drop function if exists "public"."update_invoice_status"();

create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "notification_event_id" uuid not null,
    "user_id" uuid not null,
    "read" boolean not null default false,
    "archived" boolean not null default false
);


create table "public"."notifications_events" (
    "id" uuid not null,
    "service_id" uuid not null,
    "type" notification_type not null,
    "created_at" timestamp with time zone not null default now(),
    "invoice_id" text,
    "webhook_delivery_id" uuid
);


CREATE UNIQUE INDEX notifications_events_pkey ON public.notifications_events USING btree (id);

CREATE UNIQUE INDEX notifications_notification_event_id_user_id_key ON public.notifications USING btree (notification_event_id, user_id);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."notifications_events" add constraint "notifications_events_pkey" PRIMARY KEY using index "notifications_events_pkey";

alter table "public"."notifications" add constraint "notifications_notification_event_id_fkey" FOREIGN KEY (notification_event_id) REFERENCES notifications_events(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_notification_event_id_fkey";

alter table "public"."notifications" add constraint "notifications_notification_event_id_user_id_key" UNIQUE using index "notifications_notification_event_id_user_id_key";

alter table "public"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_user_id_fkey";

alter table "public"."notifications_events" add constraint "notifications_events_invoice_id_fkey" FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."notifications_events" validate constraint "notifications_events_invoice_id_fkey";

alter table "public"."notifications_events" add constraint "notifications_events_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) not valid;

alter table "public"."notifications_events" validate constraint "notifications_events_service_id_fkey";

alter table "public"."notifications_events" add constraint "notifications_events_webhook_delivery_id_fkey" FOREIGN KEY (webhook_delivery_id) REFERENCES webhooks_deliveries(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."notifications_events" validate constraint "notifications_events_webhook_delivery_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_notifications_from_events()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$BEGIN    
    INSERT INTO notifications (id, notification_event_id, user_id, read, archived)
    SELECT gen_random_uuid(), NEW.id, u.id, FALSE, FALSE
    FROM auth.users u
    JOIN services s ON s.user_id = u.id
    WHERE s.id = NEW.service_id;

    RETURN NEW;
END;$function$
;

CREATE OR REPLACE FUNCTION public.handle_invoice_status()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$BEGIN
    IF NEW.received_amount >= NEW.price THEN
      NEW.status = 'paid';
    END IF;

    -- Check for status change to 'paid'
    IF OLD.status IS DISTINCT FROM 'paid' AND NEW.status = 'paid' THEN
        INSERT INTO notifications_events (id, type, created_at, invoice_id, service_id)
        VALUES (gen_random_uuid(), 'INVOICE_PAID', now(), NEW.id, NEW.service_id);
    END IF;

    -- Check for status change to 'expired'
    IF OLD.status IS DISTINCT FROM 'expired' AND NEW.status = 'expired' THEN
        INSERT INTO notifications_events (id, type, created_at, invoice_id, service_id)
        VALUES (gen_random_uuid(), 'INVOICE_EXPIRED', now(), NEW.id, NEW.service_id);
    END IF;

    -- Check for status change to 'error'
    IF OLD.status IS DISTINCT FROM 'error' AND NEW.status = 'error' THEN
        INSERT INTO notifications_events (id, type, created_at, invoice_id, service_id)
        VALUES (gen_random_uuid(), 'INVOICE_ERROR', now(), NEW.id, NEW.service_id);
    END IF;

    RETURN NEW;
END;$function$
;

CREATE OR REPLACE FUNCTION public.handle_webhook_delivery_success()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$BEGIN
    -- Check for webhook delivery failure
    IF NEW.success = FALSE THEN
        INSERT INTO notifications_events (id, type, created_at, webhook_delivery_id, service_id)
        VALUES (gen_random_uuid(), 'WEBHOOK_FAILURE', now(), NEW.id, (SELECT service_id FROM webhooks WHERE id = NEW.webhook_id));
    END IF;

    RETURN NEW;
END;$function$
;

CREATE TRIGGER trigger_create_notifications_on_insert_events AFTER INSERT ON public.notifications_events FOR EACH ROW EXECUTE FUNCTION create_notifications_from_events();

CREATE TRIGGER trigger_webhooks_notifications_events_on_success_change AFTER INSERT OR UPDATE OF success ON public.webhooks_deliveries FOR EACH ROW WHEN ((new.success = false)) EXECUTE FUNCTION handle_webhook_delivery_success();

CREATE TRIGGER update_on_received_amount BEFORE INSERT OR UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION handle_invoice_status();


