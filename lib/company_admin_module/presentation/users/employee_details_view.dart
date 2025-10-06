import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employee_details_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class EmployeeDetailsPage extends StatelessWidget {
  final String userId;

  const EmployeeDetailsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmployeeDetailsCubit(sl<UserServices>())..loadData(userId),
      child: EmployeeDetailsBody(userId: userId),
    );
  }
}

class EmployeeDetailsBody extends StatefulWidget {
  final String userId;

  const EmployeeDetailsBody({Key? key, required this.userId}) : super(key: key);

  @override
  EmployeeDetailsBodyState createState() => EmployeeDetailsBodyState();
}

class EmployeeDetailsBodyState extends State<EmployeeDetailsBody> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: 'Employee Details'),
      body: BlocConsumer<EmployeeDetailsCubit, EmployeeDetailsState>(
        listener: (context, state) {
          if (state is EmployeeDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red[600],
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EmployeeDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EmployeeDetailsLoaded) {
            // Calculate attendance counts
            final presentCount = state.attendance
                .where((a) => a.status.toLowerCase() == 'present')
                .length;
            final halfDayCount = state.attendance
                .where((a) => a.status.toLowerCase() == 'half_day')
                .length;
            final absentCount = state.attendance
                .where((a) => a.status.toLowerCase() == 'absent')
                .length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    decoration: InputDecoration(
                      labelText: 'Select Month',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    items: List.generate(12, (index) {
                      final date = DateTime.now().subtract(Duration(days: index * 30));
                      return DropdownMenuItem(
                        value: DateFormat('yyyy-MM').format(date),
                        child: Text(DateFormat('MMMM yyyy').format(date)),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                        });
                        context.read<EmployeeDetailsCubit>().loadData(widget.userId, month: value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            state.user.name ?? 'Unknown',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          subtitle: Text(
                            'Advance Balance: IQD ${state.advanceBalance.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Attendance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Attendance Summary Card
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Present: $presentCount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Half Day: $halfDayCount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Absent: $absentCount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Table(
                            border: TableBorder.all(color: Colors.grey.shade300),
                            columnWidths: {
                              0: FlexColumnWidth((screenWidth - 32) * 0.5),
                              1: FlexColumnWidth((screenWidth - 32) * 0.5),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900],
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              ...state.attendance.map((model) {
                                final status = model.status.toUpperCase();
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        model.date, // Already dd-MM-yyyy
                                        style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: status.toLowerCase().contains('present')
                                              ? Colors.green[600]
                                              : status.toLowerCase().contains('half day')
                                              ? Colors.orange[600]
                                              : Colors.red[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Ledger',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Table(
                            border: TableBorder.all(color: Colors.grey.shade300),
                            columnWidths: {
                              0: FlexColumnWidth((screenWidth - 32) * 0.33),
                              1: FlexColumnWidth((screenWidth - 32) * 0.33),
                              2: FlexColumnWidth((screenWidth - 32) * 0.33),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900],
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Type',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              ...state.ledger.map((record) {
                                final type = record['type'].toString().toUpperCase();
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        record['date'],
                                        style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: type.toLowerCase().contains('credit')
                                              ? Colors.green[600]
                                              : Colors.red[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'IQD ${(record['amount'] as double).toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            context,
                            label: 'Credit',
                            color: Colors.green[600],
                            onPressed: () async {
                              final amount = await _showAmountDialog(context, 'Credit Advance');
                              if (amount != null) {
                                await context.read<EmployeeDetailsCubit>().recordAdvanceSalary(
                                  widget.userId,
                                  amount,
                                  DateTime.now().toIso8601String().substring(0, 10),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Credit recorded successfully'),
                                    backgroundColor: Colors.green[600],
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                          ),
                          _buildActionButton(
                            context,
                            label: 'Debit',
                            color: Colors.red[600],
                            onPressed: () async {
                              final amount = await _showAmountDialog(context, 'Debit Salary');
                              if (amount != null) {
                                await context.read<EmployeeDetailsCubit>().recordSalaryPayment(
                                  widget.userId,
                                  amount,
                                  _selectedMonth,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Debit recorded successfully'),
                                    backgroundColor: Colors.green[600],
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                          ),
                          _buildActionButton(
                            context,
                            label: 'Finalize Month',
                            color: Colors.blue[700],
                            onPressed: () async {
                              await context.read<EmployeeDetailsCubit>().finalizeMonth(widget.userId, _selectedMonth);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Month finalized'),
                                  backgroundColor: Colors.green[600],
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(
            child: Text(
              'No Data Available',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String label,
        required Color? color,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: const TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Future<double?> _showAmountDialog(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(title, style: TextStyle(color: Colors.grey[900])),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount (IQD )',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.blue[700]!),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Enter a valid amount'),
                    backgroundColor: Colors.red[600],
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text('OK', style: TextStyle(color: Colors.blue[700])),
          ),
        ],
      ),
    );
  }
}