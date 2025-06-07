import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';

@RoutePage()
class RidePlatinumPage extends StatefulWidget {
  const RidePlatinumPage({Key? key}) : super(key: key);

  @override
  _RidePlatinumPageState createState() => _RidePlatinumPageState();
}

class _RidePlatinumPageState extends State<RidePlatinumPage> {
  final _formKey = GlobalKey<FormState>();
  final _passengerNumbers = TextEditingController(text: '2');
  final _firstName = TextEditingController(text: 'John');
  final _lastName = TextEditingController(text: 'Doe');
  final _email = TextEditingController(text: 'john.doe@example.com');
  final _countryCode = TextEditingController(text: '+91');
  final _mobileNumber = TextEditingController(text: '9876543210');
  String? _taxiTypeId;
  String? _tripTypeId;
  String? _serviceTypeId;
  final _additionalInfo = TextEditingController(text: 'Test booking');
  final _pickupAddress = TextEditingController(text: '123 Main St, City');
  final _dropAddress = TextEditingController(text: '456 Elm St, City');
  DateTime? _date = DateTime.now();
  String? _startTime = TimeOfDay.now().toString();
  double _distance = 10.0;
  late final TaxiSettingsCubit _taxiSettingsCubit;
  late final TaxiBookingCubit _taxiBookingCubit;

  @override
  void initState() {
    super.initState();
    _taxiSettingsCubit = sl<TaxiSettingsCubit>()..fetchSettings();
    _taxiBookingCubit = sl<TaxiBookingCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    final double basePadding = 16.0 * scaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2526),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: basePadding, vertical: 8 * scaleFactor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PLATINUM',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'SYDNEY',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14 * scaleFactor,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: basePadding),
                      ElevatedButton(
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
                    ],
                  ),
                ],
              ),
            ),
            // Booking Form Section
            BlocConsumer<TaxiBookingCubit, TaxiBookingState>(
              bloc: _taxiBookingCubit,
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
                  bloc: _taxiSettingsCubit,
                  builder: (context, settingsState) {
                    if (settingsState.isLoading) {
                      return const Center(child: CustomLoadingDialog());
                    }
                    if (settingsState.errorMessage != null) {
                      return Center(
                        child: Text(
                          settingsState.errorMessage!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16 * scaleFactor,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    return Container(
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
                            _buildDropdownField(
                              value: _serviceTypeId,
                              label: 'SERVICE TYPE',
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
                              onChanged: (value) => setState(() => _serviceTypeId = value),
                              validator: (value) => value == null ? 'Required' : null,
                            ),
                            SizedBox(height: basePadding),
                            _buildTextField(_pickupAddress, 'PICKUP ADDRESS', validator: (value) => value!.isEmpty ? 'Required' : null),
                            SizedBox(height: basePadding),
                            _buildTextField(_dropAddress, 'DROP ADDRESS', validator: (value) => value!.isEmpty ? 'Required' : null),
                            SizedBox(height: basePadding),
                            Row(
                              children: [
                                Expanded(child: _buildDateField()),
                                SizedBox(width: basePadding),
                                Expanded(child: _buildTimeField()),
                              ],
                            ),
                            SizedBox(height: basePadding),
                            _buildTextField(_passengerNumbers, 'PASSENGER NUMBER', keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Required' : null),
                            SizedBox(height: basePadding),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_firstName, 'FIRST NAME', validator: (value) => value!.isEmpty ? 'Required' : null)),
                                SizedBox(width: basePadding),
                                Expanded(child: _buildTextField(_lastName, 'LAST NAME', validator: (value) => value!.isEmpty ? 'Required' : null)),
                              ],
                            ),
                            SizedBox(height: basePadding),
                            _buildTextField(_email, 'EMAIL', keyboardType: TextInputType.emailAddress, validator: (value) => value!.isEmpty ? 'Required' : null),
                            SizedBox(height: basePadding),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildTextField(_countryCode, 'CODE', validator: (value) => value!.isEmpty ? 'Required' : null),
                                ),
                                SizedBox(width: basePadding),
                                Expanded(
                                  flex: 3,
                                  child: _buildTextField(_mobileNumber, 'MOBILE NO.', keyboardType: TextInputType.phone, validator: (value) => value!.isEmpty ? 'Required' : null),
                                ),
                              ],
                            ),
                            SizedBox(height: basePadding),
                            _buildDropdownField(
                              value: _taxiTypeId,
                              label: 'TAXI TYPE',
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
                              onChanged: (value) => setState(() => _taxiTypeId = value),
                              validator: (value) => value == null ? 'Required' : null,
                            ),
                            SizedBox(height: basePadding),
                            _buildDropdownField(
                              value: _tripTypeId,
                              label: 'TRIP TYPE',
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
                              onChanged: (value) => setState(() => _tripTypeId = value),
                              validator: (value) => value == null ? 'Required' : null,
                            ),
                            SizedBox(height: basePadding),
                            _buildTextField(_additionalInfo, 'ADDITIONAL INSTRUCTIONS', maxLines: 4, maxLength: 500),
                            SizedBox(height: basePadding),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(horizontal: 32 * scaleFactor, vertical: 12 * scaleFactor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
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
                                    _taxiBookingCubit.createBooking(booking);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please fill all required fields')),
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
                    );
                  },
                );
              },
            ),
            // About Us Section
            Container(
              padding: EdgeInsets.all(basePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABOUT US',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 24 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8 * scaleFactor),
                  Text(
                    'We are Sydney’s leading luxury transport company. Our professional drivers '
                        'ensure you arrive in style, comfort, and safety. Whether it’s a business trip, '
                        'wedding, or airport transfer, we’ve got you covered.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14 * scaleFactor,
                      color: const Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              ),
            ),
            // Our Premium Services Section
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
                      _buildServiceCard('AIRPORT & CRUISE TRANSFERS', Icons.flight, scaleFactor),
                      _buildServiceCard('WEDDINGS & FORMALS', Icons.favorite, scaleFactor),
                    ],
                  ),
                  SizedBox(height: basePadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildServiceCard('PRIVATE PARTY TRANSPORT', Icons.party_mode, scaleFactor),
                      _buildServiceCard('CHAUFFEUR\nSERVICES', Icons.directions_car, scaleFactor),
                    ],
                  ),
                ],
              ),
            ),
            // Our Fleet Section
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
            // What Our Clients Say Section
            Container(
              padding: EdgeInsets.all(basePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHAT OUR CLIENTS SAY',
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
                      _buildTestimonialCard(
                          '“The best luxury transport in Sydney! Always on time and professional.”',
                          'JESSICA T.',
                          scaleFactor),
                      _buildTestimonialCard(
                          '“Travelled to my wedding in style. Highly recommend!”', 'MIKE L.', scaleFactor),
                    ],
                  ),
                ],
              ),
            ),
            // Contact Us Section
            Container(
              padding: EdgeInsets.all(basePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTACT US',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 24 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8 * scaleFactor),
                  Text(
                    'Have questions? We’re here to help! Reach out to our friendly team.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14 * scaleFactor,
                      color: const Color(0xFFB0B0B0),
                    ),
                  ),
                  SizedBox(height: basePadding),
                  Text(
                    'PHONE: +61 2 1234 5678',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14 * scaleFactor,
                      color: const Color(0xFFB0B0B0),
                    ),
                  ),
                  SizedBox(height: 8 * scaleFactor),
                  Text(
                    'ADDRESS: 123 Luxury St, Sydney, NSW 2000, Australia',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14 * scaleFactor,
                      color: const Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: EdgeInsets.all(basePadding),
              color: const Color(0xFF2A2F32),
              child: Center(
                child: Text(
                  '© 2025 Platinum. All rights reserved.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scaleFactor,
                    color: const Color(0xFFB0B0B0),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required

    List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String? Function(String?)? validator,
  }) {
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
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
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16 * scaleFactor,
              color: Colors.white,
            ),
            dropdownColor: const Color(0xFF1C2526),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
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
              hintText: _date == null ? 'Select Date' : DateFormat.yMMMd().format(_date!),
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scaleFactor,
                color: Colors.white,
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
                  if (date != null) setState(() => _date = date);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
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
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.access_time, color: Colors.white),
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

  Widget _buildTestimonialCard(String testimonial, String author, double scaleFactor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8 * scaleFactor),
        padding: EdgeInsets.all(16 * scaleFactor),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2F32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              testimonial,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14 * scaleFactor,
                color: const Color(0xFFB0B0B0),
              ),
            ),
            SizedBox(height: 8 * scaleFactor),
            Text(
              author,
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
}