class AttendanceDTO {
  final String date; // yyyy-MM-dd, e.g., "2025-05-06"
  final String status; // e.g., "present", "absent"
  final String year; // e.g., "2025"
  final String month; // e.g., "05"
  final String day; // e.g., "06"

  AttendanceDTO({
    required this.date,
    required this.status,
    required this.year,
    required this.month,
    required this.day,
  });

  factory AttendanceDTO.fromJson(Map<String, dynamic> json) {
    return AttendanceDTO(
      date: json['date'],
      status: json['status'],
      year: json['year'],
      month: json['month'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'status': status,
      'year': year,
      'month': month,
      'day': day,
    };
  }
}