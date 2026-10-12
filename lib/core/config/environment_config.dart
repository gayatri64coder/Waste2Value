/// Application Environment Mode
enum AppEnvironment {
  development,
  testing,
  production;

  static AppEnvironment fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'testing':
      case 'test':
        return AppEnvironment.testing;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }
}

/// Central configuration class for waste2value.
///
/// IMPORTANT SECURITY RULES:
/// 1. NEVER hardcode real API keys or secrets in this or any file.
/// 2. External credentials must be supplied by the project team via:
///    - android/app/google-services.json (for Firebase Android)
///    - compile-time arguments (--dart-define)
///    - local.properties or gradle environment variables (for Google Maps)
/// 3. Placeholder values (e.g. 'YOUR_GOOGLE_MAPS_API_KEY') are used strictly
///    to identify unconfigured environments without crashing the app.
class EnvironmentConfig {
  EnvironmentConfig._();

  /// Default placeholder used to detect unconfigured Google Maps key
  static const String mapsKeyPlaceholder = 'YOUR_GOOGLE_MAPS_API_KEY';

  /// Default placeholder used to detect unconfigured Firebase Project
  static const String firebaseProjectPlaceholder = 'YOUR_FIREBASE_PROJECT_ID';

  /// Current runtime environment (can be set via --dart-define=APP_ENV=production)
  static final AppEnvironment environment = AppEnvironment.fromString(
    const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
  );

  /// Application Name
  static const String appName = 'waste2value';
  static const String appTagline = 'Electronic Waste Management & Circular Valuation';
  static const String appVersion = '1.0.0+1';

  /// Firebase Project ID (supplied via --dart-define or loaded from google-services.json)
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: firebaseProjectPlaceholder,
  );

  /// Firebase Storage Bucket
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: '',
  );

  /// Firebase Messaging Sender ID
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );

  /// Google Maps API Key
  /// Provided via --dart-define or injected directly into AndroidManifest.xml
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: mapsKeyPlaceholder,
  );

  /// Optional Future External AI API Key (Post-MVP only)
  /// MVP uses zero-cost local rule-based AI engine and local FAQ chatbot.
  static const String optionalAiApiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: '',
  );

  /// Cloud Functions / Backend Base URL (optional)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Checks if Firebase configuration has been provided
  static bool get isFirebaseExplicitlyConfigured {
    return firebaseProjectId.isNotEmpty &&
        firebaseProjectId != firebaseProjectPlaceholder;
  }

  /// Checks if Google Maps API key has been supplied with a real key
  static bool get isGoogleMapsConfigured {
    return googleMapsApiKey.isNotEmpty &&
        googleMapsApiKey != mapsKeyPlaceholder;
  }

  /// Checks if an external AI API key has been supplied
  static bool get isExternalAiConfigured {
    return optionalAiApiKey.isNotEmpty;
  }

  /// True when running in development mode
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// True when running in production mode
  static bool get isProduction => environment == AppEnvironment.production;

  /// True when running in test mode
  static bool get isTesting => environment == AppEnvironment.testing;
}
