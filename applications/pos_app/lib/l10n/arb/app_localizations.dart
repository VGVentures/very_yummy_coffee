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

  /// The title of the POS application
  ///
  /// In en, this message translates to:
  /// **'Very Yummy Coffee — POS'**
  String get appTitle;

  /// Message shown on the connecting screen
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// Title for the menu panel
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// Label for the 'All' category tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get menuCategoryAll;

  /// Add button label on menu item cards
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get menuItemAdd;

  /// Label shown on unavailable menu items
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get menuItemUnavailable;

  /// Empty state for menu item grid
  ///
  /// In en, this message translates to:
  /// **'No items in this category'**
  String get menuEmpty;

  /// Error state for menu item grid
  ///
  /// In en, this message translates to:
  /// **'Unable to load menu'**
  String get menuError;

  /// Title for the current order panel
  ///
  /// In en, this message translates to:
  /// **'Current Order'**
  String get orderTicketCurrentOrder;

  /// Title for the order ticket panel
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderTicketTitle;

  /// Empty state for order ticket
  ///
  /// In en, this message translates to:
  /// **'No items — tap menu to add'**
  String get orderTicketEmpty;

  /// Button to start a new order
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get orderTicketNewOrder;

  /// Button to clear/cancel the current order
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get orderTicketClear;

  /// Button to charge and submit the order
  ///
  /// In en, this message translates to:
  /// **'Charge {amount}'**
  String orderTicketCharge(String amount);

  /// Subtotal label in order ticket footer
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get orderTicketSubtotal;

  /// Tax label in order ticket footer
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get orderTicketTax;

  /// Label for total price in order ticket
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderTicketTotal;

  /// Button to navigate to the orders list screen
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get viewOrders;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Success heading on the order complete screen
  ///
  /// In en, this message translates to:
  /// **'Order Charged!'**
  String get orderCompleteTitle;

  /// Success body text on the order complete screen
  ///
  /// In en, this message translates to:
  /// **'The order has been placed and sent to the kitchen.'**
  String get orderCompleteDetails;

  /// Receipt panel title on the order complete screen
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get orderCompleteReceipt;

  /// Button to start a new order from the receipt screen
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get orderCompleteNewOrder;

  /// Title for the orders list screen
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// Section title for pending orders still being built by customers
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersPendingTitle;

  /// Section title for active/in-flight orders
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get ordersActiveTitle;

  /// Section title for order history
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get ordersHistoryTitle;

  /// Empty state for orders list
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// Back button label on the orders page (breadcrumb to the ordering screen)
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get ordersBack;

  /// Column header for order number in the history table
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get ordersColumnOrder;

  /// Column header for items in the history table
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get ordersColumnItems;

  /// Column header for completion time in the history table
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersColumnCompleted;

  /// Column header for order status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderStatus;

  /// Order status: submitted
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get orderStatusSubmitted;

  /// Order status: in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get orderStatusInProgress;

  /// Order status: ready
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orderStatusReady;

  /// Order status: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// Order status: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// Order status: pending (not yet submitted)
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// Confirm button on the modifier selection bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get modifierSheetConfirm;

  /// Placeholder hint for the customer name text field on the order ticket
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get orderTicketCustomerNameHint;

  /// Column header for customer name in the history table
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ordersColumnCustomer;
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
