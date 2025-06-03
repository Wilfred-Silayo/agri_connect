import 'package:agri_connect/core/config/supabase_config.dart';
import 'package:agri_connect/core/routes/router.dart';
import 'package:agri_connect/core/themes/themes.dart';
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
    final router = createRouter(ref);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Agriconnect',
      routerConfig: router,
      theme: AppTheme.agriThemeLight,
    );
  }
}
