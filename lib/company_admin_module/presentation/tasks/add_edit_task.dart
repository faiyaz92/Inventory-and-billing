import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

@RoutePage()
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
  String? selectedUserName;
  String? selectedStatus;
  late TaskCubit taskCubit;

  @override
  void initState() {
    super.initState();
    taskCubit = sl<TaskCubit>()
      ..fetchTasks()
      ..loadTaskSettings();

    if (widget.task != null) {
      titleController.text = widget.task!.title ?? '';
      descriptionController.text = widget.task!.description ?? '';
      selectedUserId = widget.task!.assignedTo;
      selectedUserName = widget.task!.assignedToUserName;
      selectedStatus = widget.task?.status;
      deadlineController.text = widget.task!.deadline != null
          ? DateFormat('dd-MM-yyyy').format(widget.task!.deadline!)
          : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.task != null;
    return BlocProvider(
      create: (context) => taskCubit,
      child: Scaffold(
        appBar: CustomAppBar(title: isEditing ? "Edit Task" : "Add Task"),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<TaskCubit, TaskState>(
            buildWhen: (pre, cur) {
              return cur is TaskLoading ||
                  cur is TaskLoaded ||
                  cur is TaskError;
            },
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskLoaded) {
                taskCubit.loadTaskSettings();
                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(titleController, "Title"),
                        _buildUserDropdown(state),
                        _buildStatusDropdown(state),
                        _buildDateField(),
                        _buildTextFieldDescription(
                            descriptionController, "Description"),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _onSubmit,
                            child: Text(
                                isEditing ? "Update Task" : "Create Task"),
                          ),
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16.0,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _buildTextFieldDescription(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        maxLines: 10,
        maxLength: 500,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16.0,
          ),
          alignLabelWithHint: false,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          counterText: "",
        ),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _buildUserDropdown(TaskLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: DropdownButtonFormField<String>(
        value: state.users.any((user) => user.userId == selectedUserId)
            ? selectedUserId
            : null,
        items: state.users.map((user) {
          return DropdownMenuItem(
            value: user.userId,
            child: Text(user.userName ?? "Unknown"),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedUserId = newValue;
            final user = state.users.firstWhere(
                  (user) => user.userId == newValue,
              orElse: () => UserInfo(userId: null, userName: ''),
            );
            selectedUserName = user.userName ?? '';
          });
        },
        validator: (value) => value == null ? 'Select User' : null,
        decoration: InputDecoration(
          labelText: "Assigned To",
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16.0,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        style: const TextStyle(fontSize: 16.0, color: Colors.black),
      ),
    );
  }

  Widget _buildStatusDropdown(TaskLoaded state) {
    return BlocBuilder<TaskCubit, TaskState>(
      buildWhen: (previous, current) => current is TaskSettingsLoaded,
      builder: (context, state) {
        List<String> statuses = [];

        if (state is TaskSettingsLoaded) {
          statuses = state.taskStatuses;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: DropdownButtonFormField<String>(
              value: statuses.contains(selectedStatus) ? selectedStatus : null,
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
              validator: (value) => value == null ? 'Select Status' : null,
              decoration: InputDecoration(
                labelText: "Select Status",
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.0,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: deadlineController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Deadline (DD-MM-YYYY)",
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16.0,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today,
                color: Theme.of(context).primaryColor),
            onPressed: () => selectDate(context, deadlineController),
          ),
        ),
        style: const TextStyle(fontSize: 16.0),
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

    // Convert DD-MM-YYYY to YYYY-MM-DD for parsing
    String formattedDate = '';
    try {
      final parts = deadlineController.text.split('-');
      if (parts.length == 3) {
        formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid date format")),
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
      deadline: DateTime.tryParse(formattedDate) ?? DateTime.now(),
      assignedToUserName: selectedUserName ?? '',
      createdAt: widget.task?.createdAt,
    );

    if (widget.task != null) {
      taskCubit.updateTask(task.taskId, task);
    } else {
      taskCubit.addTask(task);
    }
    sl<Coordinator>().navigateBack(isUpdated: true);
  }
}

Future<void> selectDate(
    BuildContext context, TextEditingController controller) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null) {
    controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
  }
}