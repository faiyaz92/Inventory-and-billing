class TaskDto {
  final String? taskId;
  final String? companyId; // ✅ Tenant company ID
  final String title;
  final String description;
  final String assignedTo;
  final String createdBy;
  final String status;
  final DateTime deadline;

  TaskDto({
    this.taskId,
    required this.companyId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.createdBy,
    required this.status,
    required this.deadline,
  });

  factory TaskDto.fromMap(Map<String, dynamic> map,id) {
    return TaskDto(
      taskId: id,
      companyId: map["companyId"],
      title: map["title"],
      description: map["description"],
      assignedTo: map["assignedTo"],
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
      "createdBy": createdBy,
      "status": status,
      "deadline": deadline.toIso8601String(),
    };
  }
}
