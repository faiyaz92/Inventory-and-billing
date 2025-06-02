import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';

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
  final _email =
      TextEditingController(text: 'john.doe@example.com'); // Dummy data
  final _countryCode = TextEditingController(text: '+91'); // Dummy data
  final _mobileNumber = TextEditingController(text: '9876543210'); // Dummy data
  String? _taxiTypeId;
  String? _tripTypeId;
  String? _serviceTypeId;
  final _additionalInfo =
      TextEditingController(text: 'Test booking'); // Dummy data
  final _pickupAddress =
      TextEditingController(text: '123 Main St, City'); // Dummy data
  final _dropAddress =
      TextEditingController(text: '456 Elm St, City'); // Dummy data
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

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _passengerNumbers,
                        decoration: const InputDecoration(
                            labelText: 'Passenger Numbers'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _firstName,
                        decoration:
                            const InputDecoration(labelText: 'First Name'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _lastName,
                        decoration:
                            const InputDecoration(labelText: 'Last Name'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _countryCode,
                              decoration:
                                  const InputDecoration(labelText: 'Code'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _mobileNumber,
                              decoration: const InputDecoration(
                                  labelText: 'Mobile Number'),
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      // Dropdown for Taxi Type
                      DropdownButtonFormField<String>(
                        value: _taxiTypeId,
                        decoration:
                            const InputDecoration(labelText: 'Taxi Type'),
                        items: settingsState.taxiTypes.map((TaxiType taxiType) {
                          return DropdownMenuItem<String>(
                            value: taxiType.id,
                            child: Text(taxiType.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _taxiTypeId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      // Dropdown for Trip Type
                      DropdownButtonFormField<String>(
                        value: _tripTypeId,
                        decoration:
                            const InputDecoration(labelText: 'Trip Type'),
                        items: settingsState.tripTypes.map((TripType tripType) {
                          return DropdownMenuItem<String>(
                            value: tripType.id,
                            child: Text(tripType.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _tripTypeId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      // Dropdown for Service Type
                      DropdownButtonFormField<String>(
                        value: _serviceTypeId,
                        decoration:
                            const InputDecoration(labelText: 'Service Type'),
                        items: settingsState.serviceTypes
                            .map((ServiceType serviceType) {
                          return DropdownMenuItem<String>(
                            value: serviceType.id,
                            child: Text(serviceType.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _serviceTypeId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _additionalInfo,
                        decoration: const InputDecoration(
                            labelText: 'Additional Information'),
                      ),
                      TextFormField(
                        controller: _pickupAddress,
                        decoration:
                            const InputDecoration(labelText: 'Pickup Address'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _dropAddress,
                        decoration:
                            const InputDecoration(labelText: 'Drop Address'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      ListTile(
                        title: Text(_date == null
                            ? 'Select Date'
                            : DateFormat.yMMMd().format(_date!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => _date = date);
                        },
                      ),
                      ListTile(
                        title: Text(_startTime ?? 'Select Start Time'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => _startTime = time.format(context));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
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
                                  final fare =
                                      _distance * settings.perKmFareRate >
                                              settings.minimumFare
                                          ? _distance * settings.perKmFareRate
                                          : settings.minimumFare;

                                  // Check for WhatsApp notification threshold
                                  if (fare >
                                      settings
                                          .whatsappNotificationFareThreshold) {
                                    // Placeholder for WhatsApp notification logic
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'WhatsApp notification will be sent')),
                                    );
                                  }

                                  final booking = TaxiBooking(
                                    id: '',
                                    passengerNumbers:
                                        int.parse(_passengerNumbers.text),
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
                                    // Replace with actual user
                                    createdAt: DateTime.now(),
                                    lastUpdatedAt: DateTime.now(),
                                  );
                                  context
                                      .read<TaxiBookingCubit>()
                                      .createBooking(booking);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please fill all required fields')),
                                  );
                                }
                              },
                        child: const Text('Book Taxi'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
