# Android Build Instructions

This directory contains the Android-specific code and configuration for the AppMony application.

## Prerequisites

- Android Studio 4.2 or higher
- JDK 11 or higher
- Flutter SDK (latest stable version)
- Android SDK with API level 33 (Android 13) or higher

## Building the App

### From Android Studio

1. Open the `android` folder in Android Studio
2. Wait for Gradle sync to complete
3. Select a device or emulator
4. Click the Run button

### From Command Line

1. Navigate to the project root directory
2. Run the following command:

```bash
flutter build apk --release
```

For app bundle (recommended for Play Store):

```bash
flutter build appbundle --release
```

## Troubleshooting

### Gradle Wrapper Issues

If you encounter issues with the Gradle wrapper, try the following:

1. Make sure the Gradle wrapper files have execute permissions:

```bash
chmod +x android/gradlew
```

2. Update the Gradle wrapper:

```bash
cd android
./gradlew wrapper --gradle-version=7.5
```

### Build Failures

If the build fails, check the following:

1. Make sure all dependencies are up to date:

```bash
flutter pub get
```

2. Clean the build:

```bash
flutter clean
cd android
./gradlew clean
```

3. Check for any conflicting dependencies in `build.gradle` files

## AdMob Integration

The app uses Google AdMob for monetization. Make sure to update the AdMob app ID and ad unit IDs in:

- `android/app/src/main/AndroidManifest.xml`
- `lib/core/constants/app_constants.dart`

## In-App Purchases

The app uses Google Play Billing for premium subscriptions. Make sure to:

1. Configure your Google Play Developer account
2. Set up in-app products in the Google Play Console
3. Update the product IDs in `lib/core/constants/app_constants.dart`