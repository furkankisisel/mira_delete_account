import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();
  static TextTheme build(TextTheme base) {
    final playfair = GoogleFonts.playfairDisplayTextTheme(base);
    return playfair.copyWith(
      bodyMedium: GoogleFonts.nunito(textStyle: base.bodyMedium),
      bodySmall: GoogleFonts.nunito(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.nunito(textStyle: base.labelLarge),
    );
  }
}
