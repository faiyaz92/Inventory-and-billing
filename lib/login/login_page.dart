import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/app_router/app_router.gr.dart';
import 'package:requirment_gathering_app/widget/custom_textfield.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';

import 'login_cubit.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
          centerTitle: true,
        ),
        body: BlocProvider(
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

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      labelText: "Email",
                      hintText: "Enter your email",
                      prefixIcon:  const Icon(Icons.email),
                      errorText: emailError,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      },
                      onChanged: (value) =>
                          context.read<LoginCubit>().validateEmail(value),
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
                            // Trigger login on "Done"
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            context.read<LoginCubit>().login(email, password);
                          },
                          onChanged: (value) => context
                              .read<LoginCubit>()
                              .validatePassword(value),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        if (state is LoginLoading) {
                          return const CircularProgressIndicator();
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 64.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            context.read<LoginCubit>().login(email, password);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
}
