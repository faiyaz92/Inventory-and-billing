import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle defaultTextStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  FontStyle fontStyle = FontStyle.normal, // New: Added fontStyle parameter
  Color color = Colors.black,
}) {
  return GoogleFonts.roboto(
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle, // Apply fontStyle
    color: color,
  );
}
