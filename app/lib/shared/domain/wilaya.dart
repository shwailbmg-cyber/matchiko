/// An Algerian wilaya. Same ids and codes as `public.cities` (migration
/// `20261011000100_wilayas_and_level.sql`); a test keeps them in sync.
class Wilaya {
  const Wilaya(this.code, this.id, this.nameFr, this.nameAr);

  /// Official number, 1 to 69.
  final int code;
  final String id;
  final String nameFr;
  final String nameAr;

  /// Arabic name in Arabic, the French spelling otherwise (also used in
  /// English, like on road signs).
  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameFr;

  /// "16 · Alger"
  String label(String languageCode) =>
      '${code.toString().padLeft(2, '0')} · ${name(languageCode)}';

  static Wilaya? byId(String? id) => all.where((w) => w.id == id).firstOrNull;

  /// All 69 wilayas in official order (58 + decree n° 26-206 of 2026).
  static const all = [
    Wilaya(1, 'adrar', 'Adrar', 'أدرار'),
    Wilaya(2, 'chlef', 'Chlef', 'الشلف'),
    Wilaya(3, 'laghouat', 'Laghouat', 'الأغواط'),
    Wilaya(4, 'oum_el_bouaghi', 'Oum El Bouaghi', 'أم البواقي'),
    Wilaya(5, 'batna', 'Batna', 'باتنة'),
    Wilaya(6, 'bejaia', 'Béjaïa', 'بجاية'),
    Wilaya(7, 'biskra', 'Biskra', 'بسكرة'),
    Wilaya(8, 'bechar', 'Béchar', 'بشار'),
    Wilaya(9, 'blida', 'Blida', 'البليدة'),
    Wilaya(10, 'bouira', 'Bouira', 'البويرة'),
    Wilaya(11, 'tamanrasset', 'Tamanrasset', 'تمنراست'),
    Wilaya(12, 'tebessa', 'Tébessa', 'تبسة'),
    Wilaya(13, 'tlemcen', 'Tlemcen', 'تلمسان'),
    Wilaya(14, 'tiaret', 'Tiaret', 'تيارت'),
    Wilaya(15, 'tizi', 'Tizi Ouzou', 'تيزي وزو'),
    Wilaya(16, 'alger', 'Alger', 'الجزائر'),
    Wilaya(17, 'djelfa', 'Djelfa', 'الجلفة'),
    Wilaya(18, 'jijel', 'Jijel', 'جيجل'),
    Wilaya(19, 'setif', 'Sétif', 'سطيف'),
    Wilaya(20, 'saida', 'Saïda', 'سعيدة'),
    Wilaya(21, 'skikda', 'Skikda', 'سكيكدة'),
    Wilaya(22, 'sidi_bel_abbes', 'Sidi Bel Abbès', 'سيدي بلعباس'),
    Wilaya(23, 'annaba', 'Annaba', 'عنابة'),
    Wilaya(24, 'guelma', 'Guelma', 'قالمة'),
    Wilaya(25, 'constantine', 'Constantine', 'قسنطينة'),
    Wilaya(26, 'medea', 'Médéa', 'المدية'),
    Wilaya(27, 'mostaganem', 'Mostaganem', 'مستغانم'),
    Wilaya(28, 'msila', "M'Sila", 'المسيلة'),
    Wilaya(29, 'mascara', 'Mascara', 'معسكر'),
    Wilaya(30, 'ouargla', 'Ouargla', 'ورقلة'),
    Wilaya(31, 'oran', 'Oran', 'وهران'),
    Wilaya(32, 'el_bayadh', 'El Bayadh', 'البيض'),
    Wilaya(33, 'illizi', 'Illizi', 'إليزي'),
    Wilaya(34, 'bordj_bou_arreridj', 'Bordj Bou Arréridj', 'برج بوعريريج'),
    Wilaya(35, 'boumerdes', 'Boumerdès', 'بومرداس'),
    Wilaya(36, 'el_tarf', 'El Tarf', 'الطارف'),
    Wilaya(37, 'tindouf', 'Tindouf', 'تندوف'),
    Wilaya(38, 'tissemsilt', 'Tissemsilt', 'تيسمسيلت'),
    Wilaya(39, 'el_oued', 'El Oued', 'الوادي'),
    Wilaya(40, 'khenchela', 'Khenchela', 'خنشلة'),
    Wilaya(41, 'souk_ahras', 'Souk Ahras', 'سوق أهراس'),
    Wilaya(42, 'tipaza', 'Tipaza', 'تيبازة'),
    Wilaya(43, 'mila', 'Mila', 'ميلة'),
    Wilaya(44, 'ain_defla', 'Aïn Defla', 'عين الدفلى'),
    Wilaya(45, 'naama', 'Naâma', 'النعامة'),
    Wilaya(46, 'ain_temouchent', 'Aïn Témouchent', 'عين تموشنت'),
    Wilaya(47, 'ghardaia', 'Ghardaïa', 'غرداية'),
    Wilaya(48, 'relizane', 'Relizane', 'غليزان'),
    Wilaya(49, 'timimoun', 'Timimoun', 'تيميمون'),
    Wilaya(50, 'bordj_badji_mokhtar', 'Bordj Badji Mokhtar', 'برج باجي مختار'),
    Wilaya(51, 'ouled_djellal', 'Ouled Djellal', 'أولاد جلال'),
    Wilaya(52, 'beni_abbes', 'Béni Abbès', 'بني عباس'),
    Wilaya(53, 'in_salah', 'In Salah', 'عين صالح'),
    Wilaya(54, 'in_guezzam', 'In Guezzam', 'عين قزام'),
    Wilaya(55, 'touggourt', 'Touggourt', 'تقرت'),
    Wilaya(56, 'djanet', 'Djanet', 'جانت'),
    Wilaya(57, 'el_mghair', "El M'Ghair", 'المغير'),
    Wilaya(58, 'el_meniaa', 'El Meniaa', 'المنيعة'),
    Wilaya(59, 'aflou', 'Aflou', 'آفلو'),
    Wilaya(60, 'barika', 'Barika', 'بريكة'),
    Wilaya(61, 'el_kantara', 'El Kantara', 'القنطرة'),
    Wilaya(62, 'bir_el_ater', 'Bir El Ater', 'بئر العاتر'),
    Wilaya(63, 'el_aricha', 'El Aricha', 'العريشة'),
    Wilaya(64, 'ksar_chellala', 'Ksar Chellala', 'قصر الشلالة'),
    Wilaya(65, 'ain_oussera', 'Aïn Oussera', 'عين وسارة'),
    Wilaya(66, 'messaad', 'Messaad', 'مسعد'),
    Wilaya(67, 'ksar_el_boukhari', 'Ksar El Boukhari', 'قصر البخاري'),
    Wilaya(68, 'bou_saada', 'Bou Saâda', 'بوسعادة'),
    Wilaya(
      69,
      'el_abiodh_sidi_cheikh',
      'El Abiodh Sidi Cheikh',
      'الأبيض سيدي الشيخ',
    ),
  ];
}
