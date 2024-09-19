create type "public"."invoice_status" as enum ('pending', 'paid', 'expired', 'error');

alter table "public"."invoices" alter column "status" set default 'pending'::invoice_status;

alter table "public"."invoices" alter column "status" set data type invoice_status using "status"::invoice_status;


