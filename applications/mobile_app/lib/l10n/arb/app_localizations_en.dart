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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
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

  @override
  String cartProceedToCheckout(String total) {
    return 'Proceed to Checkout — $total';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutFakePaymentLabel => 'Fake Payment';

  @override
  String get checkoutFakePaymentSubtitle => 'No real charge will be made';

  @override
  String checkoutPlaceOrder(String total) {
    return 'Place Order — $total';
  }

  @override
  String get checkoutErrorRetry => 'Something went wrong. Please try again.';

  @override
  String get orderCompleteTitle => 'Order Confirmed!';

  @override
  String orderCompleteOrderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String get orderCompleteStep1 => 'Placed';

  @override
  String get orderCompleteStep2 => 'In Progress';

  @override
  String get orderCompleteStep3 => 'Ready';

  @override
  String get orderCompleteStep4 => 'Picked Up';

  @override
  String get orderCompleteOrderDetailsLabel => 'Your Order';

  @override
  String get orderCompleteBackToMenu => 'Back to Menu';

  @override
  String get orderCompleteCancelledLabel => 'Order Cancelled';
}
