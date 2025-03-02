class TaskDto {
  final String? taskId;
  final String? companyId; // ✅ Tenant company ID
  final String title;
  final String description;
  final String assignedTo; // User ID
  final String assignedToUserName; // 🔥 New field to store assigned user name
  final String createdBy;
  final String status;
  final DateTime deadline;

  TaskDto({
    this.taskId,
    required this.companyId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToUserName, // ✅ New field
    required this.createdBy,
    required this.status,
    required this.deadline,
  });

  factory TaskDto.fromMap(Map<String, dynamic> map, String id) {
    return TaskDto(
      taskId: id,
      companyId: map["companyId"],
      title: map["title"],
      description: map["description"],
      assignedTo: map["assignedTo"],
      assignedToUserName: map["assignedToUserName"] ?? "Unknown", // ✅ Default value if missing
      createdBy: map["createdBy"],
      status: map["status"],
      deadline: DateTime.parse(map["deadline"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "taskId": taskId,
      "companyId": companyId,
      "title": title,
      "description": description,
      "assignedTo": assignedTo,
      "assignedToUserName": assignedToUserName, // ✅ Include in Firestore data
      "createdBy": createdBy,
      "status": status,
      "deadline": deadline.toIso8601String(),
    };
  }
}
