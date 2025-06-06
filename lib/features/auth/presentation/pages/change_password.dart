import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_state.dart'
    as auth;
import 'package:agri_connect/features/auth/presentation/widgets/auth_field.dart';
import 'package:agri_connect/features/auth/presentation/widgets/auth_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authNotifierProvider.notifier)
          .changePassword(newPassword: passwordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<auth.AuthState>(authNotifierProvider, (prev, next) {
      if (next is auth.AuthLoading) {
        showLoadingDialog(context, message: 'Updating password...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is auth.AuthFailure) {
        showSnackBar(context, next.message);
      } else if (next is auth.AuthSuccess) {
        passwordController.text = '';
        showSnackBar(context, 'Password updated successfully.');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthField(
                hinttext: "Old Password",
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
              const SizedBox(height: 20),
              AuthGradient(text: 'Update Password', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
