# Quick Reference Guide

## Common Commands

### Setup & Installation
```bash
# Install dependencies
flutter pub get

# Check Flutter setup
flutter doctor

# Create .env file
cp .env.example .env
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Building
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Xcode on macOS)
flutter build ios --release
```

### Development
```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Run specific test file
flutter test test/api_service_test.dart

# Clean build artifacts
flutter clean
```

### iOS Specific
```bash
# Install CocoaPods dependencies
cd ios && pod install && cd ..

# Update CocoaPods
cd ios && pod update && cd ..

# Open in Xcode
open ios/Runner.xcworkspace
```

### Android Specific
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Build debug APK
flutter build apk --debug

# Open Android project in Android Studio
open -a "Android Studio" android/
```

## API Service Usage

### Basic GET Request
```dart
import 'package:utammys_mobile_app/services/api_service.dart';

// Fetch products
final products = await ApiService.get('products');
print(products);

// Fetch specific product
final product = await ApiService.get('products/1');
```

### Basic POST Request
```dart
import 'package:utammys_mobile_app/services/api_service.dart';

// Create order
final order = await ApiService.post('orders', {
  'product_id': 1,
  'quantity': 2,
  'customer_name': 'John Doe',
});
```

### With Error Handling
```dart
try {
  final data = await ApiService.get('products');
  // Handle success
  setState(() {
    products = data['products'];
  });
} catch (e) {
  // Handle error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

## Environment Configuration

### .env File Format
```env
API_BASE_URL=https://your-api-url.com/api
```

### Accessing in Code
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Get API URL
final apiUrl = dotenv.env['API_BASE_URL'];
```

## Project Structure

```
lib/
├── main.dart           # App entry point
├── models/             # Data models
│   └── product.dart    # Example: Product model
├── screens/            # Full-page screens
│   ├── home_screen.dart
│   └── product_detail_screen.dart
├── services/           # Business logic
│   └── api_service.dart
└── widgets/            # Reusable components
    └── product_card.dart
```

## Creating New Features

### 1. Create a Model
```dart
// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
    );
  }
}
```

### 2. Create a Screen
```dart
// lib/screens/products_screen.dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final data = await ApiService.get('products');
      setState(() {
        products = data['products'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(products[index]['name']),
        );
      },
    );
  }
}
```

### 3. Create a Widget
```dart
// lib/widgets/product_card.dart
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(imageUrl),
          Text(name),
          Text('\$$price'),
        ],
      ),
    );
  }
}
```

## Troubleshooting

### "flutter: command not found"
Add Flutter to PATH or use full path to flutter binary.

### "No connected devices"
- Android: Start an emulator or connect a physical device
- iOS: Start a simulator or connect an iOS device

### "Could not find .env"
Create a .env file: `cp .env.example .env`

### Build errors after git pull
```bash
flutter clean
flutter pub get
# For iOS
cd ios && pod install && cd ..
```

## Hot Reload & Restart

While app is running:
- `r` - Hot reload (fast, preserves state)
- `R` - Hot restart (slower, resets state)
- `q` - Quit

## Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)
- [Flutter Packages](https://pub.dev/)

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/product-listing

# Make changes and commit
git add .
git commit -m "feat: add product listing screen"

# Push to remote
git push origin feature/product-listing

# Create pull request on GitHub
```
