revoke insert on table "public"."profiles" from "authenticated";
grant insert(user_id, avatar_url, name) on table "public"."profiles" to "authenticated";

revoke update on table "public"."profiles" from "authenticated";
grant update(avatar_url, name) on table "public"."profiles" to "authenticated";

