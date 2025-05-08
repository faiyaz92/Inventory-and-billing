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

  ForgotPasswordPage({super.key});

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
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Reset Password",
        centerTitle: true,

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme
                  .of(context)
                  .primaryColor
                  .withOpacity(0.1),
              Theme
                  .of(context)
                  .primaryColor
                  .withOpacity(0.3),
            ],
          ),
        ),
        child: BlocProvider(
          create: (context) => _forgotPasswordCubit,
          child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                _showSuccessDialog(context, "Password Reset",
                    "Email link has been sent to ${emailController.text}.");
              } else if (state is ForgotPasswordFailure) {
                _showErrorDialog(context, "Password Reset Error", state.error);
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
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Reset Your Password",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Enter your email to receive a password reset link.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  CustomTextField(
                                    controller: emailController,
                                    focusNode: emailFocusNode,
                                    labelText: "Email",
                                    hintText: "Enter your email",
                                    prefixIcon: const Icon(Icons.email),
                                    errorText: emailError,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (value) {
                                      final email = emailController.text.trim();
                                      _forgotPasswordCubit
                                          .resetPassword(email);
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      hintText: "Enter your email",
                                      prefixIcon: const Icon(Icons.email),
                                      labelStyle: TextStyle(
                                        color: Theme
                                            .of(context)
                                            .primaryColor,
                                        fontSize: 16.0,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0),
                                        borderSide: BorderSide(
                                            color: Colors.grey[400]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0),
                                        borderSide: BorderSide(
                                            color: Colors.grey[400]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0),
                                        borderSide: BorderSide(color: Theme
                                            .of(context)
                                            .primaryColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: BlocBuilder<
                                        ForgotPasswordCubit,
                                        ForgotPasswordState>(
                                      builder: (context, state) {
                                        if (state is ForgotPasswordLoading) {
                                          return CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                              Theme
                                                  .of(context)
                                                  .primaryColor,
                                            ),
                                          );
                                        }
                                        return ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme
                                                .of(context)
                                                .primaryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16.0,
                                              horizontal: 64.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8.0),
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            final email = emailController.text
                                                .trim();
                                            _forgotPasswordCubit
                                                .resetPassword(email);
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
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business, color: Colors.white70,
                                size: 30),
                            SizedBox(width: 8),
                            Text(
                              "Powered by Easy2Solutions",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.code, color: Colors.white70, size: 30),
                          ],
                        ),
                        Text(
                          "Version 1.0.0",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
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

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sl.get<Coordinator>()
                    .navigateBack(); // Navigate back to LoginPage
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}