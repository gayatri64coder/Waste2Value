# waste2value 🌱⚡
### Sustainable Electronic Waste Management, Valuation & Circular Economy Platform

`waste2value` is a Flutter application designed to connect individuals and enterprises with certified e-waste recyclers (R2v3 / e-Stewards). It features real-time rule-based device valuation, precious metals recovery estimation (Gold, Silver, Copper, Palladium), certified collection center discovery, doorstep pickup scheduling with chain-of-custody tracking, ESG recycling certificates, and an intelligent local offline assistant (**EcoBot**).

---

## 🔒 Security & Credential Policy

This application is engineered with strict enterprise security policies:
- **NO credentials or secret keys are hardcoded in source code.**
- **NO fake Firebase credentials or fake backends are created.**
- Sensitive configuration files (`google-services.json`, `.env`, keystores) are strictly excluded in `.gitignore` and must **never** be committed to GitHub.
- **Graceful Bootstrap**: If any external credential is not yet configured, the app compiles and operates smoothly in a dedicated **Local Development & Offline Mode**, enabling continuous UI, logic, and feature development without crashes or blockers.

---

## Required Credentials and Configuration

All external credentials and API keys are to be supplied by the project owner/team. Below is the comprehensive guide for each required credential:

### 1. Firebase Project Configuration
* **Where the team obtains it:**
  1. Open the [Firebase Console](https://console.firebase.google.com/).
  2. Click **Create Project** (or select your existing project).
  3. Enable the required Firebase services:
     - **Firebase Authentication**: Email/Password sign-in provider.
     - **Cloud Firestore**: Create database in production or test mode.
     - **Firebase Storage**: Standard storage bucket for device inspection photos.
     - **Firebase Cloud Messaging (FCM)**: For pickup status alerts and notifications.
* **Where it should be configured:**
  - In your environment config file `.env` (copied from `.env.example`) or via compile-time Dart defines:
    ```bash
    --dart-define=FIREBASE_PROJECT_ID=your-actual-firebase-project-id \
    --dart-define=FIREBASE_STORAGE_BUCKET=your-actual-project.appspot.com
    ```
* **Whether it is required for the MVP:**
  - **Required for cloud synchronization in production.**
  - **NOT blocking development**: If not yet created, the application runs automatically with local dual-mode repositories (`AuthRepository`, `EwasteRepository`, `PickupRepository`), allowing full offline testing, UI reviews, and demo walkthroughs.

---

### 2. Firebase Android Configuration
* **Where the team obtains it:**
  1. Go to **Firebase Console** > **Project Settings** > **General**.
  2. Under **Your apps**, click **Add App** and select **Android**.
  3. Register the package name:
     ```
     com.waste2value.app
     ```
  4. Download the generated configuration file: `google-services.json`.
* **Where it should be configured:**
  - Place the downloaded file into the Android app directory:
    ```
    android/app/google-services.json
    ```
  - **Gradle Integration**: `android/app/build.gradle.kts` dynamically checks for this file:
    - If present, the `com.google.gms.google-services` plugin applies automatically.
    - If absent, Gradle logs a clear development notice and compiles successfully without crashing.
* **Whether it is required for the MVP:**
  - **Required for live Android Firebase authentication and Firestore syncing.**
  - **NOT blocking development**: Unrelated features continue to function seamlessly when the file is pending.

---

### 3. Google Maps API Key
* **Where the team obtains it:**
  1. Open the [Google Cloud Console](https://console.cloud.google.com/).
  2. Navigate to **APIs & Services** > **Credentials**.
  3. Click **Create Credentials** > **API Key**.
  4. Enable the following APIs:
     - **Maps SDK for Android**
     - **Places API** (optional for address autocomplete)
     - **Maps JavaScript API** (if building for web)
  5. Restrict the API key by Android app package name (`com.waste2value.app`) and SHA-1 fingerprint for production security.
* **Where it should be configured:**
  - **Option A (Recommended for Android)**: Add to `android/local.properties` (which is gitignored):
    ```properties
    MAPS_API_KEY=AIzaSyYourActualGoogleMapsApiKeyHere
    ```
  - **Option B**: Pass via `--dart-define` during run:
    ```bash
    --dart-define=GOOGLE_MAPS_API_KEY=AIzaSyYourActualGoogleMapsApiKeyHere
    ```
  - The placeholder `YOUR_GOOGLE_MAPS_API_KEY` is present in `AndroidManifest.xml` and `build.gradle.kts` strictly as a fallback to prevent compilation failure when the key has not yet been set.
* **Whether it is required for the MVP:**
  - **Required for live vector and satellite Google Maps rendering.**
  - **NOT blocking development**: If the key is unavailable, the application provides a clearly marked **Development Fallback**:
    - An interactive **GPS Collection Center Radar** visualization showing relative distances, pins, and center statuses.
    - Full list search, R2/e-Stewards filters, operating hours, and drop-off booking.

---

### 4. Any Optional Future AI API Key
* **Where the team obtains it:**
  - [Google AI Studio](https://aistudio.google.com/) for Gemini API keys (or chosen LLM provider).
* **Where it should be configured:**
  - In `.env` (or via `--dart-define=AI_API_KEY=your_key`).
  - Handled cleanly in `lib/domain/ai/external_ai_service.dart`.
* **Whether it is required for the MVP:**
  - **NO. The MVP MUST NOT require a paid external AI API.**
  - `waste2value` includes a **100% offline, zero-cost, rule-based AI suite**:
    1. **EwasteValuationEngine**: Rule-based economic appraisal, precious metals (Gold, Silver, Copper, Palladium) estimation, carbon offset calculation (kg CO₂e), and hazard risk scoring.
    2. **DeviceInspectionClassifier**: Local heuristic diagnostic checklist for screens, swollen batteries, and port integrity.
    3. **EcobotFaqEngine**: Intelligent NLP keyword and intent-matching local FAQ advisor for data sanitization, lithium-ion safety, and recycling standards.

---

## Environment Configuration

The application supports three distinct environments:
- `development` (Default - enables mock fallbacks and verbose diagnostics)
- `testing`
- `production`

### Running with Environments

#### Development Mode (Default)
```bash
flutter run
```

#### Production Mode with Real Credentials
```bash
flutter run \
  --dart-define=APP_ENV=production \
  --dart-define=FIREBASE_PROJECT_ID=your-firebase-project-id \
  --dart-define=GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

### System Diagnostics Screen
At any time, navigate to the **System** tab in the bottom navigation bar (or tap the top status banner) to view the live status of all credentials, inspect current environment parameters, and test different user roles (Citizen, Recycler, Enterprise).

---

## Project Structure

```
lib/
├── core/
│   └── config/
│       ├── environment_config.dart     # Central environment & credentials handler
│       └── firebase_bootstrap.dart     # Safe non-crashing Firebase initialization
├── data/
│   ├── repositories/
│   │   ├── auth_repository.dart        # Dual-mode Firebase Auth + Dev persona sessions
│   │   ├── ewaste_repository.dart      # Dual-mode Firestore + local cached listings
│   │   ├── collection_center_repository.dart # Certified drop-off hubs & Haversine distance
│   │   └── pickup_repository.dart      # Doorstep collection milestones & scheduling
│   └── services/
│       ├── notification_service.dart   # Firebase Cloud Messaging handler
│       └── storage_service.dart        # Firebase Storage device image uploads
├── domain/
│   ├── ai/
│   │   ├── device_inspection_classifier.dart # Local diagnostic heuristic checker
│   │   ├── ecobot_faq_engine.dart      # Offline zero-cost intelligent FAQ assistant
│   │   ├── ewaste_valuation_engine.dart # E-waste pricing & precious metals model
│   │   └── external_ai_service.dart    # Secure hook for optional future external AI
│   └── models/
│       ├── chat_message.dart
│       ├── collection_center.dart
│       ├── ewaste_item.dart
│       ├── pickup_request.dart
│       ├── recycling_certificate.dart
│       └── user_profile.dart
├── ui/
│   ├── features/
│   │   ├── auth/                       # Login & registration screen
│   │   ├── certificate/                # Verifiable ESG recycling certificates
│   │   ├── collection_points/          # Dual Google Maps & interactive radar view
│   │   ├── dashboard/                  # Circular impact metrics & quick actions
│   │   ├── diagnostics/                # Live credentials audit & role switcher
│   │   ├── ecobot/                     # Offline AI chat interface
│   │   ├── pickups/                    # Doorstep collection booking & QR tracker
│   │   └── valuation/                  # Interactive appraisal wizard
│   ├── theme/
│   │   └── app_theme.dart              # Curated eco-tech palette & styling
│   └── widgets/
│       └── system_status_banner.dart   # Non-intrusive environment & credentials pill
└── main.dart                           # Application entrypoint & bottom navigation
```

---

## Running Automated Tests

```bash
flutter test
```
Includes comprehensive unit tests for `EwasteValuationEngine`, `DeviceInspectionClassifier`, `EcobotFaqEngine`, and smoke tests for the UI.
