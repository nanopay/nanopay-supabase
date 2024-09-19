revoke insert on table "public"."services" from "authenticated";
grant insert(id, user_id, name, avatar_url, description, display_name, contact_email, website) on table "public"."services" to "authenticated";

revoke update on table "public"."services" from "authenticated";
grant update(name, avatar_url, description, display_name, contact_email, website) on table "public"."services" to "authenticated";
