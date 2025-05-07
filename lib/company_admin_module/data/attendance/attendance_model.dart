class AttendanceModel {
  final String date; // dd-MM-yyyy, e.g., "06-05-2025"
  final String status; // e.g., "present", "absent"

  AttendanceModel({
    required this.date,
    required this.status,
  });
}