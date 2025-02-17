import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/task_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/task_repository_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

class TaskServiceImpl implements TaskService {
  final TaskRepository _taskRepository;
  final AccountRepository _accountRepository;

  TaskServiceImpl(this._taskRepository, this._accountRepository);

  @override
  Future<void> createTask(TaskModel task) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }

    final taskDto = task.toDto(userInfo.companyId!);
    await _taskRepository.createTask(taskDto);
  }

  @override
  Future<void> updateTask(String taskId, TaskModel task) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }

    final taskDto = task.toDto(userInfo.companyId!);
    await _taskRepository.updateTask(taskId, taskDto);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _taskRepository.deleteTask(taskId);
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }

    final taskDtos = await _taskRepository.getAllTasks(userInfo.companyId!);
    return taskDtos.map((dto) => TaskModel.fromDto(dto)).toList();
  }
}
