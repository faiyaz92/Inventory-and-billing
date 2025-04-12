import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with TickerProviderStateMixin {
  late TaskCubit _taskCubit;
  TabController? _tabController;
  List<String> _statuses = [];
  List<String> _allStatuses = [];

  @override
  void initState() {
    super.initState();
    _taskCubit = sl<TaskCubit>()
      ..fetchTasks()
      ..loadTaskSettings();
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
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is TaskLoaded || state is TaskSettingsLoaded) {
            if (state is TaskSettingsLoaded) {
              _allStatuses = state.taskStatuses;
            }

            final tasks = state is TaskLoaded ? state.tasks:<TaskModel>[];
            _statuses = _taskCubit
                .getUniqueStatuses(tasks)
                .where((status) =>
                    tasks.any((task) => (task.status ?? 'pending') == status))
                .toList();

            if (_tabController == null ||
                _tabController!.length != _statuses.length) {
              _tabController?.dispose();
              _tabController =
                  TabController(length: _statuses.length, vsync: this);
            }

            return Scaffold(
              appBar: const CustomAppBar(title: "Task List"),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final result =
                      await sl<Coordinator>().navigateToAddTaskPage();
                  if (result) {
                    _taskCubit = sl<TaskCubit>()
                      ..fetchTasks()
                      ..loadTaskSettings();
                  }
                },
                child: const Icon(Icons.add),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildUserFilterDropdown(
                        state is TaskLoaded ? state.users : []),
                    _buildDateFilter(),
                    if (_statuses.isNotEmpty)
                      TabBar(
                        controller: _tabController,
                        tabs: _statuses
                            .map((status) => Tab(text: status))
                            .toList(),
                      ),
                    Expanded(
                      child: _statuses.isEmpty
                          ? const Center(child: Text("No tasks available"))
                          : TabBarView(
                              controller: _tabController,
                              children: _statuses.map((status) {
                                return _buildTaskList(tasks, status);
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: Text("Failed to load tasks")),
            );
          }
        },
      ),
    );
  }

  /// User Filter Dropdown
  Widget _buildUserFilterDropdown(List<UserInfo> users) {
    List<String> uniqueUsers =
        users.map((user) => user.userName ?? "Unknown").toSet().toList();
    uniqueUsers.insert(0, "All Users");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        value: _taskCubit.selectedUserName,
        decoration: const InputDecoration(
          labelText: "Filter by Assigned User",
          border: OutlineInputBorder(),
        ),
        items: uniqueUsers.map((user) {
          return DropdownMenuItem(value: user, child: Text(user));
        }).toList(),
        onChanged: (newValue) {
          _taskCubit
              .filterTasksByUser(newValue); // Updates selectedUserName in Cubit
        },
      ),
    );
  }

  /// Due Date Filter UI
  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDatePicker("Start Date", _taskCubit.selectedStartDate, (date) {
            if (date != null &&
                _taskCubit.selectedEndDate != null &&
                date.isAfter(_taskCubit.selectedEndDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Start Date cannot be after End Date")),
              );
            } else {
              setState(() {
                _taskCubit.selectedStartDate = date;
                _taskCubit.filterTasks(
                    startDate: date, endDate: _taskCubit.selectedEndDate);
              });
            }
          }),
          const SizedBox(width: 10),
          _buildDatePicker("End Date", _taskCubit.selectedEndDate, (date) {
            if (date != null &&
                _taskCubit.selectedStartDate != null &&
                date.isBefore(_taskCubit.selectedStartDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("End Date cannot be before Start Date")),
              );
            } else {
              setState(() {
                _taskCubit.selectedEndDate = date;
                _taskCubit.filterTasks(
                    startDate: _taskCubit.selectedStartDate, endDate: date);
              });
            }
          }),
        ],
      ),
    );
  }

  /// Date Picker
  Widget _buildDatePicker(
      String label, DateTime? selectedDate, Function(DateTime?) onDatePicked) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            onDatePicked(pickedDate);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            selectedDate != null ? _formatDate(selectedDate) : label,
            style: TextStyle(
              color: selectedDate != null ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  /// Format Date to Readable String (with optional time)
  String _formatDate(DateTime date, {bool includeTime = false}) {
    final baseDate =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    if (includeTime) {
      return "$baseDate ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return baseDate;
  }

  Widget _buildTaskList(List<TaskModel> allTasks, String statusFilter) {
    List<TaskModel> filteredTasks = allTasks
        .where((task) =>
            (task.status ?? 'pending') == statusFilter &&
            (_taskCubit.selectedUserName == null ||
                _taskCubit.selectedUserName == "All Users" ||
                task.assignedToUserName == _taskCubit.selectedUserName))
        .toList()
      ..sort((a, b) {
        final statusA = a.status ?? 'pending';
        final statusB = b.status ?? 'pending';
        if (statusA == "Done" || statusA == "Cancelled") {
          return (b.lastUpdateTime ?? DateTime.now())
              .compareTo(a.lastUpdateTime ?? DateTime.now());
        } else {
          return (a.deadline ?? DateTime.now())
              .compareTo(b.deadline ?? DateTime.now());
        }
      });

    if (filteredTasks.isEmpty) {
      return const Center(child: Text("No tasks for this filter."));
    }

    Map<String, List<TaskModel>> groupedTasks = {};
    for (var task in filteredTasks) {
      String dateKey = _formatDate(task.deadline ?? DateTime.now());
      if (!groupedTasks.containsKey(dateKey)) {
        groupedTasks[dateKey] = [];
      }
      groupedTasks[dateKey]!.add(task);
    }

    return ListView.builder(
      itemCount: groupedTasks.length,
      itemBuilder: (context, index) {
        String dateKey = groupedTasks.keys.elementAt(index);
        List<TaskModel> tasksForDate = groupedTasks[dateKey]!;
        return StickyHeader(
          header: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blueGrey[700]),
            child: Text(
              dateKey,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          content: Column(
            children: tasksForDate.map((task) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    task.title ?? "Untitled Task",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Assigned to: ${task.assignedToUserName ?? 'Unknown'}"),
                      Text(
                        "Due Date: ${_formatDate(task.deadline ?? DateTime.now())}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      Text(
                          "Created At: ${_formatDate(task.createdAt ?? DateTime.now())}"),
                      Text(
                        "Last Updated: ${_formatDate(task.lastUpdateTime ?? DateTime.now(), includeTime: true)} by ${task.lastUpdatedByUserName ?? 'Unknown'}",
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await sl<Coordinator>()
                        .navigateToAddTaskPage(task: task);
                    if (result) {
                      // refresh
                      _taskCubit = sl<TaskCubit>()
                        ..fetchTasks()
                        ..loadTaskSettings();
                    }
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "delete") {
                        _showDeleteConfirmation(context, task.taskId ?? '');
                      } else {
                        final updatedTask = task.copyWith(status: value);
                        _taskCubit.updateTask(updatedTask.taskId, updatedTask);
                      }
                    },
                    itemBuilder: (context) => [
                      ..._allStatuses.map((status) {
                        return PopupMenuItem(
                            value: status, child: Text(status));
                      }).toList(),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("🗑 Delete Task",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Delete Confirmation Dialog
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
                child: const Text("Cancel")),
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
