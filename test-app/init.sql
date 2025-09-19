CREATE TABLE "public"."platform" (
    "validated" boolean NOT NULL,
    "id" bigserial primary key,
    "message" character varying(255),
)
WITH (oids = false);