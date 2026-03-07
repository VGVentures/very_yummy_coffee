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

  /// Brand name displayed on the kiosk home screen
  ///
  /// In en, this message translates to:
  /// **'Very Yummy Coffee'**
  String get kioskBrandName;

  /// Tagline displayed below the brand name on the kiosk home screen
  ///
  /// In en, this message translates to:
  /// **'Freshly brewed, just for you.'**
  String get kioskTagline;

  /// Label for the start order button on the kiosk home screen
  ///
  /// In en, this message translates to:
  /// **'Start Order'**
  String get kioskStartOrder;

  /// Cart badge label showing item count in the kiosk header
  ///
  /// In en, this message translates to:
  /// **'Cart ({count})'**
  String kioskCartBadge(int count);

  /// Label for the done button on the order complete screen
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get kioskDone;

  /// Subtitle on the menu groups screen
  ///
  /// In en, this message translates to:
  /// **'What would you like?'**
  String get kioskWhatWouldYouLike;

  /// Title on the order complete success hero panel
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get kioskOrderPlacedTitle;

  /// Subtitle on the order complete success hero panel
  ///
  /// In en, this message translates to:
  /// **'We\'re brewing your order now.\nSee you in a few minutes!'**
  String get kioskOrderPlacedSubtitle;

  /// Label for the checkout button on the cart screen
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get kioskProceedToCheckout;

  /// Generic error message shown when an unexpected failure occurs
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorSomethingWentWrong;

  /// Label for the add-to-cart button on the item detail page
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get itemDetailAddToCart;

  /// Message shown when an item becomes unavailable on the item detail page
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available'**
  String get itemDetailUnavailable;

  /// Title of the cart page
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get cartTitle;

  /// Number of items shown in the cart header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String cartItemCount(int count);

  /// Heading shown when the cart has no items
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// Subtitle shown when the cart has no items
  ///
  /// In en, this message translates to:
  /// **'Add some items from the menu to get started.'**
  String get cartEmptySubtitle;

  /// Button label that navigates to the menu from an empty cart
  ///
  /// In en, this message translates to:
  /// **'Browse Menu'**
  String get cartBrowseMenu;

  /// Heading for the order summary section
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get cartOrderSummaryLabel;

  /// Label for the subtotal row in the order summary
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotalLabel;

  /// Label for the tax row in the order summary
  ///
  /// In en, this message translates to:
  /// **'Tax (8%)'**
  String get cartTaxLabel;

  /// Label for the total row in the order summary
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotalLabel;

  /// Title of the checkout screen
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// Label on the cosmetic payment card in the checkout screen
  ///
  /// In en, this message translates to:
  /// **'Fake Payment'**
  String get checkoutFakePaymentLabel;

  /// Subtitle on the cosmetic payment card in the checkout screen
  ///
  /// In en, this message translates to:
  /// **'No real charge will be made'**
  String get checkoutFakePaymentSubtitle;

  /// Label for the place-order button on the checkout screen
  ///
  /// In en, this message translates to:
  /// **'Place Order — {total}'**
  String checkoutPlaceOrder(String total);

  /// Inline error shown below the place-order button on failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get checkoutErrorRetry;

  /// Order number display on the order complete screen
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderCompleteOrderNumber(String number);

  /// Step 1 label on the order status tracker
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get orderCompleteStep1;

  /// Step 2 label on the order status tracker
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get orderCompleteStep2;

  /// Step 3 label on the order status tracker
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orderCompleteStep3;

  /// Step 4 label on the order status tracker
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get orderCompleteStep4;

  /// Section heading for the order details on the order complete screen
  ///
  /// In en, this message translates to:
  /// **'Your Order'**
  String get orderCompleteOrderDetailsLabel;

  /// Label shown when the order has been cancelled
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCompleteCancelledLabel;
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
