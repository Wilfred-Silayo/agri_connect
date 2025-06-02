import 'package:agri_connect/core/routes/auth/auth_routes.dart';
import 'package:agri_connect/core/routes/product/product_routes.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(WidgetRef ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/products',
    routes: [...authRoutes, ...productRoutes],
    redirect: (context, state) {
      final currentLocation = state.uri.toString();
      // print('Redirecting from: $currentLocation');

      final isInAuthLocation =
          currentLocation == '/signin' || currentLocation == '/signup';

      return auth.when(
        data: (user) {
          if (user == null && !isInAuthLocation) return '/signin';
          if (user != null && isInAuthLocation) return '/products';
          return null;
        },
        error: (err, st) {
          showSnackBar(context, "Oops! Something went wrong.");
          return '/signin';
        },
        loading: () {
          if (isInAuthLocation) return null;
          return '/signin';
        },
      );
    },
  );
}
