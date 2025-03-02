

import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  final List<UserInfo> users;

  TaskLoaded(this.tasks, this.users);

  @override
  List<Object> get props => [tasks, users];
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);

  @override
  List<Object> get props => [message];
}
class TaskSettingsLoaded extends TaskState {
  final List<String> taskStatuses;

  TaskSettingsLoaded(this.taskStatuses);
}
