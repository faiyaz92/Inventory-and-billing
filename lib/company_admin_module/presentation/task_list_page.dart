import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/task_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/task_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskCubit>()..fetchTasks(),
      child: _TaskListView(),
    );
  }
}

class _TaskListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sl<Coordinator>().navigateToAddTaskPage();
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.status),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          sl<Coordinator>().navigateToAddTaskPage(task: task);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmation(context, task.taskId);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No tasks found."));
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.read<TaskCubit>().deleteTask(taskId);
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
