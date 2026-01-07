# Utammy's Mobile App

A Flutter mobile application for selling uniforms - a clothing catalog that integrates with a Laravel API backend.

## Features

- 📱 Cross-platform support (Android & iOS)
- 🔌 Laravel API integration
- 🔐 Environment-based configuration
- 👕 Clothing catalog interface

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK 3.0.0 or higher)
- [Dart](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development - macOS only)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/pablosalazarbr/utammys-mobile-app.git
cd utammys-mobile-app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure API settings

Create a `.env` file in the root directory based on `.env.example`:

```bash
cp .env.example .env
```

Edit the `.env` file and set your Laravel API base URL:

```env
API_BASE_URL=https://your-api-url.com/api
```

### 4. Run the app

#### For Android:

```bash
flutter run
```

#### For iOS (macOS only):

```bash
cd ios
pod install
cd ..
flutter run
```

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/                # Data models
├── screens/               # UI screens
├── services/              # API and business logic services
│   └── api_service.dart   # API service with Laravel integration
└── widgets/               # Reusable UI components

android/                   # Android native configuration
ios/                       # iOS native configuration
```

## API Service

The app includes an `ApiService` class that handles all API communications with the Laravel backend. It automatically reads the base URL from the `.env` file.

### Usage Example

```dart
import 'package:utammys_mobile_app/services/api_service.dart';

// GET request
final data = await ApiService.get('products');

// POST request
final result = await ApiService.post('orders', {
  'product_id': 1,
  'quantity': 2,
});
```

## Building for Production

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

The output will be in `build/app/outputs/flutter-apk/` or `build/app/outputs/bundle/release/`

### iOS

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload to App Store.

## Development

### Run in debug mode

```bash
flutter run
```

### Run tests

```bash
flutter test
```

### Format code

```bash
flutter format .
```

### Analyze code

```bash
flutter analyze
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `API_BASE_URL` | Laravel API base URL | `https://api.example.com/api` |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For support, please contact the development team or open an issue in the repository.