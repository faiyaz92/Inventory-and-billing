import 'package:flutter/material.dart';

class AppColors {
  static const Color appBarStartColor = Color(0xFF6A1B9A); // Purple (gradient start)
  static const Color appBarMiddleColor = Color(0xFF1E88E5); // Dark Blue
  static const Color appBarEndColor = Color(0xFF2196F3); // Light Blue
  static const Color appBarIconColor = Colors.white;
  static const Color appBarTitleColor = Colors.white;

  static const Color labelColor = Colors.black;
  static const Color textFieldColor = Colors.black;
  static const Color hintColor = Colors.grey;



  // Button Colors
  static const Color deleteButtonColor = Colors.red; // Red for delete buttons
  static const Color viewButtonColor = Color(0xFF4CAF50); // Green for view buttons
  static const Color editButtonColor = Color(0xFF1E88E5); // Blue for edit buttons
  static const Color verifiedChipBackground = Colors.grey; // Background for unselected chips
  static const Color verifiedChipTextColor = Colors.black; // Text color for unselected chips

  static const Color blue = Colors.blue;
  static const Color transparent = Colors.transparent;
  static const Color green = Colors.green;
  static const Color orange = Colors.orange;

  // General Colors

  // Chart Colors
  static const Color red = Colors.red;

  // UI Component Colors
  static const Color cardBackground = Colors.white;
  static const Color borderGray = Colors.grey;
  static const Color shadowGray = Color(0xFFD3D3D3);

  // General Colors
  static const Color white = Colors.white;



  // UI Component Colors
  static const Color borderGrey = Colors.grey; // Border color for cards
  static const Color shadowGrey = Color(0xFFD3D3D3); // Light gray shadow for depth effect

  // Pie Chart Colors (Follow-Up Chart)
  static const Color pieChartSent = Colors.green; // Email Sent color
  static const Color pieChartNotSent = Colors.orange; // Email Not Sent color

  // Progress Chart (Bar Chart)
  static const Color barChartColor = Colors.blue; // Color for bars in the progress chart

  // Line Chart (Comparison Chart)
  static const Color lineChartColor = Colors.blueAccent; // Line color for the comparison chart
// Primary Colors
  static const Color primary = Color(0xFF1976D2); // A deep blue shade used in StockListPage
  static const Color primaryLight = Color(0xFF42A5F5); // Lighter shade for gradients
  static const Color primaryDark = Color(0xFF0D47A1); // Darker shade for contrast

  // Secondary Colors
  static const Color secondary = Color(0xFFFFA726); // Orange shade for buttons or highlights
  static const Color secondaryLight = Color(0xFFFFD95A); // Lighter orange for hover effects

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light grey background
  static const Color black87 = Colors.black87; // For text (used in StockListPage)

  // Text Colors
  static const Color grey = Colors.grey; // For labels and subtitles (used in StockListPage)
  static const Color textPrimary = Colors.black87; // Primary text color
  static const Color textSecondary = Colors.grey; // Secondary text color

  // Error and Success Colors

  // Card and Border Colors
  static const Color cardBorder = Colors.grey; // For table borders and outlines (used in StockListPage)

  // Gradient for Background (Inspired by StockListPage)
  static LinearGradient backgroundGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Theme.of(context).primaryColor.withOpacity(0.1),
        Theme.of(context).primaryColor.withOpacity(0.3),
      ],
    );
  }

  static const Color pending = Color(0xFFFFCA28); // For pending orders
  static const Color processing = Color(0xFF42A5F5); // For processing orders
  static const Color shipped = Color(0xFFAB47BC); // For shipped orders
  static const Color completed = Color(0xFF66BB6A); // For completed orders
  static const Color highLightOrange = Color(0xFFF3DDC7); // For processing orders


}
