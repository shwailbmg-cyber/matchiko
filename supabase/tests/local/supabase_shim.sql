-- Minimal stand-in for the parts of a Supabase database our migrations use,
-- so migrations + pgTAP tests can run on a plain Postgres when Docker (and
-- therefore `supabase start`) is not available, e.g. in cloud agent sessions.
-- The real thing is always `supabase db reset && supabase test db`.

create role anon nologin noinherit;
create role authenticated nologin noinherit;
create role service_role nologin noinherit bypassrls;

create schema extensions;
create schema auth;
grant usage on schema public, extensions to anon, authenticated, service_role;
grant usage on schema auth to anon, authenticated, service_role;
create extension pgtap with schema extensions;

create table auth.users (
  instance_id uuid,
  id uuid primary key default gen_random_uuid(),
  aud text,
  role text,
  email text,
  email_confirmed_at timestamptz,
  phone text unique,
  phone_confirmed_at timestamptz,
  raw_app_meta_data jsonb,
  raw_user_meta_data jsonb,
  confirmation_token text,
  recovery_token text,
  email_change_token_new text,
  email_change text,
  phone_change text,
  phone_change_token text,
  email_change_token_current text,
  reauthentication_token text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table auth.identities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  provider_id text not null,
  provider text not null,
  identity_data jsonb not null,
  last_sign_in_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (provider_id, provider)
);

-- Same logic as Supabase's auth.uid() / auth.jwt().
create function auth.uid() returns uuid language sql stable as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;
create function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb
$$;
grant execute on function auth.uid(), auth.jwt() to anon, authenticated, service_role;

create publication supabase_realtime;

-- Supabase's default privileges: everything new in public is granted to the
-- API roles. Reproduced so tests catch tables/functions we forget to lock.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;

-- Minimal Storage schema (the parts our migrations and policies use).
create schema storage;
grant usage on schema storage to anon, authenticated, service_role;
create table storage.buckets (
  id text primary key,
  name text not null,
  public boolean default false,
  file_size_limit bigint,
  allowed_mime_types text[]
);
create table storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets (id),
  name text,
  owner uuid default auth.uid(),
  created_at timestamptz default now()
);
alter table storage.objects enable row level security;
grant select, insert, update, delete on storage.objects to authenticated;
create function storage.foldername(name text) returns text[]
language sql immutable as $$ select (string_to_array(name, '/'))[1:array_length(string_to_array(name, '/'), 1) - 1] $$;
