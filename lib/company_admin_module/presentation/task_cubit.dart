import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/task_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskService _taskService;

  TaskCubit(this._taskService) : super(TaskInitial());

  Future<void> fetchTasks() async {
    try {
      emit(TaskLoading());
      final tasks = await _taskService.getAllTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      emit(TaskLoading());
      await _taskService.createTask(task);
      await fetchTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> updateTask(String taskId, TaskModel task) async {
    try {
      emit(TaskLoading());
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
}
