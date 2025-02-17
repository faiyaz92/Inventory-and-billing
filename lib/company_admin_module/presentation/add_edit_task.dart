import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/task_cubit.dart';

class AddTaskPage extends StatefulWidget {
  final TaskModel? task;

  const AddTaskPage({Key? key, this.task}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController assignedToController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      statusController.text = widget.task!.status;
      assignedToController.text = widget.task!.assignedTo;
      deadlineController.text = widget.task!.deadline.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Task" : "Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title")),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description")),
            TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: "Status")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final task = TaskModel(
                  taskId: widget.task?.taskId ?? "",
                  title: titleController.text,
                  description: descriptionController.text,
                  assignedTo: assignedToController.text,
                  createdBy: "Admin",
                  status: statusController.text,
                  deadline: DateTime.parse(deadlineController.text),
                );

                isEditing
                    ? context.read<TaskCubit>().updateTask(task.taskId, task)
                    : context.read<TaskCubit>().addTask(task);
              },
              child: Text(isEditing ? "Update Task" : "Create Task"),
            ),
          ],
        ),
      ),
    );
  }
}
