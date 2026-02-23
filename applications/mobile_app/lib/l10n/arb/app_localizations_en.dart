// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Very Yummy Coffee';

  @override
  String get errorSomethingWentWrong => 'Something went wrong';

  @override
  String get itemDetailSizeLabel => 'Size';

  @override
  String get itemDetailMilkLabel => 'Milk';

  @override
  String get itemDetailExtrasLabel => 'Extras';

  @override
  String get itemDetailAddToCart => 'Add to Cart';

  @override
  String get cartTitle => 'My Cart';

  @override
  String cartItemCount(int count) {
    return intl.Intl.plural(
      count,
      locale: localeName,
      one: '1 item',
      other: '$count items',
    );
  }

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptySubtitle =>
      'Add some items from the menu to get started.';

  @override
  String get cartBrowseMenu => 'Browse Menu';

  @override
  String get cartOrderSummaryLabel => 'Order Summary';

  @override
  String get cartSubtotalLabel => 'Subtotal';

  @override
  String get cartTaxLabel => 'Tax (8%)';

  @override
  String get cartTotalLabel => 'Total';
}
