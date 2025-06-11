import 'package:agri_connect/core/constants/pallete.dart';
import 'package:agri_connect/core/enums/user_enums.dart';
import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/core/utils/dropdown_controller.dart';
import 'package:agri_connect/features/auth/presentation/pages/sign_in_page.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_state.dart'
    as auth;
import 'package:agri_connect/features/auth/presentation/widgets/auth_field.dart';
import 'package:agri_connect/features/auth/presentation/widgets/auth_gradient.dart';
import 'package:agri_connect/features/auth/presentation/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final userTypeController = DropdownController("farmer");

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    await ref
        .read(authNotifierProvider.notifier)
        .signUp(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          type: userTypeController.selected,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<auth.AuthState>(authNotifierProvider, (previous, next) {
      if (next is auth.AuthLoading) {
        showLoadingDialog(context, message: 'Signing up...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is auth.AuthFailure) {
        showSnackBar(context, next.message);
      } else if (next is auth.AuthInitial) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppPalette.neutralDark,
        backgroundColor: AppPalette.neutralLight,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.deepForest,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthField(hinttext: "Name", controler: nameController),
                  const SizedBox(height: 15),
                  AuthField(hinttext: "Email", controler: emailController),
                  const SizedBox(height: 15),
                  CustomDropdown(
                    items: UserType.values.map((e) => e.type).toList(),
                    controller: userTypeController,
                  ),
                  const SizedBox(height: 15),
                  AuthField(
                    hinttext: "Password",
                    controler: passwordController,
                    isObscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  AuthField(
                    hinttext: "Confirm password",
                    controler: confirmPasswordController,
                    isObscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthGradient(
                    text: 'Sign Up',
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await signUp();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppPalette.deepForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
