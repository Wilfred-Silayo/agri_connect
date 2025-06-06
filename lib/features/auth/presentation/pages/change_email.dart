import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_state.dart'
    as auth;
import 'package:agri_connect/features/auth/presentation/widgets/auth_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authNotifierProvider.notifier)
          .changeEmail(newEmail: emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<auth.AuthState>(authNotifierProvider, (previous, next) {
      if (next is auth.AuthLoading) {
        showLoadingDialog(context, message: 'Updating email...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is auth.AuthFailure) {
        showSnackBar(context, next.message);
      } else if (next is auth.AuthSuccess) {
        showSnackBar(
          context,
          'A confirmation email has been sent to your new address.',
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text("Change Email")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'New Email'),
                validator:
                    (value) =>
                        value != null && value.contains('@')
                            ? null
                            : 'Enter valid email',
              ),
              const SizedBox(height: 20),
              AuthGradient(text: 'Update Email', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
