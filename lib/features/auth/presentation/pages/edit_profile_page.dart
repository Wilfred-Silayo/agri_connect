import 'dart:io';

import 'package:agri_connect/core/shared/widgets/custom_profile_image.dart';
import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_state.dart'
    as auth;
import 'package:agri_connect/features/auth/presentation/widgets/auth_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool isUsernameAvailable = true;
  bool checkingUsername = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    fullNameController = TextEditingController(text: user.fullName);
    usernameController = TextEditingController(text: user.username ?? '');
    bioController = TextEditingController(text: user.bio ?? '');
    phoneController = TextEditingController(text: user.phone ?? '');
    addressController = TextEditingController(text: user.address ?? '');

    usernameController.addListener(
      () => _checkUsername(usernameController.text),
    );
  }

  Future<void> _checkUsername(String username) async {
    if (username.trim().isEmpty || username == widget.user.username) return;
    setState(() => checkingUsername = true);

    final isAvailable = await ref
        .read(authNotifierProvider.notifier)
        .checkUsernameAvailability(username);

    setState(() {
      isUsernameAvailable = isAvailable;
      checkingUsername = false;
    });
  }

  File? _newProfileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newProfileImage = File(picked.path));
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate() && isUsernameAvailable) {
      final updatedUser = widget.user.copyWith(
        fullName: fullNameController.text.trim(),
        username: usernameController.text.trim(),
        bio: bioController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
      );

      await ref
          .read(authNotifierProvider.notifier)
          .updateUserProfile(updatedUser, _newProfileImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<auth.AuthState>(authNotifierProvider, (previous, next) {
      if (next is auth.AuthLoading) {
        showLoadingDialog(context, message: 'Updating profile...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is auth.AuthFailure) {
        print(next.message);
        showSnackBar(context, next.message);
      } else if (next is auth.AuthSuccess) {
        showSnackBar(context, "Profile updated successfully");
        Navigator.pop(context, true);
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CustomProfileImage(
                      url: widget.user.avatarUrl,
                      localImage: _newProfileImage,
                      radius: 50,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  suffixIcon:
                      checkingUsername
                          ? const CircularProgressIndicator()
                          : isUsernameAvailable
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.close, color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!isUsernameAvailable) return 'Username is already taken';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 20),
              AuthGradient(text: 'Save Changes', onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }
}
