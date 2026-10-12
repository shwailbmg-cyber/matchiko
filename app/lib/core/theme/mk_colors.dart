import 'package:flutter/material.dart';

/// Design tokens. Brand: electric violet, between blue and magenta, on
/// indigo-black. The football pitch keeps its turf green (see PitchTurf).
abstract final class MkColors {
  static const bg = Color(0xFF0B0A1A);
  static const bg2 = Color(0xFF110F26);
  static const card = Color(0xFF17142F);
  static const card2 = Color(0xFF221D44);
  static const nav = Color(0xFF0D0B20);
  static const text = Color(0xFFF1EEFF);
  static const sub = Color(0xFFADA6D2);
  static const faint = Color(0xFF7A72A3);

  /// Primary action color (buttons, active tab, progress).
  static const primary = Color(0xFF9D6BFF);

  /// Text on [primary].
  static const ink = Color(0xFF14072E);

  /// Hero gradient: blue → violet → magenta, dark at the bottom.
  static const heroBlue = Color(0xFF3D5BFF);
  static const heroViolet = Color(0xFF7B3FF2);
  static const heroMagenta = Color(0xFFB0309E);
  static const heroDeep = Color(0xFF241056);

  /// Light text on hero gradients.
  static const tint = Color(0xFFE4DCFF);
  static const tint2 = Color(0xFFC9C0F0);

  /// Football turf stripes (the pitch stays green).
  static const turf = Color(0xFF1A6B3C);
  static const turf2 = Color(0xFF1D7542);

  static const sand = Color(0xFFE9C46A);
  static const terra = Color(0xFFEF7B5A);
  static const red = Color(0xFFF06464);
  static const blue = Color(0xFF8CC8F5);

  /// Thin card borders (violet-white at 9% and 18%).
  static const line = Color(0x17D2C8FF);
  static const line2 = Color(0x2ED2C8FF);
}

abstract final class MkRadius {
  static const card = 18.0;
  static const cta = 17.0;
  static const sheet = 28.0;
}
