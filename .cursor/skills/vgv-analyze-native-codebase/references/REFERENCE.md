# Analysis Reference Guide

Detailed instructions for each analysis step.

## Step 1: Project Discovery

1. Identify iOS project root (look for `.xcodeproj` or `.xcworkspace`)
2. Identify Android project root (look for `build.gradle` or `build.gradle.kts`)
3. Determine project type: single app, multi-module, monorepo
4. List all build targets/modules

## Step 2: Dependency Inventory

### iOS Dependencies

Check these locations:
- `Podfile` and `Podfile.lock` (CocoaPods)
- `Package.swift` and `Package.resolved` (Swift Package Manager)
- `.xcodeproj/project.pbxproj` for embedded frameworks
- Carthage's `Cartfile` if present

### Android Dependencies

Check these locations:
- `build.gradle` / `build.gradle.kts` (module and project level)
- `settings.gradle` / `settings.gradle.kts`
- `gradle/libs.versions.toml` (version catalogs)

### For Each Dependency

Determine:
- Purpose/category (networking, state management, analytics, etc.)
- Flutter equivalent (if known)
- Migration complexity (drop-in replacement, partial, custom, none)

See [FLUTTER_MAPPINGS.md](FLUTTER_MAPPINGS.md) for comprehensive native-to-Flutter package mappings.

## Step 3: Architecture Pattern Detection

### iOS Patterns

- **MVVM** - ViewModels, Bindings, Combine/RxSwift
- **VIPER** - Interactors, Presenters, Routers, Entities
- **MVC** - Traditional Apple MVC
- **TCA** - The Composable Architecture
- **Clean Architecture** - Layered structure
- **Coordinator** - Navigation pattern

### Android Patterns

- **MVVM** - ViewModels, LiveData/StateFlow
- **MVI** - Intent, State, Side Effects
- **MVP** - Presenters, Views
- **Clean Architecture** - Layered structure
- **Single Activity** - Navigation Component
- **Multi-Activity** - Explicit intents

### Pattern Indicators

Look for:
- Folder structure (`/presentation`, `/domain`, `/data`, `/features`)
- Base classes (`BaseViewModel`, `BaseFragment`, `Coordinator`)
- Dependency injection (Hilt, Koin, Swinject, Resolver)
- Reactive patterns (Combine, RxSwift, Flow, LiveData)

## Step 4: Screen & Feature Inventory

### Capture for Each Screen

- Unique identifier (from class name or route)
- Platform (iOS, Android, both)
- Screen type (list, detail, form, dashboard, auth, settings)
- UI framework (UIKit, SwiftUI, XML Views, Jetpack Compose)
- Associated ViewModel/Presenter
- Navigation entry points
- API dependencies
- Local data dependencies
- Platform-specific features used

### iOS Screen Discovery

- Parse storyboards (`.storyboard` files) for view controllers
- Find SwiftUI views (`struct X: View`)
- Locate UIKit view controllers (`class X: UIViewController`)
- Check `Info.plist` for main storyboard entry point
- Trace coordinator/router patterns for navigation graph

### Android Screen Discovery

- Parse navigation graphs (`nav_graph.xml`)
- Find Activities in `AndroidManifest.xml`
- Locate Fragments (`class X : Fragment()`)
- Find Composable functions (`@Composable fun X()`)
- Trace NavHost and NavController usage

## Step 5: API & Data Layer Analysis

### Network Layer

Identify:
- HTTP client (URLSession, Alamofire, Retrofit, Ktor, OkHttp)
- All API endpoints called
- Request/response models
- Authentication mechanisms (OAuth, JWT, API keys)
- Base URL configuration

### Swagger/OpenAPI Integration (Optional)

When a Swagger/OpenAPI specification is provided:

**Supported formats:**
- `swagger.json` / `swagger.yaml` (Swagger 2.0)
- `openapi.json` / `openapi.yaml` (OpenAPI 3.x)

**Enhanced analysis:**
| Without Swagger | With Swagger |
|----------------|--------------|
| Endpoints inferred from code | Complete endpoint inventory from spec |
| Models extracted from source | Exact schema definitions with validation rules |
| Auth patterns detected | Full auth spec (OAuth flows, scopes, API keys) |
| Manual API matching | Automatic iOS/Android endpoint correlation |

### Local Storage

Document:
- CoreData models -> Entity definitions
- Room entities -> Entity definitions
- UserDefaults/SharedPreferences keys
- Keychain/EncryptedSharedPreferences usage
- File storage patterns

### Data Models

- List all data/domain models
- Identify serialization (Codable, Moshi, Gson, kotlinx.serialization)
- Note relationships between models
- Identify shared models (used by multiple features)

## Step 6: Platform-Specific API Usage

### High Complexity (Platform Channels/FFI Required)

- HealthKit / Health Connect
- ARKit / ARCore
- CallKit / ConnectionService
- Siri Shortcuts / Google Assistant
- WidgetKit / App Widgets
- App Clips / Instant Apps
- CarPlay / Android Auto

### Medium Complexity (Plugins Exist, May Need Customization)

- Push Notifications (APNs / FCM)
- In-App Purchases (StoreKit / Google Play Billing)
- Biometrics (Face ID, Touch ID, Fingerprint)
- Background processing
- Deep linking / Universal Links / App Links
- Share extensions

### Low Complexity (Well-Supported Plugins)

- Camera
- Location
- Local notifications
- Permissions
- Device info
- Connectivity

## Step 7: Testing Infrastructure

### iOS Testing Detection

**Frameworks to identify:**
- `XCTest` - Apple's native testing framework
- `Quick` / `Nimble` - BDD-style testing
- `SnapshotTesting` (pointfreeco) - UI snapshot tests
- `OHHTTPStubs` / `Mocker` - Network mocking
- `Cuckoo` / `Mockingbird` - Mock generation

**Detection patterns:**
```
# Test targets in project
*.xcodeproj -> testTargets
*Tests/ directories

# Coverage configuration
*.xcscheme -> CodeCoverageEnabled
*.xctestplan files

# Snapshot tests
__Snapshots__/ directories
```

**Capture:**
- Test frameworks used
- Coverage percentage (from `.xcscheme` or CI reports)
- Mock tools in use
- Snapshot testing presence
- UI test (XCUITest) presence
- Test organization pattern
- Approximate test counts by type

### Android Testing Detection

**Frameworks to identify:**
- `JUnit4` / `JUnit5` - Unit testing
- `MockK` / `Mockito` - Mocking
- `Espresso` - UI testing
- `Robolectric` - Android unit tests without emulator
- `Turbine` - Flow testing
- `Kotest` - Kotlin testing framework

**Detection patterns:**
```
# Test directories
src/test/         # Unit tests
src/androidTest/  # Instrumented tests

# Coverage configuration
build.gradle -> jacoco
jacocoTestReport task

# Test dependencies
testImplementation
androidTestImplementation
```

**Capture:**
- Test frameworks used
- JaCoCo coverage percentage
- Mock tools in use
- Instrumented test presence
- Espresso UI test presence
- Test organization pattern
- Approximate test counts by type

### Flutter Recommendation

Map to:
- `flutter_test` - Core testing
- `bloc_test` - BLoC testing
- `mocktail` / `mockito` - Mocking
- `golden_toolkit` - Screenshot testing
- `integration_test` - Integration testing

## Step 8: CI/CD Configuration

### iOS CI/CD Detection

**Fastlane:**
```
fastlane/
├── Fastfile          # Lane definitions
├── Appfile           # App identifiers
├── Matchfile         # Code signing config
└── Pluginfile        # Fastlane plugins
```

**Lanes to capture:**
- `test` - Test execution
- `beta` - TestFlight distribution
- `release` - App Store submission
- Custom lanes

**Code signing:**
- `match` - Fastlane Match (Git-based)
- `cert` / `sigh` - Manual provisioning
- Xcode automatic signing

**Other CI files:**
- `.xcode-version`
- `ci_scripts/` (Xcode Cloud)
- `.github/workflows/*.yml`
- `.bitrise.yml`
- `Jenkinsfile`

### Android CI/CD Detection

**Fastlane:**
```
fastlane/
├── Fastfile          # Lane definitions
└── Appfile           # Package name, JSON key
```

**Gradle configuration:**
```groovy
// Signing configs
signingConfigs {
    release {
        storeFile file(...)
        storePassword ...
    }
}

// Product flavors
productFlavors {
    dev { ... }
    prod { ... }
}
```

**Build automation:**
- `gradle-play-publisher` plugin
- GitHub Actions workflows
- Bitrise configuration

**Capture:**
- Build automation tool
- Available build lanes/tasks
- Signing configurations
- Product flavors/variants
- Deployment targets
- CI provider

### Secrets Management

Identify:
- Environment variables
- GitHub Secrets
- Fastlane Match
- HashiCorp Vault
- Manual key storage

## Step 9: Localization

### iOS Localization Detection

**File formats:**
- `.strings` - Legacy format
- `.xcstrings` - Modern format (Xcode 15+)
- `.stringsdict` - Pluralization

**Detection patterns:**
```
# Localization directories
*.lproj/
  Localizable.strings
  InfoPlist.strings

# String catalogs
Localizable.xcstrings

# SwiftGen configuration
swiftgen.yml -> strings
```

**Capture:**
- Localization file format
- Supported locales (list all `*.lproj` directories)
- Approximate string count
- SwiftGen usage for type-safety
- Pluralization support (`.stringsdict` presence)
- RTL language support (ar, he, fa locales)

### Android Localization Detection

**Resource structure:**
```
res/
├── values/           # Default (English)
│   └── strings.xml
├── values-es/        # Spanish
├── values-fr/        # French
└── values-ar/        # Arabic (RTL)
```

**Detection patterns:**
```groovy
// build.gradle - locale filtering
android {
    defaultConfig {
        resConfigs "en", "es", "fr"
    }
}

// AndroidManifest.xml
android:supportsRtl="true"
```

**Capture:**
- Supported locales (from `res/values-XX` directories)
- Approximate string count
- `resConfigs` (restricted locales)
- Pluralization (`plurals.xml` presence)
- RTL support (`supportsRtl` in manifest)

### Parity Analysis

Compare:
- Matching locales (supported on both)
- iOS-only locales
- Android-only locales

### Flutter Recommendation

- `flutter_localizations` - Official localization
- `intl` - ICU message format
- `easy_localization` - Alternative approach
- ARB file generation from native strings

## Step 10: Accessibility

### iOS Accessibility Detection

**Patterns to search:**
```swift
// Accessibility labels
.accessibilityLabel("...")
accessibilityLabel = "..."

// Accessibility traits
.accessibilityTraits(.button)
accessibilityTraits = .button

// Accessibility hints
.accessibilityHint("...")

// Dynamic Type
UIFontMetrics
.dynamicTypeSize
preferredFont(forTextStyle:)

// Reduce Motion
UIAccessibility.isReduceMotionEnabled
```

**Audit indicators:**
- Accessibility Audit results in Xcode
- `.accessibilityIdentifier` usage (for testing)

**Capture:**
- Consistent `accessibilityLabel` usage
- Proper `accessibilityTraits` setting
- VoiceOver support level (none/partial/full)
- Dynamic Type support
- Reduce Motion respect
- Accessibility audit issue count

### Android Accessibility Detection

**Patterns to search:**
```xml
<!-- Content descriptions -->
android:contentDescription="@string/..."
android:importantForAccessibility="yes"

<!-- Touch targets -->
android:minHeight="48dp"
android:minWidth="48dp"
```

```kotlin
// Programmatic
contentDescription = "..."
ViewCompat.setAccessibilityDelegate(...)
```

**Font scaling:**
- Use of `sp` units for text (good)
- Use of `dp` for text (bad - won't scale)

**Capture:**
- Consistent `contentDescription` usage
- TalkBack support level
- Font scaling support (sp units)
- Touch target size compliance (48dp minimum)
- Accessibility Scanner issue count

### Compliance Level

Estimate WCAG level:
- `none` - No accessibility implementation
- `wcag_a` - Basic accessibility
- `wcag_aa` - Standard compliance
- `wcag_aaa` - Enhanced compliance

## Step 11: Analytics & Tracking

### Provider Detection

**Firebase Analytics:**
```swift
// iOS
Analytics.logEvent("...", parameters: [...])
```
```kotlin
// Android
firebaseAnalytics.logEvent("...") { ... }
```

**Mixpanel:**
```swift
Mixpanel.mainInstance().track(event: "...")
```
```kotlin
mixpanel.track("...")
```

**Amplitude:**
```swift
Amplitude.instance().logEvent("...")
```
```kotlin
amplitude.track("...")
```

**Other providers:**
- Segment
- Adjust
- AppsFlyer
- Branch

### Event Pattern Analysis

**Capture:**
- Naming convention (snake_case, camelCase, etc.)
- Approximate event count
- User properties tracked
- Screen tracking implementation

### Privacy Compliance

**iOS:**
```swift
// App Tracking Transparency
ATTrackingManager.requestTrackingAuthorization
```

**GDPR:**
- Consent management SDK
- Data deletion endpoint
- Privacy policy link

**Capture:**
- GDPR consent implementation
- ATT prompt (iOS)
- Data deletion support

## Step 12: Error Handling

### Crash Reporting Detection

**Crashlytics:**
```swift
// iOS
Crashlytics.crashlytics().record(error:)
```
```kotlin
// Android
Firebase.crashlytics.recordException(e)
```

**Sentry:**
```swift
SentrySDK.capture(error:)
```
```kotlin
Sentry.captureException(e)
```

**Other providers:**
- Bugsnag
- Instabug
- AppCenter

### iOS Error Handling Patterns

**Detection:**
```swift
// Result type
func fetch() -> Result<Data, Error>

// Custom error types
enum NetworkError: Error { ... }

// Global handler
NSSetUncaughtExceptionHandler

// Combine error handling
.catch { error in ... }
```

**Capture:**
- Custom error types defined
- Result pattern usage
- Global error handler presence
- Retry patterns (exponential backoff, etc.)

### Android Error Handling Patterns

**Detection:**
```kotlin
// Coroutine exception handler
CoroutineExceptionHandler { _, exception -> ... }

// Custom exceptions
class NetworkException : Exception()

// Global handler
Thread.setDefaultUncaughtExceptionHandler

// Flow error handling
.catch { e -> ... }
```

**Capture:**
- Custom exception classes
- CoroutineExceptionHandler usage
- Global error handler presence
- Retry patterns

### Logging Detection

**iOS:**
- `OSLog` / `Logger` (Apple's unified logging)
- `CocoaLumberjack`
- `SwiftyBeaver`
- `XCGLogger`

**Android:**
- `Timber`
- `slf4j`
- `Log.*` (Android built-in)

**Capture:**
- Logging framework
- Log levels used

## Step 13: App Startup Sequence

### iOS Startup Detection

**Entry point identification:**
```swift
// Traditional
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate

// Modern (iOS 14+)
@main
struct MyApp: App
```

**Initialization sequence in AppDelegate:**
```swift
func application(_:didFinishLaunchingWithOptions:) -> Bool {
    // 1. Analytics setup
    FirebaseApp.configure()

    // 2. Crash reporting
    Crashlytics.crashlytics()

    // 3. Dependency injection
    Container.shared.setup()

    // 4. Remote config fetch
    RemoteConfig.remoteConfig().fetch()

    // 5. Authentication check
    AuthManager.shared.checkSession()

    return true
}
```

**SceneDelegate (iOS 13+):**
```swift
func scene(_:willConnectTo:options:)
```

**Detection patterns:**
- `AppDelegate.swift` or `@main` struct
- `SceneDelegate.swift` presence
- `LaunchScreen.storyboard` or `Launch.storyboard`
- Static initializers (`+load`, `+initialize`)

**Capture:**
- Entry point type
- Initialization steps (ordered)
- Scene delegate usage
- Splash screen type
- Pre-main operations

### Android Startup Detection

**Application class:**
```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialization here
    }
}
```

**ContentProvider initialization:**
```xml
<provider
    android:name="androidx.startup.InitializationProvider"
    android:authorities="${applicationId}.androidx-startup">
    <meta-data
        android:name="com.example.MyInitializer"
        android:value="androidx.startup" />
</provider>
```

**App Startup library:**
```kotlin
class MyInitializer : Initializer<MyDependency> {
    override fun create(context: Context): MyDependency
    override fun dependencies(): List<Class<Initializer<*>>>
}
```

**Splash screen:**
```xml
<!-- Legacy (theme-based) -->
<style name="SplashTheme">
    <item name="android:windowBackground">@drawable/splash</item>
</style>

<!-- Modern (SplashScreen API, Android 12+) -->
<style name="Theme.App.Starting" parent="Theme.SplashScreen">
    <item name="windowSplashScreenBackground">@color/...</item>
</style>
```

**Detection patterns:**
- Custom `Application` class in manifest
- ContentProvider declarations
- `androidx.startup` usage
- Splash screen theme configuration

**Capture:**
- Application class name
- Initialization steps (ordered)
- ContentProvider usage
- App Startup initializers
- Splash screen type

### Critical Path Analysis

Identify operations that block first frame:
- Database initialization
- Network calls (remote config, auth check)
- Heavy computations
- File I/O

### Flutter Recommendation

Map to:
- `flutter_native_splash` - Native splash screen
- `main()` async initialization pattern
- `FutureBuilder` / `StreamBuilder` for async init
- Deferred initialization for non-critical tasks

## Special Scenarios

### Mixed UI Frameworks

If app uses both UIKit and SwiftUI (or XML and Compose):
- Note which screens use which framework
- SwiftUI/Compose screens often have better 1:1 Flutter mappings
- UIKit/XML screens may need more structural changes

### Legacy Code

If Objective-C or Java code is present:
- Flag separately in manifest
- Often indicates older, more complex components
- May require additional analysis for hidden dependencies

### White-Label / Multi-Brand

If native apps support multiple brands:
- Document theming/configuration system
- Identify brand-specific vs shared features
- This affects Flutter package structure significantly

### Existing Flutter Code

If there's already Flutter code (add-to-app):
- Document existing Flutter modules
- Identify integration points
- Note platform channel contracts already in place
