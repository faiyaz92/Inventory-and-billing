import 'package:requirment_gathering_app/company_admin_module/data/task_model_dto.dart';

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final String assignedTo; // User ID
  final String assignedToUserName; // 🔥 New field to store assigned user name
  final String createdBy;
  final String status;
  final DateTime deadline;

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToUserName, // ✅ Added assigned user name
    required this.createdBy,
    required this.status,
    required this.deadline,
  });

  /// 🔹 Mapping from DTO to TaskModel
  factory TaskModel.fromDto(TaskDto dto) {
    return TaskModel(
      taskId: dto.taskId ?? '',
      title: dto.title,
      description: dto.description,
      assignedTo: dto.assignedTo,
      assignedToUserName: dto.assignedToUserName ?? "Unknown", // ✅ Assign default if missing
      createdBy: dto.createdBy,
      status: dto.status,
      deadline: dto.deadline,
    );
  }

  /// 🔹 Convert to DTO for Firestore communication
  TaskDto toDto(String companyId) {
    return TaskDto(
      taskId: taskId,
      companyId: companyId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedToUserName: assignedToUserName, // ✅ Include assigned user name
      createdBy: createdBy,
      status: status,
      deadline: deadline,
    );
  }

  /// 🔹 **CopyWith Method for Partial Updates**
  TaskModel copyWith({
    String? taskId,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToUserName,
    String? createdBy,
    String? status,
    DateTime? deadline,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToUserName: assignedToUserName ?? this.assignedToUserName, // ✅ Keeps existing name if not updated
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
    );
  }
}
