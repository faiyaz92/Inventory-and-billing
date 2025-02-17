import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';

abstract class TaskService {
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(String taskId, TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskModel>> getAllTasks();
}