import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle defaultTextStyle({
  double fontSize = 14, // Default font size
  FontWeight fontWeight = FontWeight.normal, // Default font weight
  FontStyle fontStyle = FontStyle.normal, // Default font style
  Color color = Colors.black, // Default color
  TextDecoration? decoration, // Optional decoration (e.g., underline)
}) {
  return GoogleFonts.roboto(
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    color: color,
    decoration: decoration, // Apply decoration if provided
    height: 1.4, // Line height for readability
  );
}
