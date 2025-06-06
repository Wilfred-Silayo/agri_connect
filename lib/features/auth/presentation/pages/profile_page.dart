import 'package:agri_connect/core/enums/user_enums.dart';
import 'package:agri_connect/core/shared/pages/error_page.dart';
import 'package:agri_connect/core/shared/widgets/custom_profile_image.dart';
import 'package:agri_connect/core/shared/widgets/loader.dart';
import 'package:agri_connect/core/utils/format_date.dart';
import 'package:agri_connect/features/auth/presentation/pages/edit_profile_page.dart';
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
      error: (authErr, _) => ErrorPage(error: authErr.toString()),
      data: (currentUser) {
        if (currentUser == null) return const SizedBox();

        return userDetailsAsync.when(
          loading: () => const Loader(),
          error:
              (userErr, _) =>
                  Scaffold(body: ErrorPage(error: userErr.toString())),
          data: (user) {
            if (user == null) return const SizedBox();

            final isCurrentUser = currentUser.id == user.id;
            final isFarmer =
                user.userType == UserType.farmer ||
                user.userType == UserType.farmerAndBuyer;

            return DefaultTabController(
              length: isFarmer && !isCurrentUser ? 2 : 0,
              child: Scaffold(
                body: NestedScrollView(
                  headerSliverBuilder:
                      (context, innerBoxIsScrolled) => [
                        SliverAppBar(
                          expandedHeight: 300,
                          pinned: true,
                          title: const Text('Profile'),
                          actions: [
                            if (isCurrentUser)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              EditProfilePage(user: user),
                                    ),
                                  );

                                  if (updated == true) {
                                    // Refresh userDetailsProvider
                                    ref.invalidate(
                                      userDetailsProvider(user.id),
                                    );
                                  }
                                },
                              ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: Padding(
                              padding: const EdgeInsets.only(
                                top: kToolbarHeight + 20,
                                left: 16,
                                right: 16,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomProfileImage(url: user.avatarUrl),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${user.fullName} ~ ${user.username ?? "no username"}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                user.userType.type,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildProfileField('Email', user.email),
                                    _buildProfileField('Phone', user.phone),
                                    _buildProfileField('Address', user.address),
                                    if (user.bio != null &&
                                        user.bio!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Bio:',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            Text(
                                              user.bio!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Joined: ${formatDate(user.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          bottom:
                              isFarmer && !isCurrentUser
                                  ? const TabBar(
                                    tabs: [
                                      Tab(text: 'Products'),
                                      Tab(text: 'Other Info'),
                                    ],
                                  )
                                  : null,
                        ),
                      ],
                  body:
                      isFarmer && !isCurrentUser
                          ? const TabBarView(
                            children: [
                              Center(child: Text('Products List')),
                              Center(child: Text('Additional Info')),
                            ],
                          )
                          : const SizedBox(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileField(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Text(
      '$label: $value',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
