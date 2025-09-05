import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employess_list_cubit.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

@RoutePage()
class EmployeesPage extends StatefulWidget {
  const EmployeesPage({Key? key}) : super(key: key);

  @override
  EmployeesPageState createState() => EmployeesPageState();
}

class EmployeesPageState extends State<EmployeesPage> {
  bool _showMap = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    // _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    setState(() {
      _locationPermissionGranted = true;
    });
  }

  void _updateMarkers(List<UserInfo> users) {
    setState(() {
      _markers = users
          .asMap()
          .entries
          .where((entry) => entry.value.latitude != null && entry.value.longitude != null)
          .map((entry) {
        final user = entry.value;
        final index = entry.key;
        return Marker(
          markerId: MarkerId('user_$index'),
          position: LatLng(user.latitude!, user.longitude!),
          infoWindow: InfoWindow(
            title: user.name ?? 'User',
            snippet: user.email ?? 'No Email',
          ),
        );
      })
          .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EmployeeCubit>()..fetchUsers(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: "User Management",
          actions: [
            Row(
              children: [
                const Text('Map View'),
                Switch(
                  value: _showMap,
                  onChanged: (value) {
                    setState(() {
                      _showMap = value;
                    });
                  },
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.event),
              onPressed: () {
                sl<Coordinator>().navigateToAttendancePage();
                },
            ),
          ],
        ),
        body: BlocConsumer<EmployeeCubit, EmployeesState>(
          listener: (context, state) {
            if (state is UserListLoaded) {
              _updateMarkers(state.users);
            }
          },
          builder: (context, state) {
            if (state is UserListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserListError) {
              return Center(child: Text("Error: ${state.error}"));
            } else if (state is UserListLoaded) {
              return _showMap
                  ? _buildMapView(state.users)
                  : _buildUserList(context, state.users, state.payableSalaries);
            }
            return const Center(child: Text("No Users Available"));
          },
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<UserInfo> users, Map<String, double> payableSalaries) {
    final totalPayable = payableSalaries.values.fold(0.0, (sum, s) => sum + s);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total Payable Salary: IQD ${totalPayable.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserInfo user = users[index];
              final payableSalary = payableSalaries[user.userId] ?? 0.0;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(user.name ?? "No Name"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email ?? "No Email"),
                      Text('Payable: IQD ${payableSalary.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        sl<Coordinator>().navigateToAddUserPage(user: user);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, user.userId ?? '');
                      } else if (value == 'details') {
                        sl<Coordinator>().navigateToEmployeeDetailsPage(userId: user.userId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      const PopupMenuItem(value: 'details', child: Text('Details')),
                    ],
                  ),
                  onTap: () {
                    sl<Coordinator>().navigateToEmployeeDetailsPage(userId: user.userId);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView(List<UserInfo> users) {
    if (!_locationPermissionGranted) {
      return const Center(child: Text('Location permission not granted'));
    }
    if (_markers.isEmpty) {
      return const Center(child: Text('No location data available for users'));
    }
    const defaultCenter = LatLng(37.7749, -122.4194);
    final initialPosition = _markers.isNotEmpty ? _markers.first.position : defaultCenter;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 12,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.read<EmployeeCubit>().deleteUser(userId);
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}