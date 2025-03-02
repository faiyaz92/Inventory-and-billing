import 'package:requirment_gathering_app/company_admin_module/data/task_model_dto.dart';

abstract class TaskRepository {
  Future<void> createTask(TaskDto taskDto);
  Future<void> updateTask(String taskId, TaskDto taskDto);
  Future<void> deleteTask(String companyId,String taskId);
  Future<List<TaskDto>> getAllTasks(String companyId);
}
