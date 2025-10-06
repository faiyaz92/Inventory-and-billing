import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/attendance_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:table_calendar/table_calendar.dart';

@RoutePage()
class AttendanceRegisterPage extends StatefulWidget {
  const AttendanceRegisterPage({Key? key}) : super(key: key);

  @override
  State<AttendanceRegisterPage> createState() => _AttendanceRegisterPageState();
}

class _AttendanceRegisterPageState extends State<AttendanceRegisterPage> {
  late AttendanceCubit _attendanceCubit;

  @override
  void initState() {
    _attendanceCubit = AttendanceCubit(sl<UserServices>())..fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _attendanceCubit,
      child: const AttendanceRegisterBody(),
    );
  }
}

class AttendanceRegisterBody extends StatefulWidget {
  const AttendanceRegisterBody({Key? key}) : super(key: key);

  @override
  AttendanceRegisterBodyState createState() => AttendanceRegisterBodyState();
}

class AttendanceRegisterBodyState extends State<AttendanceRegisterBody> {
  late DateTime _selectedDate; // The date selected by the user (shown in AppBar)
  late DateTime _focusedDate; // The date determining the calendar's displayed month/year
  final Map<String, String> _attendanceStatus = {};
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Start with today's date selected
    _focusedDate = DateTime.now(); // Start with current month displayed
  }

  // Check if the selected date is editable (today or last 3 days)
  bool _isDateEditable(DateTime date) {
    final today = DateTime.now();
    final earliestEditable = today.subtract(const Duration(days: 3));
    return !date.isBefore(earliestEditable) &&
        (date.day <= today.day || date.month != today.month || date.year != today.year);
  }

  // Map status to highlight color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green[700]!;
      case 'absent':
        return Colors.red[700]!;
      case 'half_day':
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = _dateFormat.format(_selectedDate);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance - $formattedDate',
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.blue),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedDate = DateTime.now();
              });
              context.read<AttendanceCubit>().fetchAttendance(_dateFormat.format(_selectedDate));
            },
            tooltip: 'Jump to Today',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
        // Calendar Widget
        Card(
        margin: const EdgeInsets.all(12.0),
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1), // Allow swiping to very old dates
            lastDay: DateTime.now(), // Limit to today
            focusedDay: _focusedDate, // Controls the displayed month/year
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay; // Update selected date
                _focusedDate = focusedDay; // Update displayed month/year
              });
              // Fetch attendance for the selected date
              context.read<AttendanceCubit>().fetchAttendance(_dateFormat.format(selectedDay));
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.blue),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.blue),
            ),
            calendarStyle: CalendarStyle(
              tableBorder: const TableBorder(
                horizontalInside: BorderSide(color: Colors.grey, width: 0.5),
                verticalInside: BorderSide(color: Colors.grey, width: 0.5),
              ),
              selectedDecoration: const CircleDecoration(color: Colors.blue),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              weekendStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            daysOfWeekHeight: 24.0, // Increased height for spacing
          ),
        ),
      ),
      // Employee List as DataTable
      BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red[600],
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is AttendanceLoaded) {
            // Update _attendanceStatus with fetched attendance data
            setState(() {
              _attendanceStatus.clear();
              state.attendance.forEach((userId, attendance) {
                _attendanceStatus[userId] = attendance.status;
              });
            });
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            return SizedBox(
              width: MediaQuery.of(context).size.width, // Match screen width
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0), // Left/right spacing
                child: DataTable(
                  columnSpacing: 8.0, // Original spacing
                  dataRowHeight: 56.0,
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
                  border: const TableBorder(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                    left: BorderSide(color: Colors.grey, width: 0.5),
                    right: BorderSide(color: Colors.grey, width: 0.5),
                    horizontalInside: BorderSide(color: Colors.grey, width: 0.5),
                    verticalInside: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Employee Name',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Text(
                          'Status',
                          textAlign: TextAlign.left,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(state.users.length, (index) {
                    final user = state.users[index];
                    final isEditable = _isDateEditable(_selectedDate);
                    final status = _attendanceStatus[user.userId] ?? 'absent';
                    return DataRow(
                      color: MaterialStateColor.resolveWith(
                            (states) => index % 2 == 0 ? Colors.white : Colors.grey[50]!,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            user.name ?? 'Unknown',
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                          ),
                        ),
                        DataCell(
                          isEditable
                              ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: DropdownButton<String>(
                              value: status,
                              items: const [
                                DropdownMenuItem(value: 'present', child: Text('Present')),
                                DropdownMenuItem(value: 'absent', child: Text('Absent')),
                                DropdownMenuItem(value: 'half_day', child: Text('Half Day')),
                              ],
                              onChanged: (value) async {
                                if (value != null) {
                                  setState(() {
                                    _attendanceStatus[user.userId!] = value;
                                  });
                                  final attendance = AttendanceModel(
                                    date: formattedDate, // dd-MM-yyyy
                                    status: value,
                                  );
                                  await context
                                      .read<AttendanceCubit>()
                                      .markAttendance(user.userId!, attendance);
                                }
                              },
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: _getStatusColor(status),
                              ),
                              isDense: true,
                              underline: Container(
                                height: 1,
                                color: Colors.blue,
                              ),
                            ),
                          )
                              : Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                            child: Text(
                              status.toUpperCase(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          }
          return Center(
            child: Text(
              'No Employees Available',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          );
        },
      ),
            ],
        ),
    ),
    );
  }
}
// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase}${substring(1)}";
  }
}

// Custom CircleDecoration for TableCalendar
class CircleDecoration extends Decoration {
  final Color color;

  const CircleDecoration({required this.color});

  @override
  BoxDecoration get decoration => BoxDecoration(
    shape: BoxShape.circle,
    color: color,
  );

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CircleBoxPainter(decoration, onChanged);
  }
}

class _CircleBoxPainter extends BoxPainter {
  final BoxDecoration decoration;

  _CircleBoxPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint()
      ..color = decoration.color ?? Colors.transparent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      rect.center,
      rect.shortestSide / 2,
      paint,
    );
  }
}