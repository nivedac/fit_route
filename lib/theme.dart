import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color charcoal = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color accentOrange = Color(0xFFE67E22);
  static const Color sunsetOrange = Color(0xFFFF4D00);
  static const Color accentLime = Color(0xFFE2FF3B);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentEmerald = Color(0xFF00E676);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: charcoal,
    primaryColor: sunsetOrange,
    colorScheme: ColorScheme.dark(
      primary: sunsetOrange,
      secondary: accentOrange,
      surface: surface,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
  );
}
