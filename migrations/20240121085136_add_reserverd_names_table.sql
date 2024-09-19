-- add reserved names table with column created_at:

CREATE TABLE reserved_names (
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);
