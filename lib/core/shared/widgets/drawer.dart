import 'package:agri_connect/core/enums/user_enums.dart';
import 'package:agri_connect/core/shared/widgets/custom_dialog.dart';
import 'package:agri_connect/core/shared/widgets/drawer_header.dart';
import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/auth/presentation/pages/change_email.dart';
import 'package:agri_connect/features/auth/presentation/pages/change_password.dart';
import 'package:agri_connect/features/auth/presentation/pages/profile_page.dart';
import 'package:agri_connect/features/auth/presentation/pages/sign_in_page.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_state.dart'
    as auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  const CustomDrawer({super.key});

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    // Listen for sign-out state changes
    ref.listen<auth.AuthState>(authNotifierProvider, (previous, next) {
      if (next is auth.AuthLoading) {
        showLoadingDialog(context, message: 'Signing out...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is auth.AuthFailure) {
        showSnackBar(context, next.message);
      } else if (next is auth.AuthInitial) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    });

    // Load authenticated user from state
    final userAsync = ref.watch(authStateProvider);

    return userAsync.when(
      loading:
          () => const Drawer(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Drawer(child: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) {
          return const Drawer(child: Center(child: Text('No user')));
        }

        final userDetailsAsync = ref.watch(userDetailsProvider(user.id));

        return userDetailsAsync.when(
          loading:
              () => const Drawer(
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (e, _) {
            return Drawer(
              child: Center(child: Text('Error loading user details: $e')),
            );
          },
          data: (userData) {
            if (userData == null) {
              return const Drawer(child: Center(child: Text('No user')));
            }
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserDrawerHeader(user: userData),
                  ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text('MarketPlace'),
                    onTap: () => Navigator.pop(context),
                  ),
                  (userData.userType == UserType.farmer ||
                          userData.userType == UserType.farmerAndBuyer)
                      ? ListTile(
                        leading: Icon(Icons.inventory),
                        title: Text('Stocks'),
                      )
                      : SizedBox(),
                  ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text('Orders'),
                  ),
                  (userData.userType == UserType.farmer ||
                          userData.userType == UserType.farmerAndBuyer)
                      ? ListTile(
                        leading: Icon(Icons.point_of_sale),
                        title: Text('Sales'),
                      )
                      : SizedBox(),
                  (userData.userType == UserType.buyer ||
                          userData.userType == UserType.farmerAndBuyer)
                      ? ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title: Text('Purchases'),
                      )
                      : SizedBox(),
                  ExpansionTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    childrenPadding: const EdgeInsets.only(left: 40),
                    children: [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Profile'),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ),
                            ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Change Email'),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeEmailPage(),
                              ),
                            ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordPage(),
                              ),
                            ),
                      ),

                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Sign Out'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                title: 'Logout',
                                content: 'Are you sure you want to logout?',
                                onConfirm: () async {
                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .signOut();
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
