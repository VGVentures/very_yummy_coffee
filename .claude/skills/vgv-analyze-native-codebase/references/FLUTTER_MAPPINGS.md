# Native to Flutter Package Mappings

Comprehensive reference for mapping native iOS and Android dependencies to Flutter equivalents.

## Quick Reference

| Category | iOS | Android | Flutter |
|----------|-----|---------|---------|
| Networking | Alamofire, Moya | Retrofit, OkHttp | dio, http |
| State Mgmt | Combine, RxSwift | LiveData, StateFlow | bloc, riverpod |
| Database | CoreData, Realm | Room, SQLDelight | drift, sqflite |
| DI | Swinject, Resolver | Hilt, Koin | get_it, injectable |
| Images | SDWebImage, Kingfisher | Glide, Coil | cached_network_image |
| Analytics | Firebase, Mixpanel | Firebase, Amplitude | firebase_analytics |
| Crashes | Crashlytics, Sentry | Crashlytics, Sentry | firebase_crashlytics, sentry_flutter |
| Auth | Firebase Auth | Firebase Auth | firebase_auth |
| Push | APNs, FCM | FCM | firebase_messaging |
| JSON | Codable | Moshi, Gson | json_serializable, freezed |
| Navigation | Coordinators | Navigation Component | go_router, auto_route |
| Testing | XCTest, Quick | JUnit, MockK | flutter_test, mocktail |
| Payments | StoreKit | Play Billing | in_app_purchase |
| Maps | MapKit | Google Maps SDK | google_maps_flutter |
| Storage | UserDefaults, Keychain | SharedPreferences, EncryptedSP | shared_preferences, flutter_secure_storage |

---

## 1. Networking

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Alamofire** | `dio` | Similar | dio provides similar interceptor/adapter patterns |
| **Moya** | `dio` + `retrofit` | Similar | Moya's abstraction maps well to retrofit code generation |
| **URLSession** | `http` | Similar | For simpler use cases; dio for complex |
| **AFNetworking** (ObjC) | `http`, `dio` | Similar | Legacy; consider modernizing patterns |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Retrofit** | `dio` + `retrofit` | Drop-in | retrofit package generates similar code |
| **OkHttp** | `dio` | Similar | dio's interceptors mirror OkHttp |
| **Ktor** | `dio` | Similar | Multiplatform experience transfers |
| **Volley** | `http` | Similar | Legacy; simpler patterns |

### Flutter Packages

```yaml
dependencies:
  dio: ^5.4.0           # Full-featured HTTP client
  http: ^1.2.0          # Simple HTTP requests
  retrofit: ^4.1.0      # Type-safe API client (code gen)
  chopper: ^7.2.0       # Alternative to retrofit
```

---

## 2. State Management

### iOS Approaches

| Approach | Flutter Equivalent | Mapping Type | Notes |
|----------|-------------------|--------------|-------|
| **Combine** | `bloc`, `riverpod` | Similar | Reactive streams -> bloc streams |
| **RxSwift** | `bloc`, `rxdart` | Similar | Operators map to rxdart |
| **ObservableObject** (SwiftUI) | `riverpod`, `provider` | Similar | Property wrappers -> providers |
| **TCA** (Composable Architecture) | `bloc` | Partial | Reducers map well to blocs |

### Android Approaches

| Approach | Flutter Equivalent | Mapping Type | Notes |
|----------|-------------------|--------------|-------|
| **LiveData** | `bloc`, `riverpod` | Similar | Lifecycle-aware -> StreamBuilder |
| **StateFlow/SharedFlow** | `bloc`, `rxdart` | Similar | Cold/hot streams map directly |
| **RxJava** | `rxdart`, `bloc` | Similar | Operators available in rxdart |
| **MVI** | `bloc` | Drop-in | Intent/State/Effect -> Event/State |

### Flutter Packages

```yaml
dependencies:
  flutter_bloc: ^8.1.0  # BLoC pattern (VGV recommended)
  bloc: ^8.1.0          # Core bloc library
  riverpod: ^2.5.0      # Alternative state management
  provider: ^6.1.0      # Simple dependency injection + state
  rxdart: ^0.27.0       # Reactive extensions for Dart
```

---

## 3. Database / Persistence

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **CoreData** | `drift`, `sqflite` | Partial | ORM -> drift; raw SQL -> sqflite |
| **Realm** | `realm`, `isar` | Drop-in | Realm has Flutter SDK |
| **GRDB** | `drift` | Similar | SQL-focused approach |
| **SQLite.swift** | `sqflite` | Similar | Direct SQL mapping |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Room** | `drift`, `floor` | Similar | floor is Room-inspired for Flutter |
| **SQLDelight** | `drift` | Similar | Both use code generation |
| **Realm** | `realm`, `isar` | Drop-in | Realm has Flutter SDK |
| **ObjectBox** | `objectbox` | Drop-in | ObjectBox has Flutter support |

### Flutter Packages

```yaml
dependencies:
  drift: ^2.15.0        # Type-safe SQL with code gen (VGV recommended)
  sqflite: ^2.3.0       # Raw SQLite access
  floor: ^1.4.0         # Room-inspired ORM
  isar: ^3.1.0          # NoSQL database
  hive: ^2.2.0          # Lightweight key-value store
  realm: ^2.0.0         # Realm database
```

---

## 4. Dependency Injection

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Swinject** | `get_it` + `injectable` | Similar | Container pattern maps well |
| **Resolver** | `get_it` | Similar | Property wrapper -> GetIt.I |
| **Factory** | `get_it` | Similar | Factory methods supported |
| **Manual DI** | `get_it`, `riverpod` | Similar | Constructor injection |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Hilt** | `get_it` + `injectable` | Similar | Annotation-based -> code gen |
| **Koin** | `get_it` | Similar | DSL-style registration |
| **Dagger** | `get_it` + `injectable` | Similar | More complex; injectable helps |
| **Manual DI** | `get_it`, `riverpod` | Similar | Constructor injection |

### Flutter Packages

```yaml
dependencies:
  get_it: ^7.6.0        # Service locator (VGV recommended)
  injectable: ^2.3.0    # Code gen for get_it
  riverpod: ^2.5.0      # DI + state combined

dev_dependencies:
  injectable_generator: ^2.4.0
```

---

## 5. Image Loading

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **SDWebImage** | `cached_network_image` | Similar | Caching behavior maps well |
| **Kingfisher** | `cached_network_image` | Similar | SwiftUI-like API |
| **Nuke** | `cached_network_image` | Similar | Pipeline approach |
| **AlamofireImage** | `cached_network_image` | Similar | Alamofire integration -> dio |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Glide** | `cached_network_image` | Similar | Transformations available |
| **Coil** | `cached_network_image` | Similar | Kotlin-first -> Dart-friendly |
| **Picasso** | `cached_network_image` | Similar | Simpler API |
| **Fresco** | `cached_network_image` | Partial | Advanced features may need custom |

### Flutter Packages

```yaml
dependencies:
  cached_network_image: ^3.3.0  # Network image with caching
  flutter_svg: ^2.0.0           # SVG rendering
  extended_image: ^8.2.0        # Advanced image features
  photo_view: ^0.14.0           # Zoomable images
```

---

## 6. Analytics

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Firebase Analytics** | `firebase_analytics` | Drop-in | Same SDK, different syntax |
| **Mixpanel** | `mixpanel_flutter` | Drop-in | Official Flutter SDK |
| **Amplitude** | `amplitude_flutter` | Drop-in | Official Flutter SDK |
| **Segment** | `analytics` | Drop-in | Official Flutter SDK |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Firebase Analytics** | `firebase_analytics` | Drop-in | Same SDK |
| **Mixpanel** | `mixpanel_flutter` | Drop-in | Official Flutter SDK |
| **Amplitude** | `amplitude_flutter` | Drop-in | Official Flutter SDK |
| **Adjust** | `adjust_sdk` | Drop-in | Attribution tracking |

### Flutter Packages

```yaml
dependencies:
  firebase_analytics: ^10.8.0   # Firebase Analytics
  mixpanel_flutter: ^2.2.0      # Mixpanel
  amplitude_flutter: ^3.16.0    # Amplitude
  analytics: ^2.2.0             # Segment
```

---

## 7. Crash Reporting

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Crashlytics** | `firebase_crashlytics` | Drop-in | Same backend |
| **Sentry** | `sentry_flutter` | Drop-in | Official Flutter SDK |
| **Bugsnag** | `bugsnag_flutter` | Drop-in | Official Flutter SDK |
| **Instabug** | `instabug_flutter` | Drop-in | Bug reporting + crashes |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Crashlytics** | `firebase_crashlytics` | Drop-in | Same backend |
| **Sentry** | `sentry_flutter` | Drop-in | Official Flutter SDK |
| **Bugsnag** | `bugsnag_flutter` | Drop-in | Official Flutter SDK |
| **AppCenter** | Custom | Partial | Limited Flutter support |

### Flutter Packages

```yaml
dependencies:
  firebase_crashlytics: ^3.4.0  # Firebase Crashlytics
  sentry_flutter: ^7.16.0       # Sentry
  bugsnag_flutter: ^3.0.0       # Bugsnag
```

---

## 8. Authentication

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Firebase Auth** | `firebase_auth` | Drop-in | Same backend |
| **Auth0** | `auth0_flutter` | Drop-in | Official Flutter SDK |
| **AppAuth** | `flutter_appauth` | Similar | OAuth/OIDC flows |
| **Sign in with Apple** | `sign_in_with_apple` | Drop-in | Apple Sign-In |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Firebase Auth** | `firebase_auth` | Drop-in | Same backend |
| **Auth0** | `auth0_flutter` | Drop-in | Official Flutter SDK |
| **AppAuth** | `flutter_appauth` | Similar | OAuth/OIDC flows |
| **Google Sign-In** | `google_sign_in` | Drop-in | Google authentication |

### Flutter Packages

```yaml
dependencies:
  firebase_auth: ^4.17.0        # Firebase Auth
  google_sign_in: ^6.2.0        # Google Sign-In
  sign_in_with_apple: ^5.0.0    # Apple Sign-In
  flutter_appauth: ^6.0.0       # OAuth/OIDC
  auth0_flutter: ^1.5.0         # Auth0
```

---

## 9. Push Notifications

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **APNs (native)** | `firebase_messaging` | Similar | FCM wraps APNs |
| **Firebase Cloud Messaging** | `firebase_messaging` | Drop-in | Same SDK |
| **OneSignal** | `onesignal_flutter` | Drop-in | Official Flutter SDK |
| **Urban Airship** | `airship_flutter` | Drop-in | Official Flutter SDK |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Firebase Cloud Messaging** | `firebase_messaging` | Drop-in | Same SDK |
| **OneSignal** | `onesignal_flutter` | Drop-in | Official Flutter SDK |
| **Urban Airship** | `airship_flutter` | Drop-in | Official Flutter SDK |

### Flutter Packages

```yaml
dependencies:
  firebase_messaging: ^14.7.0   # FCM
  flutter_local_notifications: ^16.3.0  # Local notifications
  onesignal_flutter: ^5.1.0     # OneSignal
  awesome_notifications: ^0.8.0 # Advanced notifications
```

---

## 10. JSON Parsing / Serialization

### iOS Approaches

| Approach | Flutter Equivalent | Mapping Type | Notes |
|----------|-------------------|--------------|-------|
| **Codable** | `json_serializable`, `freezed` | Similar | Code gen approach |
| **SwiftyJSON** | `dart:convert` | Similar | Dynamic access |
| **ObjectMapper** | `json_serializable` | Similar | Mapping approach |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Moshi** | `json_serializable` | Similar | Code gen, adapters |
| **Gson** | `json_serializable` | Similar | Annotation-based |
| **kotlinx.serialization** | `json_serializable`, `freezed` | Similar | KMP-style |

### Flutter Packages

```yaml
dependencies:
  freezed_annotation: ^2.4.0    # Immutable classes (VGV recommended)
  json_annotation: ^4.8.0       # JSON serialization annotations

dev_dependencies:
  build_runner: ^2.4.0          # Code generation runner
  freezed: ^2.4.0               # Freezed code gen
  json_serializable: ^6.7.0     # JSON code gen
```

---

## 11. Navigation

### iOS Patterns

| Pattern | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Coordinator** | `go_router`, `auto_route` | Similar | Centralized navigation |
| **Storyboard Segues** | `Navigator` | Partial | Imperative navigation |
| **SwiftUI Navigation** | `go_router` | Similar | Declarative routing |
| **Custom Router** | `go_router`, `auto_route` | Similar | Type-safe routing |

### Android Patterns

| Pattern | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Navigation Component** | `go_router` | Similar | Declarative nav graph |
| **Multi-Activity** | `Navigator` | Partial | Imperative navigation |
| **Compose Navigation** | `go_router` | Similar | Declarative routing |
| **Deep Links** | `go_router` | Drop-in | Built-in deep link support |

### Flutter Packages

```yaml
dependencies:
  go_router: ^13.2.0            # Declarative routing (VGV recommended)
  auto_route: ^7.8.0            # Type-safe routing with code gen
  beamer: ^1.6.0                # Alternative declarative router

dev_dependencies:
  auto_route_generator: ^7.3.0  # Auto route code gen
```

---

## 12. Testing

### iOS Frameworks

| Framework | Flutter Equivalent | Mapping Type | Notes |
|-----------|-------------------|--------------|-------|
| **XCTest** | `flutter_test` | Similar | Core testing framework |
| **Quick/Nimble** | `flutter_test` + custom | Partial | BDD-style available |
| **SnapshotTesting** | `golden_toolkit` | Similar | Screenshot testing |
| **OHHTTPStubs** | `mocktail`, `http_mock_adapter` | Similar | Network mocking |
| **Cuckoo/Mockingbird** | `mocktail`, `mockito` | Similar | Mock generation |

### Android Frameworks

| Framework | Flutter Equivalent | Mapping Type | Notes |
|-----------|-------------------|--------------|-------|
| **JUnit** | `flutter_test` | Similar | Core testing |
| **MockK** | `mocktail` | Similar | Kotlin-style mocking |
| **Mockito** | `mockito` | Drop-in | Same API style |
| **Espresso** | `integration_test` | Similar | UI testing |
| **Robolectric** | `flutter_test` | Similar | Unit tests without device |
| **Turbine** | `bloc_test` | Similar | Flow/stream testing |

### Flutter Packages

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0             # BLoC testing (VGV recommended)
  mocktail: ^1.0.0              # Mocking (VGV recommended)
  mockito: ^5.4.0               # Alternative mocking
  golden_toolkit: ^0.15.0       # Screenshot testing
  integration_test:
    sdk: flutter
```

---

## 13. In-App Purchases

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **StoreKit** | `in_app_purchase` | Similar | Official Flutter plugin |
| **StoreKit 2** | `in_app_purchase` | Partial | Some SK2 features |
| **RevenueCat** | `purchases_flutter` | Drop-in | Official Flutter SDK |
| **Adapty** | `adapty_flutter` | Drop-in | Official Flutter SDK |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Google Play Billing** | `in_app_purchase` | Similar | Official Flutter plugin |
| **RevenueCat** | `purchases_flutter` | Drop-in | Official Flutter SDK |
| **Adapty** | `adapty_flutter` | Drop-in | Official Flutter SDK |

### Flutter Packages

```yaml
dependencies:
  in_app_purchase: ^3.1.0       # Official IAP plugin
  purchases_flutter: ^6.17.0    # RevenueCat
  adapty_flutter: ^2.10.0       # Adapty
```

---

## 14. Maps

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **MapKit** | `apple_maps_flutter` | Similar | Apple Maps in Flutter |
| **Google Maps SDK** | `google_maps_flutter` | Drop-in | Same SDK |
| **Mapbox** | `mapbox_maps_flutter` | Drop-in | Official Flutter SDK |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **Google Maps SDK** | `google_maps_flutter` | Drop-in | Same SDK |
| **Mapbox** | `mapbox_maps_flutter` | Drop-in | Official Flutter SDK |
| **OpenStreetMap** | `flutter_map` | Similar | OSM support |

### Flutter Packages

```yaml
dependencies:
  google_maps_flutter: ^2.5.0   # Google Maps
  apple_maps_flutter: ^2.1.0    # Apple Maps
  mapbox_maps_flutter: ^1.0.0   # Mapbox
  flutter_map: ^6.1.0           # OpenStreetMap
```

---

## 15. Local Storage

### iOS Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **UserDefaults** | `shared_preferences` | Drop-in | Key-value storage |
| **Keychain** | `flutter_secure_storage` | Similar | Secure storage |
| **FileManager** | `path_provider` + `dart:io` | Similar | File system access |

### Android Libraries

| Library | Flutter Equivalent | Mapping Type | Notes |
|---------|-------------------|--------------|-------|
| **SharedPreferences** | `shared_preferences` | Drop-in | Key-value storage |
| **EncryptedSharedPreferences** | `flutter_secure_storage` | Similar | Secure storage |
| **DataStore** | `shared_preferences` | Similar | Proto DataStore -> custom |
| **File storage** | `path_provider` + `dart:io` | Similar | File system access |

### Flutter Packages

```yaml
dependencies:
  shared_preferences: ^2.2.0    # Key-value storage
  flutter_secure_storage: ^9.0.0 # Secure storage
  path_provider: ^2.1.0         # File paths
  hive: ^2.2.0                  # Fast key-value database
```

---

## Mapping Types Legend

| Type | Description |
|------|-------------|
| **Drop-in** | Near-identical API, minimal changes needed |
| **Similar** | Same concepts, different syntax/approach |
| **Partial** | Some features map, others need custom work |
| **Custom** | Significant custom implementation required |
| **None** | No equivalent, requires platform channels |

---

## Migration Complexity Guidelines

When mapping dependencies:

1. **Drop-in (XS effort)**: Same SDK or official Flutter version
2. **Similar (S-M effort)**: Concepts transfer, syntax changes
3. **Partial (M-L effort)**: Core features work, advanced need custom
4. **Custom (L-XL effort)**: Platform channels or native code required
