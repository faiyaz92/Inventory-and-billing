import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> with TickerProviderStateMixin {
  late TaskCubit _taskCubit;
  TabController? _tabController;
  List<String> _statuses = [];
  List<String> _allStatuses = [];

  @override
  void initState() {
    super.initState();
    _taskCubit = sl<TaskCubit>()..fetchTasks()..loadTaskSettings();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _taskCubit,
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            // ✅ Show Loading Spinner (Instead of Black Screen)
            return const Scaffold(
              backgroundColor: Colors.white, // Prevent Black Screen
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is TaskLoaded || state is TaskSettingsLoaded) {
            if (state is TaskSettingsLoaded) {
              _allStatuses = state.taskStatuses;
            }

            // ✅ Ensure TabController updates only once
            final newStatuses = _taskCubit.getUniqueStatuses(state is TaskLoaded ? state.tasks : []);
            if (_tabController == null || _statuses.length != newStatuses.length) {
              _statuses = newStatuses;
              _tabController?.dispose();
              _tabController = TabController(length: _statuses.length, vsync: this);
            }

            return Scaffold(
              appBar: AppBar(title: const Text("Task List")),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  sl<Coordinator>().navigateToAddTaskPage();
                },
                child: const Icon(Icons.add),
              ),
              body: _statuses.isEmpty
                  ? const Center(child: Text("No tasks available")) // ✅ Prevents Empty Black Screen
                  : Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: _statuses.map((status) => Tab(text: status)).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _statuses.map((status) {
                        return _buildTaskList(state is TaskLoaded ? state.tasks : [], status);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Scaffold(
              backgroundColor: Colors.white, // ✅ Prevent Black Screen
              body: Center(child: Text("Failed to load tasks")),
            );
          }
        },
      ),
    );
  }

  /// ✅ **Task List with Edit, Status Update & Delete**
  Widget _buildTaskList(List<TaskModel> allTasks, String statusFilter) {
    List<TaskModel> filteredTasks = allTasks.where((task) => task.status == statusFilter).toList();

    if (filteredTasks.isEmpty) {
      return const Center(child: Text("No tasks for this status."));
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // ✅ Add spacing
          elevation: 4, // ✅ Creates an elevated look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // ✅ Rounded corners
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ✅ Better spacing inside
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Assigned to: ${task.assignedToUserName}"),
            onTap: () {
              sl<Coordinator>().navigateToAddTaskPage(task: task);
            },
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "delete") {
                  _showDeleteConfirmation(context, task.taskId);
                } else {
                  final updatedTask = task.copyWith(status: value);
                  _taskCubit.updateTask(updatedTask.taskId, updatedTask);
                }
              },
              itemBuilder: (context) => [
                ..._allStatuses.map((status) {
                  return PopupMenuItem(value: status, child: Text(status));
                }).toList(),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: "delete",
                  child: Text("🗑 Delete Task", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔥 **Delete Confirmation Dialog**
  void _showDeleteConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                _taskCubit.deleteTask(taskId);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
