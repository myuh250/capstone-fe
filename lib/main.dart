import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env load failed: $e');
  }

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      await FirebaseMessagingService.instance.initialize();
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((_) => prefs),
      ],
      child: const App(),
    ),
  );
}
