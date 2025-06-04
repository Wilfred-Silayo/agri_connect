import 'package:agri_connect/core/config/supabase_config.dart';
import 'package:agri_connect/core/shared/pages/error_page.dart';
import 'package:agri_connect/core/shared/pages/loading_page.dart';
import 'package:agri_connect/core/themes/themes.dart';
import 'package:agri_connect/features/auth/presentation/pages/sign_in_page.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/products/presentation/pages/products_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Load .env in production mode, .env.development otherwise
  await dotenv.load(fileName: kReleaseMode ? '.env' : '.env.development');

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agri connect',
      theme: AppTheme.agriThemeLight,
      home: ref
          .watch(authStateProvider)
          .when(
            data: (user) {
              if (user == null) {
                return SignInPage();
              }
              return ProductsPage();
            },
            error: (error, st) => ErrorPage(error: error.toString()),
            loading: () => const LoadingPage(),
          ),
    );
  }
}
