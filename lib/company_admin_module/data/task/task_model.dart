
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model_dto.dart';

class TaskModel {
  final String? taskId;
  final String? title;
  final String? description;
  final String? assignedTo; // User ID
  final String? assignedToUserName; // Assigned user name
  final String? createdBy;
  final String? status;
  final DateTime? deadline;
  final DateTime? createdAt; // ✅ New: Task creation timestamp
  final DateTime? lastUpdateTime; // Last update timestamp
  final String? lastUpdatedBy; // Last updated user ID
  final String? lastUpdatedByUserName; // Last updated user name

  TaskModel({
    this.taskId,
    this.title,
    this.description,
    this.assignedTo,
    this.assignedToUserName,
    this.createdBy,
    this.status,
    this.deadline,
    this.createdAt, // ✅ Added
    this.lastUpdateTime,
    this.lastUpdatedBy,
    this.lastUpdatedByUserName,
  });

  /// Mapping from DTO to TaskModel
  factory TaskModel.fromDto(TaskDto dto) {
    return TaskModel(
      taskId: dto.taskId,
      title: dto.title,
      description: dto.description,
      assignedTo: dto.assignedTo,
      assignedToUserName: dto.assignedToUserName ?? "Unknown",
      createdBy: dto.createdBy,
      status: dto.status,
      deadline: dto.deadline,
      createdAt: dto.createdAt, // ✅ Added
      lastUpdateTime: dto.lastUpdateTime,
      lastUpdatedBy: dto.lastUpdatedBy,
      lastUpdatedByUserName: dto.lastUpdatedByUserName ?? "Unknown",
    );
  }

  /// Convert to DTO for Firestore communication
  TaskDto toDto(String companyId) {
    return TaskDto(
      taskId: taskId,
      companyId: companyId,
      title: title ?? '', // Provide default empty string if null
      description: description ?? '', // Default empty string
      assignedTo: assignedTo ?? '', // Default empty string
      assignedToUserName: assignedToUserName ?? "Unknown",
      createdBy: createdBy ?? '', // Default empty string
      status: status ?? 'pending', // Default status
      deadline: deadline ?? DateTime.now(), // Default to current time
      createdAt: createdAt ?? DateTime.now(), // ✅ Default to current time
      lastUpdateTime: lastUpdateTime ?? DateTime.now(), // Default to current time
      lastUpdatedBy: lastUpdatedBy ?? '', // Default empty string
      lastUpdatedByUserName: lastUpdatedByUserName ?? "Unknown",
    );
  }

  /// CopyWith Method for Partial Updates
  TaskModel copyWith({
    String? taskId,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToUserName,
    String? createdBy,
    String? status,
    DateTime? deadline,
    DateTime? createdAt, // ✅ Added
    DateTime? lastUpdateTime,
    String? lastUpdatedBy,
    String? lastUpdatedByUserName,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToUserName: assignedToUserName ?? this.assignedToUserName,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt, // ✅ Added
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      lastUpdatedByUserName: lastUpdatedByUserName ?? this.lastUpdatedByUserName,
    );
  }
}