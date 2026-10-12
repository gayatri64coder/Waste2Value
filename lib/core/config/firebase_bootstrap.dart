import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'environment_config.dart';

/// Manages safe Firebase initialization without failing if credentials
/// are not yet supplied by the project team.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _isInitialized = false;
  static String? _statusMessage;
  static bool _isDemoFallbackActive = false;

  /// Whether Firebase was successfully initialized
  static bool get isInitialized => _isInitialized;

  /// Current human-readable status message for developers/UI
  static String get statusMessage =>
      _statusMessage ?? 'Firebase status pending check';

  /// Whether the app is operating in local development fallback mode
  static bool get isDemoFallbackActive => _isDemoFallbackActive;

  /// Safe initialization routine called at app startup
  static Future<void> initialize() async {
    try {
      // If running on web and explicit options are provided via dart-define
      if (kIsWeb && EnvironmentConfig.isFirebaseExplicitlyConfigured) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaNotRealPlaceholder', // Handled via web config
            appId: '1:1234567890:web:abcdef',
            messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
            projectId: EnvironmentConfig.firebaseProjectId,
            storageBucket: EnvironmentConfig.firebaseStorageBucket,
          ),
        );
        _isInitialized = true;
        _isDemoFallbackActive = false;
        _statusMessage = 'Firebase initialized with web options';
        debugPrint('[waste2value] Firebase initialized successfully on Web.');
        return;
      }

      // Default platform initialization (uses android/app/google-services.json on Android)
      await Firebase.initializeApp();
      _isInitialized = true;
      _isDemoFallbackActive = false;
      _statusMessage = 'Firebase successfully connected';
      debugPrint('[waste2value] Firebase initialized successfully via native config.');
    } catch (e) {
      _isInitialized = false;
      _isDemoFallbackActive = true;
      _statusMessage =
          'Firebase credentials pending (android/app/google-services.json). Operating in safe offline development mode.';
      debugPrint('------------------------------------------------------------');
      debugPrint('ℹ️ [waste2value] FIREBASE CONFIGURATION NOTICE:');
      debugPrint('  $e');
      debugPrint('  android/app/google-services.json is not yet configured.');
      debugPrint('  The app will run in Development Mode with local persistent storage.');
      debugPrint('  See README.md -> "Required Credentials and Configuration".');
      debugPrint('------------------------------------------------------------');
    }
  }
}
