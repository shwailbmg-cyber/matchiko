import 'package:flutter/material.dart';

import 'mk_colors.dart';

abstract final class MkFonts {
  static const display = 'BarlowCondensed';
  static const body = 'Cairo';
}

/// Uppercase condensed headline (`.disp` in the prototype). Arabic has no
/// condensed cut, so it falls back to heavy Cairo like the prototype does.
TextStyle mkDisplay(BuildContext context, {double size = 40}) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  return TextStyle(
    fontFamily: isArabic ? MkFonts.body : MkFonts.display,
    fontWeight: isArabic ? FontWeight.w900 : FontWeight.w800,
    fontSize: isArabic ? size * .75 : size,
    height: isArabic ? 1.3 : .95,
    color: MkColors.text,
  );
}

ThemeData buildMkTheme() {
  const scheme = ColorScheme.dark(
    surface: MkColors.bg,
    primary: MkColors.lime,
    onPrimary: MkColors.ink,
    secondary: MkColors.sand,
    error: MkColors.red,
    onSurface: MkColors.text,
    outline: MkColors.line2,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MkColors.bg,
    fontFamily: MkFonts.body,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: MkColors.text,
      displayColor: MkColors.text,
    ),
    cardTheme: const CardThemeData(
      color: MkColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(MkRadius.card)),
        side: BorderSide(color: MkColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MkColors.lime,
        foregroundColor: MkColors.ink,
        disabledBackgroundColor: MkColors.card2,
        disabledForegroundColor: MkColors.faint,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MkRadius.cta),
        ),
        textStyle: const TextStyle(
          fontFamily: MkFonts.body,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MkColors.sub,
        minimumSize: const Size(0, 56),
        side: const BorderSide(color: MkColors.line2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MkRadius.cta),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MkColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MkColors.line2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MkColors.line2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MkColors.lime),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MkColors.bg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MkRadius.sheet),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: MkColors.line2,
    ),
  );
}
