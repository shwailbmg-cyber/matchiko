-- Push pipeline without dashboard clicks: each new notification is sent to
-- the `push` Edge Function by pg_net, and pg_cron runs send_reminders()
-- every 15 minutes. The function URL and a random shared secret live in
-- Supabase Vault (`project_url`, `push_webhook_secret`); the Edge Function
-- reads the secret through push_webhook_secret() with the service role.
-- Everything is skipped where the extensions don't exist (local tests).

do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_net') then
    execute 'create extension if not exists pg_net';
  end if;
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    execute 'create extension if not exists pg_cron';
    perform cron.schedule('send-reminders', '*/15 * * * *', 'select public.send_reminders()');
  end if;
  if to_regnamespace('vault') is not null then
    execute $q$
      select vault.create_secret(encode(extensions.gen_random_bytes(32), 'hex'),
                                 'push_webhook_secret', 'Shared secret for the push Edge Function')
      where not exists (select 1 from vault.secrets where name = 'push_webhook_secret')
    $q$;
  end if;
end;
$$;

-- For the Edge Function only (service role).
create function public.push_webhook_secret()
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if to_regnamespace('vault') is null then
    return null;
  end if;
  return (select decrypted_secret from vault.decrypted_secrets
          where name = 'push_webhook_secret');
end;
$$;

create function public.notify_push()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_url text;
  v_secret text;
begin
  if to_regnamespace('net') is null or to_regnamespace('vault') is null then
    return null;
  end if;
  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'project_url';
  v_secret := public.push_webhook_secret();
  if v_url is null or v_secret is null then
    return null;
  end if;
  -- Asynchronous: queued by pg_net, never blocks or fails the insert.
  perform net.http_post(
    url := v_url || '/functions/v1/push',
    headers := jsonb_build_object('content-type', 'application/json',
                                  'x-webhook-secret', v_secret),
    body := jsonb_build_object('record', jsonb_build_object(
      'user_id', new.user_id, 'kind', new.kind, 'payload', new.payload)));
  return null;
end;
$$;

create trigger notifications_push after insert on public.notifications
  for each row execute function public.notify_push();

revoke all on function public.push_webhook_secret(), public.notify_push()
  from public, anon, authenticated;
grant execute on function public.push_webhook_secret() to service_role;
