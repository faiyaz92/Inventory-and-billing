import 'package:requirment_gathering_app/company_admin_module/data/task_model_dto.dart';

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final String assignedTo;
  final String createdBy;
  final String status;
  final DateTime deadline;

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedTo,
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
      createdBy: createdBy,
      status: status,
      deadline: deadline,
    );
  }
}
