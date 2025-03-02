import 'package:intl/intl.dart';

DateTime parseDate(String dateString) {
  return DateTime.parse(dateString); // ✅ Converts "2025-01-25T12:21:43.911420" to DateTime
}
String getYearFromDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat('yyyy').format(date); // ✅ Extracts "2025"
}
String getMonthYearFromDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat('MMM yyyy').format(date); // ✅ Extracts "Jan 2025"
}
String getQuarterFromDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  int quarter = ((date.month - 1) ~/ 3) + 1;
  return "Q$quarter ${DateFormat('yyyy').format(date)}"; // ✅ Extracts "Q1 2025"
}
