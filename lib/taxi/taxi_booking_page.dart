import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';

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
  final _passengerNumbers = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _countryCode = TextEditingController();
  final _mobileNumber = TextEditingController();
  String? _taxiTypeId;
  String? _tripTypeId;
  String? _serviceTypeId;
  final _additionalInfo = TextEditingController();
  final _pickupAddress = TextEditingController();
  final _dropAddress = TextEditingController();
  DateTime? _date;
  String? _startTime;
  double _distance = 10.0; // Placeholder for distance calculation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Book a Taxi'),
      body: BlocConsumer<TaxiBookingCubit, TaxiBookingState>(
        listener: (context, state) {
          if (state is TaxiBookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking created successfully')));
          } else if (state is TaxiBookingError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _passengerNumbers,
                    decoration:
                        const InputDecoration(labelText: 'Passenger Numbers'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _countryCode,
                          decoration: const InputDecoration(labelText: 'Code'),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _mobileNumber,
                          decoration:
                              const InputDecoration(labelText: 'Mobile Number'),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
// Dropdowns for taxiType, tripType, serviceType (populated from Firestore)
                  TextFormField(
                    controller: _additionalInfo,
                    decoration: const InputDecoration(
                        labelText: 'Additional Information'),
                  ),
                  TextFormField(
                    controller: _pickupAddress,
                    decoration:
                        const InputDecoration(labelText: 'Pickup Address'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _dropAddress,
                    decoration:
                        const InputDecoration(labelText: 'Drop Address'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
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
                        lastDate: DateTime.now().add(const Duration(days: 365)),
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
                                _startTime != null) {
                              final state1 =
                                  context.read<TaxiSettingsCubit>().state;
                              if (state1 is TaxiSettingsSuccess) {
                                final settings = state1.settings;
                                final fare = _distance * settings.perKmFareRate;
                                if (fare >
                                    settings
                                        .whatsappNotificationFareThreshold) {
// Trigger WhatsApp notification (placeholder)
                                }
                                // final booking = TaxiBooking(
                                //   id: '',
                                //   passengerNumbers:
                                //       int.parse(_passengerNumbers.text),
                                //   firstName: _firstName.text,
                                //   lastName: _lastName.text,
                                //   email: _email.text,
                                //   countryCode: _countryCode.text,
                                //   mobileNumber: _mobileNumber.text,
                                //   taxiTypeId: _taxiTypeId ?? '',
                                //   tripTypeId: _tripTypeId ?? '',
                                //   serviceTypeId: _serviceTypeId ?? '',
                                //   additionalInfo: _additionalInfo.text,
                                //   pickupAddress: _pickupAddress.text,
                                //   dropAddress: _dropAddress.text,
                                //   date: _date!,
                                //   startTime: _startTime!,
                                //   tripStatus: 'pending',
                                //   accepted: false,
                                //   totalFareAmount: fare, loggedDate: null,
                                // );
                                // context
                                //     .read<TaxiBookingCubit>()
                                //     .createBooking(booking);
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
                                taxiTypeId: _taxiTypeId ?? '',
                                tripTypeId: _tripTypeId ?? '',
                                serviceTypeId: _serviceTypeId ?? '',
                                additionalInfo: _additionalInfo.text,
                                pickupAddress: _pickupAddress.text,
                                dropAddress: _dropAddress.text,
                                tripDate: _date!,
                                tripStartTime: _startTime!,
                                tripStatus: 'pending',
                                accepted: false,
                                totalFareAmount: 35,
                                lastUpdatedBy: '',
                                createdAt: DateTime.timestamp(),
                                lastUpdatedAt: DateTime.timestamp(),
                              );
                              context
                                  .read<TaxiBookingCubit>()
                                  .createBooking(booking);
                            }
                          },
                    child: const Text('Book Taxi'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
