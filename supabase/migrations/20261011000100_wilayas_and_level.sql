-- All 69 wilayas (58 + the 11 created by presidential decree n° 26-206,
-- Journal officiel n° 40, 2026), and the player's self-rated level for
-- onboarding. `cities` keeps its name: one row per wilaya; communes come
-- later in their own table.

alter table public.cities
  add column code smallint unique check (code between 1 and 99);

comment on table public.cities is
  'Wilayas. code = official wilaya number (01 Adrar … 69 El Abiodh Sidi Cheikh).';

insert into public.cities (id, code, name_fr, name_ar) values
  ('adrar', 1, 'Adrar', 'أدرار'),
  ('chlef', 2, 'Chlef', 'الشلف'),
  ('laghouat', 3, 'Laghouat', 'الأغواط'),
  ('oum_el_bouaghi', 4, 'Oum El Bouaghi', 'أم البواقي'),
  ('batna', 5, 'Batna', 'باتنة'),
  ('bejaia', 6, 'Béjaïa', 'بجاية'),
  ('biskra', 7, 'Biskra', 'بسكرة'),
  ('bechar', 8, 'Béchar', 'بشار'),
  ('blida', 9, 'Blida', 'البليدة'),
  ('bouira', 10, 'Bouira', 'البويرة'),
  ('tamanrasset', 11, 'Tamanrasset', 'تمنراست'),
  ('tebessa', 12, 'Tébessa', 'تبسة'),
  ('tlemcen', 13, 'Tlemcen', 'تلمسان'),
  ('tiaret', 14, 'Tiaret', 'تيارت'),
  ('tizi', 15, 'Tizi Ouzou', 'تيزي وزو'),
  ('alger', 16, 'Alger', 'الجزائر'),
  ('djelfa', 17, 'Djelfa', 'الجلفة'),
  ('jijel', 18, 'Jijel', 'جيجل'),
  ('setif', 19, 'Sétif', 'سطيف'),
  ('saida', 20, 'Saïda', 'سعيدة'),
  ('skikda', 21, 'Skikda', 'سكيكدة'),
  ('sidi_bel_abbes', 22, 'Sidi Bel Abbès', 'سيدي بلعباس'),
  ('annaba', 23, 'Annaba', 'عنابة'),
  ('guelma', 24, 'Guelma', 'قالمة'),
  ('constantine', 25, 'Constantine', 'قسنطينة'),
  ('medea', 26, 'Médéa', 'المدية'),
  ('mostaganem', 27, 'Mostaganem', 'مستغانم'),
  ('msila', 28, 'M''Sila', 'المسيلة'),
  ('mascara', 29, 'Mascara', 'معسكر'),
  ('ouargla', 30, 'Ouargla', 'ورقلة'),
  ('oran', 31, 'Oran', 'وهران'),
  ('el_bayadh', 32, 'El Bayadh', 'البيض'),
  ('illizi', 33, 'Illizi', 'إليزي'),
  ('bordj_bou_arreridj', 34, 'Bordj Bou Arréridj', 'برج بوعريريج'),
  ('boumerdes', 35, 'Boumerdès', 'بومرداس'),
  ('el_tarf', 36, 'El Tarf', 'الطارف'),
  ('tindouf', 37, 'Tindouf', 'تندوف'),
  ('tissemsilt', 38, 'Tissemsilt', 'تيسمسيلت'),
  ('el_oued', 39, 'El Oued', 'الوادي'),
  ('khenchela', 40, 'Khenchela', 'خنشلة'),
  ('souk_ahras', 41, 'Souk Ahras', 'سوق أهراس'),
  ('tipaza', 42, 'Tipaza', 'تيبازة'),
  ('mila', 43, 'Mila', 'ميلة'),
  ('ain_defla', 44, 'Aïn Defla', 'عين الدفلى'),
  ('naama', 45, 'Naâma', 'النعامة'),
  ('ain_temouchent', 46, 'Aïn Témouchent', 'عين تموشنت'),
  ('ghardaia', 47, 'Ghardaïa', 'غرداية'),
  ('relizane', 48, 'Relizane', 'غليزان'),
  ('timimoun', 49, 'Timimoun', 'تيميمون'),
  ('bordj_badji_mokhtar', 50, 'Bordj Badji Mokhtar', 'برج باجي مختار'),
  ('ouled_djellal', 51, 'Ouled Djellal', 'أولاد جلال'),
  ('beni_abbes', 52, 'Béni Abbès', 'بني عباس'),
  ('in_salah', 53, 'In Salah', 'عين صالح'),
  ('in_guezzam', 54, 'In Guezzam', 'عين قزام'),
  ('touggourt', 55, 'Touggourt', 'تقرت'),
  ('djanet', 56, 'Djanet', 'جانت'),
  ('el_mghair', 57, 'El M''Ghair', 'المغير'),
  ('el_meniaa', 58, 'El Meniaa', 'المنيعة'),
  ('aflou', 59, 'Aflou', 'آفلو'),
  ('barika', 60, 'Barika', 'بريكة'),
  ('el_kantara', 61, 'El Kantara', 'القنطرة'),
  ('bir_el_ater', 62, 'Bir El Ater', 'بئر العاتر'),
  ('el_aricha', 63, 'El Aricha', 'العريشة'),
  ('ksar_chellala', 64, 'Ksar Chellala', 'قصر الشلالة'),
  ('ain_oussera', 65, 'Aïn Oussera', 'عين وسارة'),
  ('messaad', 66, 'Messaad', 'مسعد'),
  ('ksar_el_boukhari', 67, 'Ksar El Boukhari', 'قصر البخاري'),
  ('bou_saada', 68, 'Bou Saâda', 'بوسعادة'),
  ('el_abiodh_sidi_cheikh', 69, 'El Abiodh Sidi Cheikh', 'الأبيض سيدي الشيخ')
on conflict (id) do update
  set code = excluded.code, name_fr = excluded.name_fr, name_ar = excluded.name_ar;

alter table public.cities alter column code set not null;

-- Self-rated level, used to balance teams until enough games are played.
alter table public.profiles
  add column level text check (level in ('beginner', 'casual', 'good', 'competitive'));

grant update (level) on public.profiles to authenticated;

drop function public.get_my_profile();
create function public.get_my_profile()
returns table (
  id uuid, handle text, full_name text, avatar_url text, city_id text,
  positions public.position[], lang text, phone text, level text,
  verified_at timestamptz, xp integer, rank text, coins integer,
  no_show_count integer, booking_ban_until timestamptz, is_referee boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.handle, p.full_name, p.avatar_url, p.city_id, p.positions, p.lang,
    p.phone, p.level, p.verified_at, p.xp, public.rank_of(p.xp), p.coins,
    p.no_show_count, p.booking_ban_until,
    exists (select 1 from public.referees r where r.user_id = p.id)
  from public.profiles p
  where p.id = (select auth.uid());
$$;

revoke all on function public.get_my_profile() from public, anon;
grant execute on function public.get_my_profile() to authenticated, service_role;
