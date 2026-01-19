# Project Architecture

## Overview

Utammy's Mobile App is a Flutter-based cross-platform mobile application designed to serve as a clothing catalog for selling uniforms. The app communicates with a Laravel API backend.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Utammy's Mobile App                      │
│                    (Flutter Application)                     │
└─────────────────────────────────────────────────────────────┘
                             │
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
        ▼                                         ▼
┌───────────────┐                         ┌──────────────┐
│   Android     │                         │     iOS      │
│   Platform    │                         │   Platform   │
│  (API 21+)    │                         │  (12.0+)     │
└───────────────┘                         └──────────────┘
        │                                         │
        └────────────────────┬────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  Environment   │
                    │  Config (.env) │
                    └────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  API Service   │
                    │     Layer      │
                    └────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  Laravel API   │
                    │   (Backend)    │
                    └────────────────┘
```

## Layer Architecture

### 1. Presentation Layer (UI)
**Location:** `lib/screens/` and `lib/widgets/`

**Responsibilities:**
- Display data to users
- Handle user interactions
- Navigate between screens
- Show loading states and errors

**Current Implementation:**
- `lib/main.dart` - Entry point with HomePage
- Material Design 3 theme
- Basic navigation structure

**Future Components:**
- Product listing screen
- Product detail screen
- Shopping cart
- Checkout flow
- User profile

### 2. Business Logic Layer
**Location:** `lib/services/`

**Responsibilities:**
- API communication
- Data transformation
- Business rules
- State management

**Current Implementation:**
- `lib/services/api_service.dart` - HTTP client wrapper
  - GET requests
  - POST requests
  - Error handling
  - URL normalization

**Future Components:**
- Authentication service
- Cart management service
- Order service
- Product service

### 3. Data Layer
**Location:** `lib/models/`

**Responsibilities:**
- Data structures
- JSON serialization
- Data validation

**Current Implementation:**
- Directory structure ready

**Future Components:**
- Product model
- Category model
- Order model
- User model
- Cart model

### 4. Configuration Layer
**Location:** `.env`

**Responsibilities:**
- Environment-specific configuration
- API endpoints
- API keys (future)
- Feature flags (future)

**Current Implementation:**
- `API_BASE_URL` configuration
- flutter_dotenv integration

## Data Flow

```
┌──────────────┐
│     User     │
│  Interaction │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Screen/    │
│   Widget     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Service    │
│    Layer     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ API Service  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ HTTP Request │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Laravel API  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Response   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Model     │
│ (Parse JSON) │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Update    │
│   UI State   │
└──────────────┘
```

## API Communication

### Request Flow
1. Screen/Widget initiates action
2. Calls service method
3. Service calls ApiService
4. ApiService constructs URL from .env
5. Makes HTTP request
6. Receives response
7. Parses JSON
8. Returns data or throws error
9. Screen updates UI

### Error Handling Flow
```
API Request → Try/Catch → Error?
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
               Yes                    No
                │                     │
                ▼                     ▼
        Throw Exception         Return Data
                │                     │
                ▼                     │
        Catch in Widget               │
                │                     │
                ▼                     ▼
         Show Error UI          Update UI
```

## Platform-Specific Architecture

### Android Structure
```
android/
├── app/
│   ├── build.gradle          # App-level build config
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── kotlin/           # Native Android code
│       └── res/              # Android resources
├── build.gradle              # Project-level build config
└── settings.gradle           # Project settings
```

### iOS Structure
```
ios/
├── Runner/
│   ├── Info.plist            # iOS app configuration
│   ├── AppDelegate.swift     # iOS app delegate
│   └── Assets.xcassets/      # iOS assets
├── Podfile                   # CocoaPods dependencies
├── Runner.xcodeproj/         # Xcode project
└── Runner.xcworkspace/       # Xcode workspace
```

## State Management Strategy

### Current: StatefulWidget
- Simple state management
- Good for single-screen state
- No external dependencies

### Future Considerations:
- **Provider** - For medium complexity
- **Riverpod** - For larger apps
- **Bloc** - For complex state machines

## Security Architecture

### Current Measures:
1. **Environment Variables**
   - Sensitive config in .env
   - .env excluded from git
   
2. **HTTPS Communication**
   - API calls over HTTPS (when configured)
   
3. **Error Handling**
   - No sensitive data in error messages

### Future Enhancements:
1. **Authentication**
   - JWT token management
   - Secure token storage
   
2. **Data Encryption**
   - Encrypt sensitive local data
   
3. **Certificate Pinning**
   - Prevent MITM attacks

## Dependency Management

### Core Dependencies:
- `flutter`: Framework
- `flutter_dotenv`: Environment config
- `http`: API communication
- `cupertino_icons`: iOS icons

### Dev Dependencies:
- `flutter_test`: Testing
- `flutter_lints`: Code quality

### Future Dependencies (as needed):
- `provider` / `riverpod`: State management
- `cached_network_image`: Image caching
- `shared_preferences`: Local storage
- `flutter_secure_storage`: Secure storage

## Testing Strategy

### Current:
- Unit tests for ApiService
- Test structure in place

### Future:
- Widget tests for UI components
- Integration tests for flows
- Mock API responses
- Test coverage goals

## Build & Deployment

### Android:
1. Debug builds for development
2. Release builds signed with keystore
3. App Bundle for Play Store

### iOS:
1. Debug builds for development
2. Release builds with distribution certificate
3. Archive for App Store

## Scalability Considerations

### Code Organization:
- Modular structure
- Feature-based organization possible
- Clean separation of concerns

### Performance:
- Lazy loading for lists
- Image caching (to be added)
- Efficient state updates

### Maintainability:
- Comprehensive documentation
- Consistent code style
- Linting enabled
- Version control

## File Organization Best Practices

```
lib/
├── main.dart              # Keep minimal - just app setup
├── models/                # One model per file
│   └── product.dart
├── screens/               # One screen per file
│   ├── home_screen.dart
│   └── product_screen.dart
├── services/              # Logical service grouping
│   ├── api_service.dart
│   └── auth_service.dart
└── widgets/               # Reusable components
    └── product_card.dart
```

## Environment Configuration

### Development:
```
API_BASE_URL=http://localhost:8000/api
```

### Staging:
```
API_BASE_URL=https://staging-api.example.com/api
```

### Production:
```
API_BASE_URL=https://api.example.com/api
```

## Conclusion

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Scalable structure
- ✅ Platform independence
- ✅ Easy testing
- ✅ Maintainable codebase
- ✅ Secure configuration
- ✅ Future-ready design

The foundation is solid for building a production-ready e-commerce mobile application.
