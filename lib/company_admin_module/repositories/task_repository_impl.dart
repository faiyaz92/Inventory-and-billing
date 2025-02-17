import 'package:requirment_gathering_app/company_admin_module/data/task_model_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/task_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class TaskRepositoryImpl implements TaskRepository {
  final IFirestorePathProvider _firestorePathProvider;

  TaskRepositoryImpl(this._firestorePathProvider);

  @override
  Future<void> createTask(TaskDto taskDto) async {
    await _firestorePathProvider
        .getTaskCollectionRef(taskDto.companyId!)
        .add(taskDto.toMap());
  }

  @override
  Future<void> updateTask(String taskId, TaskDto taskDto) async {
    await _firestorePathProvider
        .getSingleTaskRef(taskDto.companyId!, taskId)
        .update(taskDto.toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _firestorePathProvider.getSingleTaskRef(taskId, taskId).delete();
  }

  @override
  Future<List<TaskDto>> getAllTasks(String companyId) async {
    final snapshot =
        await _firestorePathProvider.getTaskCollectionRef(companyId).get();

    return snapshot.docs
        .map((doc) => TaskDto.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
