class TaskDto {
  final String? taskId;
  final String? companyId; // Tenant company ID
  final String? title;
  final String? description;
  final String? assignedTo; // User ID
  final String? assignedToUserName; // Assigned user name
  final String? createdBy;
  final String? status;
  final DateTime? deadline;
  final DateTime? createdAt; // Task creation timestamp
  final DateTime? lastUpdateTime; // Last update timestamp
  final String? lastUpdatedBy; // Last updated user ID
  final String? lastUpdatedByUserName; // Last updated user name

  TaskDto({
    this.taskId,
    this.companyId,
    this.title,
    this.description,
    this.assignedTo,
    this.assignedToUserName,
    this.createdBy,
    this.status,
    this.deadline,
    this.createdAt,
    this.lastUpdateTime,
    this.lastUpdatedBy,
    this.lastUpdatedByUserName,
  });

  factory TaskDto.fromMap(Map<String, dynamic> map, String? id) {
    return TaskDto(
      taskId: id,
      companyId: map["companyId"] as String?,
      title: map["title"] as String?,
      description: map["description"] as String?,
      assignedTo: map["assignedTo"] as String?,
      assignedToUserName: map["assignedToUserName"] as String? ?? "Unknown",
      createdBy: map["createdBy"] as String?,
      status: map["status"] as String?,
      deadline: map["deadline"] != null ? DateTime.tryParse(map["deadline"] as String) : null,
      createdAt: map["createdAt"] != null ? DateTime.tryParse(map["createdAt"] as String) : null,
      lastUpdateTime: map["lastUpdateTime"] != null ? DateTime.tryParse(map["lastUpdateTime"] as String) : null,
      lastUpdatedBy: map["lastUpdatedBy"] as String?,
      lastUpdatedByUserName: map["lastUpdatedByUserName"] as String? ?? "Unknown",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "taskId": taskId,
      "companyId": companyId,
      "title": title,
      "description": description,
      "assignedTo": assignedTo,
      "assignedToUserName": assignedToUserName,
      "createdBy": createdBy,
      "status": status,
      "deadline": deadline?.toIso8601String(),
      "createdAt": createdAt?.toIso8601String(),
      "lastUpdateTime": lastUpdateTime?.toIso8601String(),
      "lastUpdatedBy": lastUpdatedBy,
      "lastUpdatedByUserName": lastUpdatedByUserName,
    };
  }
}