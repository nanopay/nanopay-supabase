alter table "public"."invoices" alter column "currency" set not null;

alter table "public"."invoices" alter column "received_amount" set not null;

alter table "public"."invoices" alter column "refunded_amount" set not null;

alter table "public"."invoices" alter column "status" set not null;