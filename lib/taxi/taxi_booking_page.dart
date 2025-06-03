import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';

@RoutePage()
class TaxiBookingPage extends StatefulWidget {
  const TaxiBookingPage({
    Key? key,
  }) : super(key: key);

  @override
  _TaxiBookingPageState createState() => _TaxiBookingPageState();
}

class _TaxiBookingPageState extends State<TaxiBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _passengerNumbers = TextEditingController(text: '2'); // Dummy data
  final _firstName = TextEditingController(text: 'John'); // Dummy data
  final _lastName = TextEditingController(text: 'Doe'); // Dummy data
  final _email = TextEditingController(text: 'john.doe@example.com'); // Dummy data
  final _countryCode = TextEditingController(text: '+91'); // Dummy data
  final _mobileNumber = TextEditingController(text: '9876543210'); // Dummy data
  String? _taxiTypeId;
  String? _tripTypeId;
  String? _serviceTypeId;
  final _additionalInfo = TextEditingController(text: 'Test booking'); // Dummy data
  final _pickupAddress = TextEditingController(text: '123 Main St, City'); // Dummy data
  final _dropAddress = TextEditingController(text: '456 Elm St, City'); // Dummy data
  DateTime? _date = DateTime.now(); // Dummy data
  String? _startTime = TimeOfDay.now().toString(); // Dummy data
  double _distance = 10.0; // Placeholder for distance calculation

  @override
  void initState() {
    super.initState();
    // Fetch settings when the page initializes
    context.read<TaxiSettingsCubit>().fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Book a Taxi'),
      body: BlocConsumer<TaxiBookingCubit, TaxiBookingState>(
        listener: (context, state) {
          if (state is TaxiBookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking created successfully')),
            );
          } else if (state is TaxiBookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return BlocBuilder<TaxiSettingsCubit, TaxiSettingsState>(
            builder: (context, settingsState) {
              if (settingsState.isLoading) {
                return const Center(child: CustomLoadingDialog());
              }
              if (settingsState.errorMessage != null) {
                return Center(child: Text(settingsState.errorMessage!));
              }

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(_passengerNumbers, 'Passenger Numbers', keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Required' : null),
                        _buildTextField(_firstName, 'First Name', validator: (value) => value!.isEmpty ? 'Required' : null),
                        _buildTextField(_lastName, 'Last Name', validator: (value) => value!.isEmpty ? 'Required' : null),
                        _buildTextField(_email, 'Email', keyboardType: TextInputType.emailAddress, validator: (value) => value!.isEmpty ? 'Required' : null),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildTextField(_countryCode, 'Code', validator: (value) => value!.isEmpty ? 'Required' : null),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: _buildTextField(_mobileNumber, 'Mobile Number', keyboardType: TextInputType.phone, validator: (value) => value!.isEmpty ? 'Required' : null),
                            ),
                          ],
                        ),
                        _buildDropdownField(
                          value: _taxiTypeId,
                          label: 'Taxi Type',
                          items: settingsState.taxiTypes.map((TaxiType taxiType) {
                            return DropdownMenuItem<String>(
                              value: taxiType.id,
                              child: Text(taxiType.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _taxiTypeId = value),
                          validator: (value) => value == null ? 'Required' : null,
                        ),
                        _buildDropdownField(
                          value: _tripTypeId,
                          label: 'Trip Type',
                          items: settingsState.tripTypes.map((TripType tripType) {
                            return DropdownMenuItem<String>(
                              value: tripType.id,
                              child: Text(tripType.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _tripTypeId = value),
                          validator: (value) => value == null ? 'Required' : null,
                        ),
                        _buildDropdownField(
                          value: _serviceTypeId,
                          label: 'Service Type',
                          items: settingsState.serviceTypes.map((ServiceType serviceType) {
                            return DropdownMenuItem<String>(
                              value: serviceType.id,
                              child: Text(serviceType.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _serviceTypeId = value),
                          validator: (value) => value == null ? 'Required' : null,
                        ),
                        _buildTextField(_additionalInfo, 'Additional Information', maxLines: 4, maxLength: 500),
                        _buildTextField(_pickupAddress, 'Pickup Address', validator: (value) => value!.isEmpty ? 'Required' : null),
                        _buildTextField(_dropAddress, 'Drop Address', validator: (value) => value!.isEmpty ? 'Required' : null),
                        _buildDateField(),
                        _buildTimeField(),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: state is TaxiBookingLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate() &&
                                  _date != null &&
                                  _startTime != null &&
                                  _taxiTypeId != null &&
                                  _tripTypeId != null &&
                                  _serviceTypeId != null) {
                                final settings = settingsState.settings;
                                final fare = _distance * settings.perKmFareRate > settings.minimumFare
                                    ? _distance * settings.perKmFareRate
                                    : settings.minimumFare;

                                // Check for WhatsApp notification threshold
                                if (fare > settings.whatsappNotificationFareThreshold) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('WhatsApp notification will be sent')),
                                  );
                                }

                                final booking = TaxiBooking(
                                  id: '',
                                  passengerNumbers: int.parse(_passengerNumbers.text),
                                  firstName: _firstName.text,
                                  lastName: _lastName.text,
                                  email: _email.text,
                                  countryCode: _countryCode.text,
                                  mobileNumber: _mobileNumber.text,
                                  taxiTypeId: _taxiTypeId!,
                                  tripTypeId: _tripTypeId!,
                                  serviceTypeId: _serviceTypeId!,
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
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields')),
                                );
                              }
                            },
                            child: const Text('Book Taxi'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
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
          counterText: maxLength != null ? "" : null,
        ),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
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
        style: const TextStyle(fontSize: 16.0, color: Colors.black),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: _date == null ? 'Select Date' : DateFormat.yMMMd().format(_date!),
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
            icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _date = date);
            },
          ),
        ),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _buildTimeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: _startTime ?? 'Select Start Time',
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
            icon: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => _startTime = time.format(context));
              }
            },
          ),
        ),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }
}