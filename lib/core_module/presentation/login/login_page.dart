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
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.3),
                ],
              ),
            ),
          ),
          // Scattered icons
          // _buildScatteredIcons(context),
          // Main content
          BlocProvider(
            create: (context) => sl.get<LoginCubit>(),
            child: BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  sl.get<AppRouter>().replace(const DashboardRoute());
                } else if (state is LoginFailure) {
                  _showErrorDialog(context, "Login Error", state.error);
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
                                      "Welcome Back",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
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
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (value) {
                                        FocusScope.of(context).requestFocus(passwordFocusNode);
                                      },
                                      onChanged: (value) => context.read<LoginCubit>().validateEmail(value),
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        hintText: "Enter your email",
                                        prefixIcon: const Icon(Icons.email),
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
                                    ),
                                    const SizedBox(height: 16),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: isPasswordVisible,
                                      builder: (context, value, child) {
                                        return CustomTextField(
                                          controller: passwordController,
                                          focusNode: passwordFocusNode,
                                          labelText: "Password",
                                          hintText: "Enter your password",
                                          prefixIcon: const Icon(Icons.lock),
                                          obscureText: !value,
                                          errorText: passwordError,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              value ? Icons.visibility : Icons.visibility_off,
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
                                            prefixIcon: const Icon(Icons.lock),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                value ? Icons.visibility : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                isPasswordVisible.value = !value;
                                              },
                                            ),
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
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          sl.get<Coordinator>().navigateToForgotPasswordPage();
                                        },
                                        child: Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: BlocBuilder<LoginCubit, LoginState>(
                                        builder: (context, state) {
                                          if (state is LoginLoading) {
                                            return CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor,
                                              ),
                                            );
                                          }
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 64.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 18,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business, color: Colors.grey[700], size: 30),
                              const SizedBox(width: 8),
                              Text(
                                "Powered by Easy2Solutions",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.code, color: Colors.grey[700], size: 30),
                            ],
                          ),
                          Text(
                            "Version 1.0.0",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
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
      Icons.person_outline,
      Icons.task_alt,
      Icons.event,
      Icons.access_time,
      Icons.group,
      Icons.check_circle_outline,
      Icons.admin_panel_settings,
      Icons.add_task_outlined,
      Icons.task,
      Icons.business,
      Icons.add_business,
      Icons.lightbulb,
      Icons.settings,
      Icons.manage_accounts,
    ];
    final size = MediaQuery.of(context).size;
    return Stack(
      children: List.generate(50, (index) {
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
              color: Colors.grey[700],
            ),
          ),
        );
      }),
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
}