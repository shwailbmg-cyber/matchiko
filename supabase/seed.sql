-- Local development data (runs on `supabase db reset`). Never run in production.

insert into public.venues (id, name, name_ar, city_id, district, lat, lng) values
  ('00000000-0000-0000-0000-00000000a001', 'Complexe El Harrach', 'مركب الحراش', 'alger', 'El Harrach', 36.7167, 3.1333),
  ('00000000-0000-0000-0000-00000000a002', 'Terrain El Biar', 'ملعب الأبيار', 'alger', 'El Biar', 36.7686, 3.0300),
  ('00000000-0000-0000-0000-00000000a003', 'Kouba Five', 'ملعب القبة', 'alger', 'Kouba', 36.7270, 3.0850);

insert into public.pitches (id, venue_id, name, max_per_side, price_da, features) values
  ('00000000-0000-0000-0000-00000000b001', '00000000-0000-0000-0000-00000000a001', 'Terrain 1', 7, 2500, '{light,ball,roof}'),
  ('00000000-0000-0000-0000-00000000b002', '00000000-0000-0000-0000-00000000a002', 'Terrain 1', 11, 3000, '{light,shower,ref}'),
  ('00000000-0000-0000-0000-00000000b003', '00000000-0000-0000-0000-00000000a003', 'Five 1', 5, 2000, '{light,ball,shower,roof}');

-- Test accounts. Sign in locally with the email code from Mailpit
-- (http://127.0.0.1:54324).
-- Empty strings, not NULL, for token columns: GoTrue can't scan NULLs there.
insert into auth.users (
  id, instance_id, aud, role, email, email_confirmed_at, phone, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
  email_change_token_new, email_change, phone_change, phone_change_token,
  email_change_token_current, reauthentication_token
) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', 'amine@matchiko.test', now(), '213555000001', now(), now(),
   '{"provider":"email","providers":["email"]}', '{}', '', '', '', '', '', '', '', ''),
  ('00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', 'manager@matchiko.test', now(), '213555000002', now(), now(),
   '{"provider":"email","providers":["email"]}', '{}', '', '', '', '', '', '', '', '');

-- Email identities so GoTrue can sign these users in with an email code.
insert into auth.identities (user_id, provider_id, provider, identity_data, last_sign_in_at)
select id, id::text, 'email',
  jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true), now()
from auth.users
where id in ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000a2');

update public.profiles
set handle = 'amineb7', full_name = 'Amine Benali', city_id = 'alger',
    positions = '{mid,fwd}', phone = '+213555000001', verified_at = now(), xp = 1240,
    coins = 340
where id = '00000000-0000-0000-0000-0000000000a1';

update public.profiles
set handle = 'manager_harrach', full_name = 'Manager El Harrach', city_id = 'alger',
    phone = '+213555000002'
where id = '00000000-0000-0000-0000-0000000000a2';

insert into public.venue_managers (venue_id, user_id) values
  ('00000000-0000-0000-0000-00000000a001', '00000000-0000-0000-0000-0000000000a2');
