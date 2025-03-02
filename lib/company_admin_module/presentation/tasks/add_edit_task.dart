import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_state.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class AddTaskPage extends StatefulWidget {
  final TaskModel? task;

  const AddTaskPage({Key? key, this.task}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  String? selectedUserId;
  String? selectedStatus;
  late TaskCubit taskCubit;

  @override
  void initState() {
    super.initState();
    taskCubit = sl<TaskCubit>()
      ..fetchTasks()..loadTaskSettings();

    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      selectedUserId = widget.task!.assignedTo;
      selectedStatus = widget.task?.status;
      deadlineController.text = widget.task!.deadline.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.task != null;
    return BlocProvider(
      create: (context) => taskCubit,
      child: Scaffold(
        appBar: AppBar(title: Text(isEditing ? "Edit Task" : "Add Task")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<TaskCubit, TaskState>(
            buildWhen: (pre,cur){
              return cur is  TaskLoading ||  cur is TaskLoaded || cur is TaskError;
            },
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskLoaded) {
                taskCubit.loadTaskSettings();
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(titleController, "Title"),
                      _buildTextField(descriptionController, "Description"),
                      _buildDropdown(state),
                      _buildStatusDropdown(context),
                      _buildDateField(),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _onSubmit,
                          child: Text(isEditing ? "Update Task" : "Create Task"),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text("Error loading users"));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(TaskLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedUserId,
        onChanged: (newValue) {
          setState(() {
            selectedUserId = newValue;
          });
        },
        items: state.users.map((user) {
          return DropdownMenuItem(
            value: user.userId,
            child: Text(user.userName ?? "Unknown"),
          );
        }).toList(),
        decoration: const InputDecoration(
          labelText: "Assigned To",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      buildWhen: (previous, current) => current is TaskSettingsLoaded,
      builder: (context, state) {
        List<String> statuses = [];

        if (state is TaskSettingsLoaded) {
          statuses = state.taskStatuses;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),  // Same padding as _buildDropdown
            child: DropdownButtonFormField<String>(
              value: statuses.isNotEmpty ? selectedStatus : null,
              decoration: const InputDecoration(
                labelText: "Select Status",
                border: OutlineInputBorder(),  // 🔥 Border added here
              ),
              items: statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
          );
        }

       return const SizedBox.shrink();
      },
    );
  }


  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: deadlineController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Deadline (YYYY-MM-DD)",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => selectDate(context, deadlineController),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedUserId == null ||
        selectedStatus == null ||
        deadlineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    final task = TaskModel(
      taskId: widget.task?.taskId ?? "",
      title: titleController.text,
      description: descriptionController.text,
      assignedTo: selectedUserId!,
      createdBy: "Admin",
      status: selectedStatus ?? '',
      deadline: DateTime.tryParse(deadlineController.text) ?? DateTime.now(),
      assignedToUserName: '',
    );

    if (widget.task != null) {
      taskCubit.updateTask(task.taskId, task);
    } else {
      taskCubit.addTask(task);
    }

    Navigator.pop(context);
  }
}

/// **Date Picker Dialog (No Past Dates Allowed)**
Future<void> selectDate(
    BuildContext context, TextEditingController controller) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null) {
    controller.text = pickedDate.toIso8601String().split("T")[0];
  }
}

/// **Task Status Enum**
enum TaskStatus { Pending, Done, Snoozed }
