import 'package:agri_connect/core/shared/pages/error_page.dart';
import 'package:agri_connect/core/shared/widgets/custom_profile_image.dart';
import 'package:agri_connect/core/shared/widgets/loader.dart';
import 'package:agri_connect/core/utils/format_date.dart';
import 'package:agri_connect/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:agri_connect/features/messages/presentation/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userDetailsAsync = ref.watch(userDetailsProvider(userId));

    return authState.when(
      loading: () => const Loader(),
      error: (err, _) => ErrorPage(error: err.toString()),
      data: (currentUser) {
        if (currentUser == null) return const SizedBox();

        return userDetailsAsync.when(
          loading: () => const Loader(),
          error: (err, _) => ErrorPage(error: err.toString()),
          data: (user) {
            if (user == null) return const SizedBox();

            final isCurrentUser = currentUser.id == user.id;

            return Scaffold(
              appBar: AppBar(
                title: const Text('User Profile'),
                actions: [
                  if (isCurrentUser)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(user: user),
                          ),
                        );
                        if (updated == true) {
                          ref.invalidate(userDetailsProvider(user.id));
                        }
                      },
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CustomProfileImage(url: user.avatarUrl, radius: 100),
                          const SizedBox(height: 16),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user.username ?? 'no username'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.userType.type,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!isCurrentUser)
                            ActionChip(
                              avatar: const Icon(
                                Icons.message,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Send me a message',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatPage(receiver: user),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildField('Email', user.email),
                    _buildField('Phone', user.phone),
                    _buildField('Address', user.address),
                    _buildField('Bio', user.bio),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.blueGrey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Joined: ${formatDate(user.createdAt)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();

    final iconMap = {
      'Email': Icons.email,
      'Phone': Icons.phone,
      'Address': Icons.location_on,
      'Bio': Icons.info_outline,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconMap[label] ?? Icons.label, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
