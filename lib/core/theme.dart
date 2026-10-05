import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const blue = Color(0xFF8AB9EA), softBlue = Color(0xFFDCEEFF), veryLight = Color(0xFFF3F8FE);
  static const green = Color(0xFFA8DDBB), lightGreen = Color(0xFFE3F5E9);
  static const purple = Color(0xFFC9B9EE), lightPurple = Color(0xFFF1ECFB);
  static const pink = Color(0xFFF5B9C4), lightPink = Color(0xFFFCECEF);
  static const red = Color(0xFFF05B61), lightRed = Color(0xFFFFF0F1);
  static const orange = Color(0xFFF2A65A), lightOrange = Color(0xFFFFF3E5);
  static const yellow = Color(0xFFE8C14F), lightYellow = Color(0xFFFFF9E0);
  static const text = Color(0xFF34445C), text2 = Color(0xFF718096);
  static const bg = Color(0xFFF8FBFE), border = Color(0xFFE4EBF3);
  static const greenDark = Color(0xFF3E9B66);
}

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: C.blue, surface: C.bg));
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(bodyColor: C.text, displayColor: C.text),
    appBarTheme: const AppBarTheme(backgroundColor: C.bg, elevation: 0, scrolledUnderElevation: 0, foregroundColor: C.text, centerTitle: false),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white, indicatorColor: C.softBlue, height: 68,
      labelTextStyle: WidgetStatePropertyAll(GoogleFonts.poppins(fontSize: 12, color: C.text)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.blue : const Color(0xFFCBD5E0)),
    ),
  );
}
