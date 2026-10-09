-- Local development data (runs on `supabase db reset`). Never run in production.

insert into public.cities (id, name_fr, name_ar) values
  ('alger', 'Alger', 'الجزائر'),
  ('oran', 'Oran', 'وهران'),
  ('constantine', 'Constantine', 'قسنطينة'),
  ('blida', 'Blida', 'البليدة'),
  ('annaba', 'Annaba', 'عنابة'),
  ('tizi', 'Tizi Ouzou', 'تيزي وزو');

-- Coins are the locked values from the product brief. XP values are a first
-- guess (TBD with the product owner); tune them here, no release needed.
insert into public.reward_rules (reason, xp, coins) values
  ('show_up', 20, 20),
  ('rate_game', 5, 10),
  ('referee', 40, 50),
  ('win', 30, 30),
  ('goal', 10, 30),
  ('mvp', 30, 30),
  ('pay_online', 0, 15),
  ('invite', 0, 100),
  ('verified', 0, 200),
  ('no_show', -50, -30),
  ('admin', 0, 0);

insert into public.venues (id, name, name_ar, city_id, district, lat, lng) values
  ('00000000-0000-0000-0000-00000000a001', 'Complexe El Harrach', 'مركب الحراش', 'alger', 'El Harrach', 36.7167, 3.1333),
  ('00000000-0000-0000-0000-00000000a002', 'Terrain El Biar', 'ملعب الأبيار', 'alger', 'El Biar', 36.7686, 3.0300),
  ('00000000-0000-0000-0000-00000000a003', 'Kouba Five', 'ملعب القبة', 'alger', 'Kouba', 36.7270, 3.0850);

insert into public.pitches (id, venue_id, name, format, price_da, features) values
  ('00000000-0000-0000-0000-00000000b001', '00000000-0000-0000-0000-00000000a001', 'Terrain 1', '6v6', 2500, '{light,ball,roof}'),
  ('00000000-0000-0000-0000-00000000b002', '00000000-0000-0000-0000-00000000a002', 'Terrain 1', '8v8', 3000, '{light,shower,ref}'),
  ('00000000-0000-0000-0000-00000000b003', '00000000-0000-0000-0000-00000000a003', 'Five 1', '5v5', 2000, '{light,ball,shower,roof}');

-- Test accounts matching [auth.sms.test_otp] in config.toml (code 123456).
-- Empty strings, not NULL, for token columns: GoTrue can't scan NULLs there.
insert into auth.users (
  id, instance_id, aud, role, phone, phone_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
  email_change_token_new, email_change, phone_change, phone_change_token,
  email_change_token_current, reauthentication_token
) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', '213555000001', now(), now(), now(),
   '{"provider":"phone","providers":["phone"]}', '{}', '', '', '', '', '', '', '', ''),
  ('00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', '213555000002', now(), now(), now(),
   '{"provider":"phone","providers":["phone"]}', '{}', '', '', '', '', '', '', '', '');

update public.profiles
set handle = 'amineb7', full_name = 'Amine Benali', city_id = 'alger',
    positions = '{mid,fwd}', verified_at = now(), xp = 1240, coins = 340
where id = '00000000-0000-0000-0000-0000000000a1';

update public.profiles
set handle = 'manager_harrach', full_name = 'Manager El Harrach', city_id = 'alger'
where id = '00000000-0000-0000-0000-0000000000a2';

insert into public.venue_managers (venue_id, user_id) values
  ('00000000-0000-0000-0000-00000000a001', '00000000-0000-0000-0000-0000000000a2');
