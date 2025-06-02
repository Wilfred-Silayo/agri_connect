import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final supabaseUrl =
      kIsWeb
          ? const String.fromEnvironment('SUPABASE_URL')
          : dotenv.env['SUPABASE_URL']!;

  static final supabaseAnonKey =
      kIsWeb
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : dotenv.env['SUPABASE_ANON_KEY']!;
}
