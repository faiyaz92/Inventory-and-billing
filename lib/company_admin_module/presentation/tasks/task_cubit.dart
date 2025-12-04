import 'package:bloc/bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart'; // Import for UserType
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskService _taskService;
  final UserServices _companyOperationsService;
  final CustomerCompanyService _companyService;
  final AccountRepository accountRepository;

  late CompanySettingsUi companySettingsUi;
  late List<UserInfo> users; // Will only contain employees
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

  Future<void> fetchTasks({bool isNeedToShow = true}) async {
    try {
      selectedUserName = null;
      if (isNeedToShow) {
        emit(TaskLoading());
      }
      final userInfo = await accountRepository.getUserInfo();
      allTasks = await _taskService.getAllTasks();
      users = (await _companyOperationsService.getUsersFromTenantCompany())
          .where((user) => user.userType == UserType.Employee)
          .toList();

      print('fetchTasks: Filtered users to employees only, count = ${users.length}, user IDs = ${users.map((u) => u.userId).toList()}');

      if (selectedUserName == null && userInfo?.userId != null && userInfo?.userType == UserType.Employee) {
        final currentUser = users.firstWhere(
              (user) => user.userId == userInfo?.userId,
          orElse: () => UserInfo(userName: "All Users", userType: UserType.Employee),
        );
        selectedUserName = currentUser.userName;
      } else {
        selectedUserName ??= "All Users";
      }

      print('fetchTasks: selectedUserName = $selectedUserName');

      allTasks.sort(_sortTasks);

      emit(TaskLoaded(_filterTasks(), users, isLoading: isNeedToShow));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void filterTasks({String? userName, DateTime? startDate, DateTime? endDate}) {
    selectedUserName = userName ?? selectedUserName;
    selectedStartDate = startDate;
    selectedEndDate = endDate;
    print('filterTasks: selectedUserName = $selectedUserName, startDate = $selectedStartDate, endDate = $selectedEndDate');
    emit(TaskLoaded(_filterTasks(), users));
  }

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

  Future<void> addTask(TaskModel task) async {
    try {
      emit(TaskLoading());
      final currentUserInfo = await accountRepository.getUserInfo();
      final currentUserId = currentUserInfo?.userId ?? '';
      final currentUserName = currentUserInfo?.userName ?? "Unknown";

      final assignedUser = users.firstWhere(
            (user) => user.userId == task.assignedTo,
        orElse: () => UserInfo(userName: "Unknown User", userType: UserType.Employee),
      );
      if (assignedUser.userType != UserType.Employee) {
        throw Exception("Assigned user must be an employee");
      }

      TaskModel updatedTask = task.copyWith(
        taskId: task.taskId ?? '',
        assignedToUserName: _getUserNameById(task.assignedTo ?? '', users),
        createdBy: task.createdBy ?? currentUserId,
        lastUpdateTime: DateTime.now(),
        lastUpdatedBy: currentUserId,
        lastUpdatedByUserName: currentUserName,
      );

      print('addTask: Assigning task to ${updatedTask.assignedToUserName} (employee)');

      await _taskService.createTask(updatedTask);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> updateTask(String? taskId, TaskModel task) async {
    try {
      emit(TaskLoading());
      final currentUserInfo = await accountRepository.getUserInfo();
      final currentUserId = currentUserInfo?.userId ?? '';
      final currentUserName = currentUserInfo?.userName ?? "Unknown";

      final assignedUser = users.firstWhere(
            (user) => user.userId == task.assignedTo,
        orElse: () => UserInfo(userName: "Unknown User", userType: UserType.Employee),
      );
      if (assignedUser.userType != UserType.Employee) {
        throw Exception("Assigned user must be an employee");
      }

      TaskModel updatedTask = task.copyWith(
        taskId: taskId ?? task.taskId ?? '',
        assignedToUserName: _getUserNameById(task.assignedTo ?? '', users),
        lastUpdateTime: DateTime.now(),
        lastUpdatedBy: currentUserId,
        lastUpdatedByUserName: currentUserName,
      );

      print('updateTask: Updating task for ${updatedTask.assignedToUserName} (employee)');

      await _taskService.updateTask(taskId ?? '', updatedTask);
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

  void filterTasksByUser(String? userName) {
    selectedUserName = userName ?? "All Users";
    print('filterTasksByUser: selectedUserName = $selectedUserName');
    emit(TaskLoaded(_filterTasks(), users));
  }

  List<String> getUniqueStatuses(List<TaskModel> tasks) {
    return tasks
        .map((task) => task.status ?? 'pending')
        .toSet()
        .toList();
  }

  String _getUserNameById(String userId, List<UserInfo> users) {
    final user = users.firstWhere(
          (user) => user.userId == userId && user.userType == UserType.Employee,
      orElse: () => UserInfo(userName: "Unknown User", userType: UserType.Employee),
    );
    print('getUserNameById: userId = $userId, resolved userName = ${user.userName}');
    return user.userName ?? "Unknown User";
  }
}
