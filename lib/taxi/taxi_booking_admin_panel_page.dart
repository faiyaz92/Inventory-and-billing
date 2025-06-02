import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_stat_card.dart';

@RoutePage()
class TaxiBookingsAdminPage extends StatefulWidget {
  const TaxiBookingsAdminPage({
    Key? key,
  }) : super(key: key);

  @override
  _TaxiBookingsAdminPageState createState() => _TaxiBookingsAdminPageState();
}

class _TaxiBookingsAdminPageState extends State<TaxiBookingsAdminPage> {
  DateTimeRange? _dateRange;
  String? _statusFilter;
  String? _selectedQuickFilter;

  void _applyQuickFilter(String filter) {
    setState(() {
      _selectedQuickFilter = filter;
      _dateRange = null;
    });
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (filter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 'Yesterday':
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 'Last 7 Days':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now.add(const Duration(days: 1));
        break;
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        endDate = now.add(const Duration(days: 1));
        break;
    }

    context.read<TaxiAdminCubit>().fetchBookings(

          startDate: startDate,
          endDate: endDate,
          status: _statusFilter,
        );
  }

  void _applyDateRangeFilter() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      setState(() {
        _dateRange = range;
        _selectedQuickFilter = null;
      });
      context.read<TaxiAdminCubit>().fetchBookings(

            startDate: range.start,
            endDate: range.end.add(const Duration(days: 1)),
            status: _statusFilter,
          );
    }
  }

  void _showStatusDialog(TaxiBooking booking) {
    final statusController = TextEditingController(text: booking.tripStatus);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: TextFormField(
          controller: statusController,
          decoration: const InputDecoration(
            labelText: 'Trip Status',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<TaxiAdminCubit>()
                  .updateBookingStatus(booking.id, statusController.text);
              Navigator.pop(context);
            },
            child: const Text('Update',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showDriverAssignDialog(TaxiBooking booking) {
    // Placeholder: Fetch drivers from UserInfo with role DRIVER
    final drivers = [
      const UserInfo(
          userId: 'driver1', userName: 'John Doe', role: Role.COMPANY_ADMIN),
      const UserInfo(
          userId: 'driver2', userName: 'Jane Smith', role: Role.COMPANY_ADMIN),
    ];
    UserInfo? selectedDriver;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Driver'),
        content: DropdownButtonFormField<UserInfo>(
          decoration: const InputDecoration(
            labelText: 'Select Driver',
            border: OutlineInputBorder(),
          ),
          value: selectedDriver,
          items: drivers
              .map((driver) => DropdownMenuItem(
                    value: driver,
                    child: Text(driver.userName ?? 'Unknown'),
                  ))
              .toList(),
          onChanged: (value) => selectedDriver = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (selectedDriver != null) {
                context
                    .read<TaxiAdminCubit>()
                    .acceptBooking(booking.id, selectedDriver!);
              }
              Navigator.pop(context);
            },
            child: const Text('Assign',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Taxi Bookings'),
      body: BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
        builder: (context, state) {
          if (state is TaxiAdminLoading) {
            return const Center(child: CustomLoadingDialog());
          } else if (state is TaxiAdminSuccess) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: AppColors.cardBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              children: [
                                StatCard(
                                    label: 'Total Bookings',
                                    value: state.bookings.length.toString()),
                                StatCard(
                                    label: "Today's Visitors",
                                    value: state.todayVisitorCount.toString()),
                                StatCard(
                                  label: 'Total Fare',
                                  value:
                                      '\$${state.bookings.fold(0.0, (sum, b) => sum + b.totalFareAmount).toStringAsFixed(2)}',
                                ),
                                StatCard(
                                  label: 'Pending',
                                  value: state.bookings
                                      .where((b) => b.tripStatus == 'pending')
                                      .length
                                      .toString(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          children: [
                            ChoiceChip(
                              label: const Text('Today'),
                              selected: _selectedQuickFilter == 'Today',
                              backgroundColor: AppColors.grey,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _selectedQuickFilter == 'Today'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              onSelected: (selected) {
                                if (selected) _applyQuickFilter('Today');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Yesterday'),
                              selected: _selectedQuickFilter == 'Yesterday',
                              backgroundColor: AppColors.grey,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _selectedQuickFilter == 'Yesterday'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              onSelected: (selected) {
                                if (selected) _applyQuickFilter('Yesterday');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Last 7 Days'),
                              selected: _selectedQuickFilter == 'Last 7 Days',
                              backgroundColor: AppColors.grey,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _selectedQuickFilter == 'Last 7 Days'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              onSelected: (selected) {
                                if (selected) _applyQuickFilter('Last 7 Days');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Last 3 Months'),
                              selected: _selectedQuickFilter == 'Last 3 Months',
                              backgroundColor: AppColors.grey,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _selectedQuickFilter == 'Last 3 Months'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              onSelected: (selected) {
                                if (selected)
                                  _applyQuickFilter('Last 3 Months');
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Custom Range'),
                              selected: _dateRange != null,
                              backgroundColor: AppColors.grey,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _dateRange != null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              onSelected: (selected) {
                                if (selected) _applyDateRangeFilter();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Filter by Status',
                            border: OutlineInputBorder(),
                          ),
                          value: _statusFilter,
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All')),
                            const DropdownMenuItem(
                                value: 'pending', child: Text('Pending')),
                            const DropdownMenuItem(
                                value: 'confirmed', child: Text('Confirmed')),
                            const DropdownMenuItem(
                                value: 'completed', child: Text('Completed')),
                            const DropdownMenuItem(
                                value: 'cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (value) {
                            setState(() => _statusFilter = value);
                            context.read<TaxiAdminCubit>().fetchBookings(

                                  status: value,
                                  startDate: _dateRange?.start,
                                  endDate: _dateRange?.end,
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final booking = state.bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: AppColors.cardBackground,
                        child: ListTile(
                          title: Text(
                            '${booking.firstName} ${booking.lastName}',
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            'Status: ${booking.tripStatus} | Fare: \$${booking.totalFareAmount.toStringAsFixed(2)}',
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (booking.accepted)
                                Text(
                                  'Driver: ${booking.acceptedByDriverName}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: AppColors.primary),
                                onPressed: () => _showStatusDialog(booking),
                              ),
                              if (!booking.accepted)
                                IconButton(
                                  icon: const Icon(Icons.person_add,
                                      color: AppColors.primary),
                                  onPressed: () =>
                                      _showDriverAssignDialog(booking),
                                ),
                            ],
                          ),
                          onTap: () {
                            // Placeholder: Navigate to details page
                            // sl<Coordinator>().navigateToTaxiBookingDetailsPage(booking.id);
                          },
                        ),
                      );
                    },
                    childCount: state.bookings.length,
                  ),
                ),
              ],
            );
          } else if (state is TaxiAdminError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.red),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
