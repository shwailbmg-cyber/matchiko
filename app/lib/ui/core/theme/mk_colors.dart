import 'package:flutter/material.dart';

/// Design tokens from the Claude Design prototype (`design/prototype/Matchiko.html`).
abstract final class MkColors {
  static const bg = Color(0xFF06110B);
  static const bg2 = Color(0xFF0A1A10);
  static const card = Color(0xFF0E2016);
  static const card2 = Color(0xFF15301F);
  static const nav = Color(0xFF07140C);
  static const text = Color(0xFFEAF5EE);
  static const sub = Color(0xFF9DBFA9);
  static const faint = Color(0xFF6B8F7A);
  static const brand = Color(0xFF1A6B3C);
  static const lime = Color(0xFF3DDC84);
  static const ink = Color(0xFF04200F);
  static const sand = Color(0xFFE9C46A);
  static const terra = Color(0xFFEF7B5A);
  static const red = Color(0xFFF06464);
  static const blue = Color(0xFF8CC8F5);

  /// rgba(190,255,210,.09) and .18 — thin card borders.
  static const line = Color(0x17BEFFD2);
  static const line2 = Color(0x2EBEFFD2);
}

abstract final class MkRadius {
  static const card = 18.0;
  static const cta = 17.0;
  static const sheet = 28.0;
}
