import 'package:bloc/bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskService _taskService;
  final UserServices _companyOperationsService;
  final CustomerCompanyService _companyService;
  late CompanySettingsUi companySettingsUi;

  TaskCubit(
      this._taskService, this._companyOperationsService, this._companyService)
      : super(TaskInitial());

  Future<void> loadTaskSettings() async {
    try {
      final settingsResult = await _companyService.getSettings();
      settingsResult.fold(
        (error) {
          emit(TaskError("Failed to load settings: $error"));
        },
        (settings) {
          companySettingsUi = settings;
          emit(TaskSettingsLoaded(settings.taskStatuses));
        },
      );
    } catch (e) {
      emit(TaskError("Unexpected error: $e"));
    }
  }

  Future<void> fetchTasks() async {
    try {
      emit(TaskLoading());
      final tasks = await _taskService.getAllTasks();
      final users = await _companyOperationsService.getUsersFromTenantCompany();
      emit(TaskLoaded(tasks, users));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      emit(TaskLoading());
      task = task.copyWith(
          assignedToUserName: getUserNameById(task.assignedTo,
              await _companyOperationsService.getUsersFromTenantCompany()));
      await _taskService.createTask(task);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  String getUserNameById(String userId, List<UserInfo> users) {
    final user = users.firstWhere(
      (user) => user.userId == userId,
      orElse: () =>
          UserInfo(userName: "Unknown User"), // ✅ Default value if not found
    );

    return user.userName ?? "Unknown User"; // ✅ Ensures non-null return
  }

  Future<void> updateTask(String taskId, TaskModel task) async {
    try {
      emit(TaskLoading());
      task = task.copyWith(
          assignedToUserName: getUserNameById(task.assignedTo,
              await _companyOperationsService.getUsersFromTenantCompany()));
      await _taskService.updateTask(taskId, task);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      emit(TaskLoading());
      await _taskService.deleteTask(taskId);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  List<String> getUniqueStatuses(List<TaskModel> tasks) {
    return tasks.map((task) => task.status).toSet().toList();
  }
}
