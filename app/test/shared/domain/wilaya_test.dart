import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/domain/wilaya.dart';

void main() {
  test('69 wilayas numbered 1 to 69 with unique ids', () {
    expect(Wilaya.all.map((w) => w.code), List.generate(69, (i) => i + 1));
    expect(Wilaya.all.map((w) => w.id).toSet(), hasLength(69));
  });

  test('ids and codes match the database migration', () {
    final sql = File(
      '../supabase/migrations/20261011000100_wilayas_and_level.sql',
    ).readAsStringSync();
    final rows = RegExp(r"\('([a-z_]+)', (\d+), ").allMatches(sql);
    final db = {for (final m in rows) m[1]!: int.parse(m[2]!)};
    expect(db, {for (final w in Wilaya.all) w.id: w.code});
  });

  test('label shows the number and the name in the right language', () {
    final w = Wilaya.byId('alger')!;
    expect(w.label('fr'), '16 · Alger');
    expect(w.label('ar'), '16 · الجزائر');
  });
}
