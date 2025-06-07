import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';

@RoutePage()
class TaxiBookingPage extends StatelessWidget {
  const TaxiBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaxiBookingCubit>(),
      child: const _TaxiBookingView(),
    );
  }
}

class _TaxiBookingView extends StatefulWidget {
  const _TaxiBookingView();

  @override
  _TaxiBookingViewState createState() => _TaxiBookingViewState();
}

class _TaxiBookingViewState extends State<_TaxiBookingView> {
  final _formKey = GlobalKey<FormState>();
  final _passengerNumbers = TextEditingController(text: '2');
  final _firstName = TextEditingController(text: 'John');
  final _lastName = TextEditingController(text: 'Doe');
  final _email = TextEditingController(text: 'john.doe@example.com');
  final _countryCode = TextEditingController(text: '+91');
  final _mobileNumber = TextEditingController(text: '9876543210');
  final _additionalInfo = TextEditingController(text: 'Test booking');
  final _pickupAddress = TextEditingController(text: '123 Main St, City');
  final _dropAddress = TextEditingController(text: '456 Elm St, City');
  DateTime? _date = DateTime.now();
  String? _startTime = TimeOfDay.now().toString();
  double _distance = 10.0;

  @override
  void initState() {
    super.initState();
    context.read<TaxiSettingsCubit>().fetchSettings();
  }

  @override
  void dispose() {
    _passengerNumbers.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _countryCode.dispose();
    _mobileNumber.dispose();
    _additionalInfo.dispose();
    _pickupAddress.dispose();
    _dropAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    final double basePadding = 16.0 * scaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2526),
      appBar: AppBar(
        title: Text(
          'Book Your Ride',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20 * scaleFactor,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1C2526),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => sl<Coordinator>().navigateBack(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: basePadding),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
              ),
              child: Text(
                'CALL NOW',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * scaleFactor,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TaxiSettingsCubit, TaxiSettingsState>(
        listener: (context, settingsState) {
          if (settingsState.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(settingsState.errorMessage!)),
            );
          }
        },
        builder: (context, settingsState) {
          if (settingsState.isLoading) {
            return Center(child: _buildLoadingDialog(scaleFactor, basePadding));
          }

          return BlocConsumer<TaxiBookingCubit, TaxiBookingState>(
            listener: (context, bookingState) {
              if (bookingState is TaxiBookingError) {
                showDialog(
                  context: context,
                  builder: (_) => _buildErrorDialog(bookingState.message, scaleFactor, basePadding),
                );
              } else if (bookingState is TaxiBookingSuccess) {
                showDialog(
                  context: context,
                  builder: (_) => _buildSuccessDialog(scaleFactor, basePadding),
                );
              }
            },
            builder: (context, bookingState) {
              final fare = _distance * settingsState.settings.perKmFareRate >
                  settingsState.settings.minimumFare
                  ? _distance * settingsState.settings.perKmFareRate
                  : settingsState.settings.minimumFare;

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.all(basePadding),
                          padding: EdgeInsets.all(basePadding),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2F32),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BOOK YOUR TAXI',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24 * scaleFactor,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: basePadding),
                                _buildServiceTypeDropdown(settingsState, scaleFactor),
                                SizedBox(height: basePadding),
                                _buildTextField(
                                  _pickupAddress,
                                  'PICKUP ADDRESS',
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                  scaleFactor: scaleFactor,
                                ),
                                SizedBox(height: basePadding),
                                _buildTextField(
                                  _dropAddress,
                                  'DROP ADDRESS',
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                  scaleFactor: scaleFactor,
                                ),
                                SizedBox(height: basePadding),
                                Row(
                                  children: [
                                    Expanded(child: _buildDateField(scaleFactor)),
                                    SizedBox(width: basePadding),
                                    Expanded(child: _buildTimeField(scaleFactor)),
                                  ],
                                ),
                                SizedBox(height: basePadding),
                                _buildTextField(
                                  _passengerNumbers,
                                  'PASSENGER NUMBER',
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                  scaleFactor: scaleFactor,
                                ),
                                SizedBox(height: basePadding),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        _firstName,
                                        'FIRST NAME',
                                        validator: (value) => value!.isEmpty ? 'Required' : null,
                                        scaleFactor: scaleFactor,
                                      ),
                                    ),
                                    SizedBox(width: basePadding),
                                    Expanded(
                                      child: _buildTextField(
                                        _lastName,
                                        'LAST NAME',
                                        validator: (value) => value!.isEmpty ? 'Required' : null,
                                        scaleFactor: scaleFactor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: basePadding),
                                _buildTextField(
                                  _email,
                                  'EMAIL',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                  scaleFactor: scaleFactor,
                                ),
                                SizedBox(height: basePadding),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: _buildTextField(
                                        _countryCode,
                                        'CODE',
                                        validator: (value) => value!.isEmpty ? 'Required' : null,
                                        scaleFactor: scaleFactor,
                                      ),
                                    ),
                                    SizedBox(width: basePadding),
                                    Expanded(
                                      flex: 3,
                                      child: _buildTextField(
                                        _mobileNumber,
                                        'MOBILE NO.',
                                        keyboardType: TextInputType.phone,
                                        validator: (value) => value!.isEmpty ? 'Required' : null,
                                        scaleFactor: scaleFactor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: basePadding),
                                _buildTaxiTypeDropdown(settingsState, scaleFactor),
                                SizedBox(height: basePadding),
                                _buildTripTypeDropdown(settingsState, scaleFactor),
                                SizedBox(height: basePadding),
                                _buildTextField(
                                  _additionalInfo,
                                  'ADDITIONAL INSTRUCTIONS',
                                  maxLines: 4,
                                  maxLength: 500,
                                  scaleFactor: scaleFactor,
                                ),
                                SizedBox(height: basePadding),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC107),
                                      foregroundColor: Colors.black,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 32 * scaleFactor,
                                        vertical: 12 * scaleFactor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: bookingState is TaxiBookingLoading
                                        ? null
                                        : () {
                                      if (_formKey.currentState!.validate() &&
                                          _date != null &&
                                          _startTime != null &&
                                          context.read<TaxiBookingCubit>().state.taxiTypeId !=
                                              null &&
                                          context.read<TaxiBookingCubit>().state.tripTypeId !=
                                              null &&
                                          context.read<TaxiBookingCubit>().state.serviceTypeId !=
                                              null) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => _buildConfirmDialog(
                                            fare,
                                            settingsState,
                                            scaleFactor,
                                            basePadding,
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (_) => _buildErrorDialog(
                                            'Please fill all required fields',
                                            scaleFactor,
                                            basePadding,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'SUBMIT BOOKING',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16 * scaleFactor,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(basePadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OUR PREMIUM SERVICES',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: basePadding),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildServiceCard(
                                      'AIRPORT & CRUISE TRANSFERS', Icons.flight, scaleFactor),
                                  _buildServiceCard('WEDDINGS & FORMALS', Icons.favorite, scaleFactor),
                                ],
                              ),
                              SizedBox(height: basePadding),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildServiceCard(
                                      'PRIVATE PARTY TRANSPORT', Icons.party_mode, scaleFactor),
                                  _buildServiceCard(
                                      'CHAUFFEUR\nSERVICES', Icons.directions_car, scaleFactor),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(basePadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OUR FLEET',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: basePadding),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildFleetCard('SEDAN', Icons.directions_car, scaleFactor),
                                  _buildFleetCard('MAXI TAXI', Icons.directions_car, scaleFactor),
                                  _buildFleetCard('PARTY BUS', Icons.directions_car, scaleFactor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bookingState is TaxiBookingLoading)
                    _buildLoadingDialog(scaleFactor, basePadding),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        int? maxLines,
        int? maxLength,
        required double scaleFactor,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14 * scaleFactor,
            color: const Color(0xFFB0B0B0),
          ),
        ),
        SizedBox(height: 8 * scaleFactor),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 8 * scaleFactor),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2526),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            maxLength: maxLength,
            validator: validator,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16 * scaleFactor,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: 'Enter $label',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeDropdown(TaxiSettingsState settingsState, double scaleFactor) {
    return BlocBuilder<TaxiBookingCubit, TaxiBookingState>(
      builder: (context, state) {
        return _buildDropdownField(
          value: state.serviceTypeId,
          label: 'SERVICE TYPE',
          hint: 'Select Service Type',
          items: settingsState.serviceTypes.map((ServiceType serviceType) {
            return DropdownMenuItem<String>(
              value: serviceType.id,
              child: Text(
                serviceType.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16 * scaleFactor,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) =>
              context.read<TaxiBookingCubit>().updateServiceTypeId(value),
          validator: (value) => value == null ? 'Required' : null,
          scaleFactor: scaleFactor,
        );
      },
    );
  }

  Widget _buildTaxiTypeDropdown(TaxiSettingsState settingsState, double scaleFactor) {
    return BlocBuilder<TaxiBookingCubit, TaxiBookingState>(
      builder: (context, state) {
        return _buildDropdownField(
          value: state.taxiTypeId,
          label: 'TAXI TYPE',
          hint: 'Select Taxi Type',
          items: settingsState.taxiTypes.map((TaxiType taxiType) {
            return DropdownMenuItem<String>(
              value: taxiType.id,
              child: Text(
                taxiType.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16 * scaleFactor,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) => context.read<TaxiBookingCubit>().updateTaxiTypeId(value),
          validator: (value) => value == null ? 'Required' : null,
          scaleFactor: scaleFactor,
        );
      },
    );
  }

  Widget _buildTripTypeDropdown(TaxiSettingsState settingsState, double scaleFactor) {
    return BlocBuilder<TaxiBookingCubit, TaxiBookingState>(
      builder: (context, state) {
        return _buildDropdownField(
          value: state.tripTypeId,
          label: 'TRIP TYPE',
          hint: 'Select Trip Type',
          items: settingsState.tripTypes.map((TripType tripType) {
            return DropdownMenuItem<String>(
              value: tripType.id,
              child: Text(
                tripType.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16 * scaleFactor,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) => context.read<TaxiBookingCubit>().updateTripTypeId(value),
          validator: (value) => value == null ? 'Required' : null,
          scaleFactor: scaleFactor,
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String? Function(String?)? validator,
    required double scaleFactor,
  }) {
    // Select the first item if the list is not empty and value is null
    final selectedValue = value ?? (items.isNotEmpty ? items.first.value : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14 * scaleFactor,
            color: const Color(0xFFB0B0B0),
          ),
        ),
        SizedBox(height: 8 * scaleFactor),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 8 * scaleFactor),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2526),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: items.isNotEmpty ? items : null, // Prevent crash when items is empty
            onChanged: items.isNotEmpty ? onChanged : null, // Disable dropdown if empty
            validator: validator,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16 * scaleFactor,
              color: Colors.white,
            ),
            dropdownColor: const Color(0xFF1C2526),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: items.isEmpty ? hint : null, // Show hint only if items is empty
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14 * scaleFactor,
            color: const Color(0xFFB0B0B0),
          ),
        ),
        SizedBox(height: 8 * scaleFactor),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 8 * scaleFactor),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2526),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: TextFormField(
            readOnly: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16 * scaleFactor,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
              _date == null ? 'Select Date' : DateFormat.yMMMd().format(_date!),
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: Colors.white.withOpacity(0.6),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    context.read<TaxiBookingCubit>().updateDate(date);
                    setState(() => _date = date);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIME',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14 * scaleFactor,
            color: const Color(0xFFB0B0B0),
          ),
        ),
        SizedBox(height: 8 * scaleFactor),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 8 * scaleFactor),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2526),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: TextFormField(
            readOnly: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16 * scaleFactor,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _startTime ?? 'Select Start Time',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: Colors.white.withOpacity(0.6),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.access_time, color: Colors.white),
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    final formattedTime = time.format(context);
                    context.read<TaxiBookingCubit>().updateStartTime(formattedTime);
                    setState(() => _startTime = formattedTime);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, IconData icon, double scaleFactor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8 * scaleFactor),
        padding: EdgeInsets.all(16 * scaleFactor),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2F32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32 * scaleFactor),
            SizedBox(height: 8 * scaleFactor),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14 * scaleFactor,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetCard(String title, IconData icon, double scaleFactor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8 * scaleFactor),
        padding: EdgeInsets.all(16 * scaleFactor),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2F32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32 * scaleFactor),
            SizedBox(height: 8 * scaleFactor),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14 * scaleFactor,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDialog(double scaleFactor, double basePadding) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(basePadding * 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFACC15)),
                strokeWidth: 5 * scaleFactor,
              ),
              SizedBox(height: 24 * scaleFactor),
              Text(
                'Wait...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18 * scaleFactor,
                  color: const Color(0xFFE4E4E7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDialog(String message, double scaleFactor, double basePadding) {
    return Dialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Container(
        padding: EdgeInsets.all(basePadding),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF27272A)),
          borderRadius: BorderRadius.circular(24.0),
        ),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24 * scaleFactor,
                color: const Color(0xFFFACC15),
              ),
            ),
            SizedBox(height: 16 * scaleFactor),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: const Color(0xFFE4E4E7),
              ),
            ),
            SizedBox(height: 24 * scaleFactor),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16 * scaleFactor,
                      color: Colors.black,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scaleFactor,
                      vertical: 8 * scaleFactor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDialog(double scaleFactor, double basePadding) {
    return Dialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Container(
        padding: EdgeInsets.all(basePadding),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF27272A)),
          borderRadius: BorderRadius.circular(24.0),
        ),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Successful',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24 * scaleFactor,
                color: const Color(0xFFFACC15),
              ),
            ),
            SizedBox(height: 16 * scaleFactor),
            Text(
              'Your booking has been successfully registered.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: const Color(0xFFE4E4E7),
              ),
            ),
            SizedBox(height: 24 * scaleFactor),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<TaxiBookingCubit>().reset();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16 * scaleFactor,
                      color: Colors.black,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scaleFactor,
                      vertical: 8 * scaleFactor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmDialog(
      double fare, TaxiSettingsState settingsState, double scaleFactor, double basePadding) {
    return Dialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Container(
        padding: EdgeInsets.all(basePadding),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF27272A)),
          borderRadius: BorderRadius.circular(24.0),
        ),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Booking',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24 * scaleFactor,
                color: const Color(0xFFFACC15),
              ),
            ),
            SizedBox(height: 8 * scaleFactor),
            Text(
              'Total fare for this trip is ₹${fare.toStringAsFixed(2)} for ${_distance.toStringAsFixed(2)} km.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: const Color(0xFFE4E4E7),
              ),
            ),
            SizedBox(height: 16 * scaleFactor),
            Text(
              'Are you sure you want to book this ride?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: const Color(0xFFE4E4E7),
              ),
            ),
            SizedBox(height: 24 * scaleFactor),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16 * scaleFactor,
                      color: const Color(0xFFE4E4E7),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF27272A),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scaleFactor,
                      vertical: 8 * scaleFactor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
                SizedBox(width: 16 * scaleFactor),
                TextButton(
                  onPressed: () {
                    final booking = TaxiBooking(
                      id: '',
                      passengerNumbers: int.parse(_passengerNumbers.text),
                      firstName: _firstName.text,
                      lastName: _lastName.text,
                      email: _email.text,
                      countryCode: _countryCode.text,
                      mobileNumber: _mobileNumber.text,
                      taxiTypeId: context.read<TaxiBookingCubit>().state.taxiTypeId!,
                      tripTypeId: context.read<TaxiBookingCubit>().state.tripTypeId!,
                      serviceTypeId: context.read<TaxiBookingCubit>().state.serviceTypeId!,
                      additionalInfo: _additionalInfo.text,
                      pickupAddress: _pickupAddress.text,
                      dropAddress: _dropAddress.text,
                      tripDate: _date!,
                      tripStartTime: _startTime!,
                      tripStatus: 'pending',
                      accepted: false,
                      totalFareAmount: fare,
                      lastUpdatedBy: 'user',
                      createdAt: DateTime.now(),
                      lastUpdatedAt: DateTime.now(),
                    );
                    context.read<TaxiBookingCubit>().createBooking(booking);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16 * scaleFactor,
                      color: Colors.black,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scaleFactor,
                      vertical: 8 * scaleFactor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}