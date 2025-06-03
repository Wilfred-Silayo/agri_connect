import 'package:agri_connect/features/auth/presentation/pages/profile_page.dart';
import 'package:agri_connect/features/auth/presentation/pages/sign_in_page.dart';
import 'package:agri_connect/features/auth/presentation/pages/sign_up_page.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
  GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
  GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
];
