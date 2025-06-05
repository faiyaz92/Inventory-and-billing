import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service.dart';

abstract class DashboardState {}

class DashboardTabState extends DashboardState {
  final int index;

  DashboardTabState(this.index);
}

class DashboardLogout extends DashboardState {}

class DashboardCubit extends Cubit<DashboardState> {
  final AuthService _authService;

  DashboardCubit(this._authService) : super(DashboardTabState(0));

  void updateIndex(int newIndex) => emit(DashboardTabState(newIndex));

  void logout() async{
   await _authService.signOut();
    emit(DashboardLogout());
  }
}