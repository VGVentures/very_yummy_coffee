import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The title of the KDS application
  ///
  /// In en, this message translates to:
  /// **'Very Yummy Coffee — Kitchen Display'**
  String get appTitle;

  /// Message shown on the connecting screen
  ///
  /// In en, this message translates to:
  /// **'Connecting to kitchen…'**
  String get connecting;

  /// Header label for the PENDING orders column
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get columnPending;

  /// Header label for the NEW orders column
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get columnNew;

  /// Header label for the IN PROGRESS orders column
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get columnInProgress;

  /// Header label for the READY orders column
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get columnReady;

  /// Action button label to start an order
  ///
  /// In en, this message translates to:
  /// **'Start →'**
  String get actionStart;

  /// Action button label to mark an order ready
  ///
  /// In en, this message translates to:
  /// **'Mark Ready →'**
  String get actionMarkReady;

  /// Action button label to complete an order
  ///
  /// In en, this message translates to:
  /// **'Complete ✓'**
  String get actionComplete;

  /// Cancel button label on an order card
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Age display for orders submitted less than 60 seconds ago
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get ageJustNow;

  /// Age display for orders submitted 1-59 minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String ageMinutesAgo(int minutes);

  /// Age display for orders submitted 60+ minutes ago
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m ago'**
  String ageHoursMinutesAgo(int hours, int minutes);

  /// Total active order count shown in the top bar
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 in queue} other{{count} in queue}}'**
  String orderQueue(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
