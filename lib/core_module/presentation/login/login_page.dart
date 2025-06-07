import 'dart:math';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/app_router/app_router.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_state.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_textfield.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    passwordController.text = 'Faiyaz@123';
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    final double basePadding = 16.0 * scaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2526), // Match TaxiBookingPage background
      body: Stack(
        children: [
          // Gradient background
          Container(
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
          ),
          // Scattered icons (adjusted for theme)
          // _buildScatteredIcons(context),
          // Main content
          BlocProvider(
            create: (context) => sl.get<LoginCubit>(),
            child: BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  sl.get<AppRouter>().replace(const DashboardRoute());
                } else if (state is LoginFailure) {
                  _showErrorDialog(context, "Login Error", state.error, scaleFactor, basePadding);
                }
              },
              builder: (context, state) {
                String? emailError;
                String? passwordError;

                if (state is EmailValidationError) {
                  emailError = state.error;
                } else if (state is PasswordValidationError) {
                  passwordError = state.error;
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
                                    "Welcome Back",
                                    style: TextStyle(
                                      fontFamily: 'Poppins', // Match TaxiBookingPage font
                                      fontSize: 28 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
                                    ),
                                  ),
                                  SizedBox(height: basePadding),
                                  CustomTextField(
                                    controller: emailController,
                                    focusNode: emailFocusNode,
                                    labelText: "Email",
                                    hintText: "Enter your email",
                                    prefixIcon: const Icon(Icons.email, color: Color(0xFFB0B0B0)),
                                    errorText: emailError,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (value) {
                                      FocusScope.of(context).requestFocus(passwordFocusNode);
                                    },
                                    onChanged: (value) => context.read<LoginCubit>().validateEmail(value),
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
                                  SizedBox(height: basePadding),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: isPasswordVisible,
                                    builder: (context, value, child) {
                                      return CustomTextField(
                                        controller: passwordController,
                                        focusNode: passwordFocusNode,
                                        labelText: "Password",
                                        hintText: "Enter your password",
                                        prefixIcon: const Icon(Icons.lock, color: Color(0xFFB0B0B0)),
                                        obscureText: !value,
                                        errorText: passwordError,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            value ? Icons.visibility : Icons.visibility_off,
                                            color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                                          ),
                                          onPressed: () {
                                            isPasswordVisible.value = !value;
                                          },
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (value) {
                                          final email = emailController.text.trim();
                                          final password = passwordController.text.trim();
                                          context.read<LoginCubit>().login(email, password);
                                        },
                                        onChanged: (value) => context.read<LoginCubit>().validatePassword(value),
                                        decoration: InputDecoration(
                                          labelText: "Password",
                                          hintText: "Enter your password",
                                          prefixIcon: const Icon(Icons.lock, color: Color(0xFFB0B0B0)),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              value ? Icons.visibility : Icons.visibility_off,
                                              color: const Color(0xFFB0B0B0),
                                            ),
                                            onPressed: () {
                                              isPasswordVisible.value = !value;
                                            },
                                          ),
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
                                      );
                                    },
                                  ),
                                  SizedBox(height: basePadding * 0.5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        sl.get<Coordinator>().navigateToForgotPasswordPage();
                                      },
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: const Color(0xFFFACC15), // Match TaxiBookingPage accent
                                          fontSize: 14 * scaleFactor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: basePadding * 1.5),
                                  Center(
                                    child: BlocBuilder<LoginCubit, LoginState>(
                                      builder: (context, state) {
                                        if (state is LoginLoading) {
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
                                            final password = passwordController.text.trim();
                                            context.read<LoginCubit>().login(email, password);
                                          },
                                          child: const Text("Login"),
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
                                Icons.local_taxi, // Match TaxiBookingPage footer icon
                                color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                                size: 24 * scaleFactor,
                              ),
                              SizedBox(width: 8 * scaleFactor),
                              Text(
                                "Powered by Easy2Solutions",
                                style: TextStyle(
                                  fontFamily: 'Poppins', // Match TaxiBookingPage font
                                  fontSize: 16 * scaleFactor,
                                  color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8 * scaleFactor),
                              Icon(
                                Icons.directions_car, // Match TaxiBookingPage footer icon
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
        ],
      ),
    );
  }

  Widget _buildScatteredIcons(BuildContext context) {
    final random = Random();
    final icons = [
      Icons.local_taxi,
      Icons.directions_car,
      Icons.flight,
      Icons.party_mode,
      Icons.favorite, // Icons from TaxiBookingPage services
    ];
    final size = MediaQuery.of(context).size;
    return Stack(
      children: List.generate(20, (index) {
        final icon = icons[random.nextInt(icons.length)];
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final iconSize = 20 + random.nextDouble() * 20; // 20-40
        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              icon,
              size: iconSize,
              color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label color
            ),
          ),
        );
      }),
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
                    fontFamily: 'Poppins', // Match TaxiBookingPage font
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
}