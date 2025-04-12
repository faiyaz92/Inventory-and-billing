import 'package:bloc/bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskService _taskService;
  final UserServices _companyOperationsService;
  final CustomerCompanyService _companyService;
  final AccountRepository accountRepository;

  late CompanySettingsUi companySettingsUi;
  late List<UserInfo> users;
  late List<TaskModel> allTasks;
  String? selectedUserName; // Will persist after initial set
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  TaskCubit(
      this._taskService,
      this._companyOperationsService,
      this._companyService,
      this.accountRepository,
      ) : super(TaskInitial());

  /// Load Task Settings (Statuses)
  Future<void> loadTaskSettings() async {
    try {
      final settingsResult = await _companyService.getSettings();
      settingsResult.fold(
            (error) => emit(TaskError("Failed to load settings: $error")),
            (settings) {
          companySettingsUi = settings;
          emit(TaskSettingsLoaded(settings.taskStatuses));
        },
      );
    } catch (e) {
      emit(TaskError("Unexpected error: $e"));
    }
  }

  /// Fetch Tasks & Set Logged-in User as Default Filter (only on first load)
  Future<void> fetchTasks() async {
    try {
      emit(TaskLoading());
      final userInfo = await accountRepository.getUserInfo();
      allTasks = await _taskService.getAllTasks();
      users = await _companyOperationsService.getUsersFromTenantCompany();

      // Set selectedUserName to current user only if not already set
      if (selectedUserName == null && userInfo?.userId != null) {
        final currentUser = users.firstWhere(
              (user) => user.userId == userInfo?.userId,
          orElse: () => UserInfo(userName: "All Users"),
        );
        selectedUserName = currentUser.userName;
      } else if (selectedUserName == null) {
        selectedUserName = "All Users";
      }

      allTasks.sort(_sortTasks);
      emit(TaskLoaded(_filterTasks(), users));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  /// Filter Tasks by Assigned User & Date
  void filterTasks({String? userName, DateTime? startDate, DateTime? endDate}) {
    selectedUserName = userName ?? selectedUserName;
    selectedStartDate = startDate;
    selectedEndDate = endDate;
    emit(TaskLoaded(_filterTasks(), users));
  }

  /// Filter Logic (By User & Date)
  List<TaskModel> _filterTasks() {
    return allTasks
        .where((task) {
      final deadline = task.deadline ?? DateTime.now();
      return (selectedUserName == null ||
          selectedUserName == "All Users" ||
          task.assignedToUserName == selectedUserName) &&
          (selectedStartDate == null ||
              deadline.isAfter(selectedStartDate!.subtract(const Duration(days: 1)))) &&
          (selectedEndDate == null ||
              deadline.isBefore(selectedEndDate!.add(const Duration(days: 1))));
    })
        .toList()
      ..sort(_sortTasks);
  }

  /// Custom Sorting Logic
  int _sortTasks(TaskModel a, TaskModel b) {
    final statusA = a.status ?? 'pending';
    final statusB = b.status ?? 'pending';

    if ((statusA == "Done" || statusA == "Cancelled") &&
        (statusB == "Done" || statusB == "Cancelled")) {
      return (b.lastUpdateTime ?? DateTime.now())
          .compareTo(a.lastUpdateTime ?? DateTime.now());
    } else if (statusA == "Done" || statusA == "Cancelled") {
      return 1;
    } else if (statusB == "Done" || statusB == "Cancelled") {
      return -1;
    } else {
      return (a.deadline ?? DateTime.now())
          .compareTo(b.deadline ?? DateTime.now());
    }
  }

  /// Add Task
  Future<void> addTask(TaskModel task) async {
    try {
      emit(TaskLoading());
      final currentUserInfo = await accountRepository.getUserInfo();
      final currentUserId = currentUserInfo?.userId ?? '';
      final currentUserName = currentUserInfo?.userName ?? "Unknown";

      TaskModel updatedTask = task.copyWith(
        taskId: task.taskId ?? '',
        assignedToUserName: _getUserNameById(task.assignedTo ?? '', users),
        createdBy: task.createdBy ?? currentUserId,
        lastUpdateTime: DateTime.now(),
        lastUpdatedBy: currentUserId,
        lastUpdatedByUserName: currentUserName,
      );

      await _taskService.createTask(updatedTask);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  /// Update Task
  Future<void> updateTask(String? taskId, TaskModel task) async {
    try {
      emit(TaskLoading());
      final currentUserInfo = await accountRepository.getUserInfo();
      final currentUserId = currentUserInfo?.userId ?? '';
      final currentUserName = currentUserInfo?.userName ?? "Unknown";

      TaskModel updatedTask = task.copyWith(
        taskId: taskId ?? task.taskId ?? '',
        assignedToUserName: _getUserNameById(task.assignedTo ?? '', users),
        lastUpdateTime: DateTime.now(),
        lastUpdatedBy: currentUserId,
        lastUpdatedByUserName: currentUserName,
      );

      await _taskService.updateTask(taskId ?? '', updatedTask);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  /// Delete Task
  Future<void> deleteTask(String taskId) async {
    try {
      emit(TaskLoading());
      await _taskService.deleteTask(taskId);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  /// Filter Tasks by Assigned User Name
  void filterTasksByUser(String? userName) {
    selectedUserName = userName ?? "All Users";
    emit(TaskLoaded(_filterTasks(), users));
  }

  /// Get Unique Statuses
  List<String> getUniqueStatuses(List<TaskModel> tasks) {
    return tasks
        .map((task) => task.status ?? 'pending')
        .toSet()
        .toList();
  }

  /// Get User Name from ID
  String _getUserNameById(String userId, List<UserInfo> users) {
    final user = users.firstWhere(
          (user) => user.userId == userId,
      orElse: () => UserInfo(userName: "Unknown User"),
    );
    return user.userName ?? "Unknown User";
  }
}