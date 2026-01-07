# Setup Instructions

## Prerequisites

1. Install Flutter SDK (3.0.0 or higher)
   - Visit https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. Install Platform-Specific Tools:
   - **Android**: Install Android Studio with SDK
   - **iOS** (macOS only): Install Xcode from App Store

## Quick Setup

1. **Clone and navigate to the project:**
   ```bash
   cd utammys-mobile-app
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure your API:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and set your Laravel API URL:
   ```
   API_BASE_URL=https://your-api-domain.com/api
   ```

4. **Verify setup:**
   ```bash
   flutter doctor
   ```

5. **Run the app:**
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   cd ios && pod install && cd ..
   flutter run
   ```

## Project Verification Checklist

- [ ] Flutter SDK installed and in PATH
- [ ] `flutter doctor` shows no critical issues
- [ ] `.env` file created with API_BASE_URL
- [ ] Android Studio installed (for Android development)
- [ ] Xcode installed (for iOS development on macOS)
- [ ] Dependencies installed (`flutter pub get` completed successfully)

## Common Issues

### Issue: "flutter: command not found"
**Solution:** Add Flutter to your PATH:
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

### Issue: Android licenses not accepted
**Solution:** Run:
```bash
flutter doctor --android-licenses
```

### Issue: CocoaPods not found (iOS)
**Solution:** Install CocoaPods:
```bash
sudo gem install cocoapods
```

## Development Workflow

1. **Start development:**
   ```bash
   flutter run
   ```

2. **Hot reload:** Press `r` in terminal while app is running

3. **Hot restart:** Press `R` in terminal while app is running

4. **Run tests:**
   ```bash
   flutter test
   ```

5. **Format code:**
   ```bash
   flutter format .
   ```

6. **Analyze code:**
   ```bash
   flutter analyze
   ```

## Building for Release

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS
```bash
flutter build ios --release
```
Then archive in Xcode: `open ios/Runner.xcworkspace`

## Environment Variables

The app uses a `.env` file to manage configuration. Currently supported variables:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `API_BASE_URL` | Laravel API base URL | Yes | `https://api.example.com/api` |

## Project Structure

```
utammys-mobile-app/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/
│   ├── main.dart        # App entry point
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic & API
│   │   └── api_service.dart
│   └── widgets/         # Reusable components
├── test/                # Unit tests
├── .env                 # Environment config (create from .env.example)
├── .env.example         # Environment template
├── pubspec.yaml         # Dependencies
└── README.md            # Documentation
```

## Next Steps

1. Start building your catalog screens in `lib/screens/`
2. Create product models in `lib/models/`
3. Implement API endpoints in `lib/services/api_service.dart`
4. Design reusable widgets in `lib/widgets/`

## Support

For issues or questions:
- Check the [Flutter documentation](https://flutter.dev/docs)
- Review the project README.md
- Open an issue in the repository
