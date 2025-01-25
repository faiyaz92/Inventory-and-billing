import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<int> {
  DashboardCubit() : super(0); // Initial index is 0 (Home tab)

  void updateIndex(int newIndex) => emit(newIndex);
}
