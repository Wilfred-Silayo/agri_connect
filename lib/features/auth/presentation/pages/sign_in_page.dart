import 'package:agri_connect/core/constants/pallete.dart';
import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/auth/presentation/pages/sign_up_page.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/auth/presentation/widgets/auth_field.dart';
import 'package:agri_connect/features/auth/presentation/widgets/auth_gradient.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_state.dart'
    as auth;
import 'package:agri_connect/features/products/presentation/pages/products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    await ref
        .read(authNotifierProvider.notifier)
        .signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<auth.AuthState>(authNotifierProvider, (previous, next) {
      if (next is auth.AuthLoading) {
        showLoadingDialog(context, message: 'Signing in...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is auth.AuthFailure) {
        print("Error: ${next.message}");
        showSnackBar(context, next.message);
      } else if (next is auth.AuthSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductsPage()),
        );
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.deepForest,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AuthField(hinttext: "Email", controler: emailController),
                    const SizedBox(height: 15),
                    AuthField(
                      hinttext: "Password",
                      controler: passwordController,
                      isObscureText: true,
                    ),
                    const SizedBox(height: 20),
                    AuthGradient(
                      text: 'Sign In',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await signIn();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Don\'t have an account? ',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: 'Sign Up',
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
      ),
    );
  }
}
