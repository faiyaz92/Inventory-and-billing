import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/forgot_password_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_textfield.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  late ForgotPasswordCubit _forgotPasswordCubit;

  @override
  void initState() {
    _forgotPasswordCubit = sl.get<ForgotPasswordCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    final double basePadding = 16.0 * scaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2526), // Match TaxiBookingPage background
      appBar: AppBar(
        title:Text("Reset Password",style: TextStyle(
          fontFamily: 'Poppins', // Match TaxiBookingPage font
          fontWeight: FontWeight.bold,
          fontSize: 20 * scaleFactor,
          color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
        ),),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C2526), // Match TaxiBookingPage appBar
        iconTheme: const IconThemeData(color: Color(0xFFE4E4E7)), // Match TaxiBookingPage icons
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2F32), // Darker shade to align with TaxiBookingPage
              Color(0xFF1C2526), // Primary background color
            ],
          ),
        ),
        child: BlocProvider(
          create: (context) => _forgotPasswordCubit,
          child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                _showSuccessDialog(context, "Password Reset",
                    "Email link has been sent to ${emailController.text}.", scaleFactor, basePadding);
              } else if (state is ForgotPasswordFailure) {
                _showErrorDialog(context, "Password Reset Error", state.error, scaleFactor, basePadding);
              }
            },
            builder: (context, state) {
              String? emailError;
              if (state is ForgotPasswordFailure) {
                emailError = state.error;
              }

              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(basePadding),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2F32), // Match TaxiBookingPage card background
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF27272A)),
                            ),
                            padding: EdgeInsets.all(basePadding * 1.5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reset Your Password",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 28 * scaleFactor,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
                                  ),
                                ),
                                SizedBox(height: basePadding),
                                Text(
                                  "Enter your email to receive a password reset link.",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16 * scaleFactor,
                                    color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                                  ),
                                ),
                                SizedBox(height: basePadding * 1.5),
                                CustomTextField(
                                  controller: emailController,
                                  focusNode: emailFocusNode,
                                  labelText: "Email",
                                  hintText: "Enter your email",
                                  prefixIcon: const Icon(Icons.email, color: Color(0xFFB0B0B0)),
                                  errorText: emailError,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (value) {
                                    final email = emailController.text.trim();
                                    _forgotPasswordCubit.resetPassword(email);
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    hintText: "Enter your email",
                                    prefixIcon: const Icon(Icons.email, color: Color(0xFFB0B0B0)),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                                      fontSize: 14 * scaleFactor,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF1C2526), // Match TaxiBookingPage input background
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(color: Color(0xFF27272A)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(color: Color(0xFF27272A)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(color: Color(0xFFFACC15)), // Match accent
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    hintStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16 * scaleFactor,
                                      color: const Color(0xFFE4E4E7).withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                SizedBox(height: basePadding * 1.5),
                                Center(
                                  child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                                    builder: (context, state) {
                                      if (state is ForgotPasswordLoading) {
                                        return CircularProgressIndicator(
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFACC15)), // Match accent
                                          strokeWidth: 5 * scaleFactor,
                                        );
                                      }
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFACC15), // Match TaxiBookingPage button
                                          foregroundColor: Colors.black, // Match TaxiBookingPage button text
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12 * scaleFactor,
                                            horizontal: 32 * scaleFactor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          textStyle: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16 * scaleFactor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          final email = emailController.text.trim();
                                          _forgotPasswordCubit.resetPassword(email);
                                        },
                                        child: const Text("Reset Password"),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: basePadding),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_taxi,
                              color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                              size: 24 * scaleFactor,
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Text(
                              "Powered by Easy2Solutions",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16 * scaleFactor,
                                color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Icon(
                              Icons.directions_car,
                              color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                              size: 24 * scaleFactor,
                            ),
                          ],
                        ),
                        Text(
                          "Version 1.0.0",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scaleFactor,
                            color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message, double scaleFactor, double basePadding) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF18181B), // Match TaxiBookingPage dialog background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            padding: EdgeInsets.all(basePadding),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF27272A)), // Match TaxiBookingPage dialog border
              borderRadius: BorderRadius.circular(24.0),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 24 * scaleFactor,
                    color: const Color(0xFFFACC15), // Match TaxiBookingPage accent
                  ),
                ),
                SizedBox(height: 16 * scaleFactor),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16 * scaleFactor,
                    color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
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
                        backgroundColor: const Color(0xFFFACC15), // Match TaxiBookingPage button
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
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message, double scaleFactor, double basePadding) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF18181B), // Match TaxiBookingPage dialog background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            padding: EdgeInsets.all(basePadding),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF27272A)), // Match TaxiBookingPage dialog border
              borderRadius: BorderRadius.circular(24.0),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 24 * scaleFactor,
                    color: const Color(0xFFFACC15), // Match TaxiBookingPage accent
                  ),
                ),
                SizedBox(height: 16 * scaleFactor),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16 * scaleFactor,
                    color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
                  ),
                ),
                SizedBox(height: 24 * scaleFactor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        sl.get<Coordinator>().navigateBack(); // Navigate back to LoginPage
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
                        backgroundColor: const Color(0xFFFACC15), // Match TaxiBookingPage button
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
      },
    );
  }
}