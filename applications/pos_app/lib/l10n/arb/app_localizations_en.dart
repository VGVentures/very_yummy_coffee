// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Very Yummy Coffee — POS';

  @override
  String get connecting => 'Connecting…';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuCategoryAll => 'All';

  @override
  String get menuItemAdd => 'Add';

  @override
  String get menuItemUnavailable => 'Unavailable';

  @override
  String get menuEmpty => 'No items in this category';

  @override
  String get menuError => 'Unable to load menu';

  @override
  String get orderTicketCurrentOrder => 'Current Order';

  @override
  String get orderTicketTitle => 'Order';

  @override
  String get orderTicketEmpty => 'No items — tap menu to add';

  @override
  String get orderTicketNewOrder => 'New Order';

  @override
  String get orderTicketClear => 'Clear';

  @override
  String orderTicketCharge(String amount) {
    return 'Charge $amount';
  }

  @override
  String get orderTicketSubtotal => 'Subtotal';

  @override
  String get orderTicketTax => 'Tax';

  @override
  String get orderTicketTotal => 'Total';

  @override
  String get viewOrders => 'View Orders';

  @override
  String get back => 'Back';

  @override
  String get orderCompleteTitle => 'Order Charged!';

  @override
  String get orderCompleteDetails =>
      'The order has been placed and sent to the kitchen.';

  @override
  String get orderCompleteReceipt => 'Receipt';

  @override
  String get orderCompleteNewOrder => 'New Order';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersPendingTitle => 'Pending';

  @override
  String get ordersActiveTitle => 'In Progress';

  @override
  String get ordersHistoryTitle => 'Order History';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get ordersBack => 'Order';

  @override
  String get ordersColumnOrder => 'Order';

  @override
  String get ordersColumnItems => 'Items';

  @override
  String get ordersColumnCompleted => 'Completed';

  @override
  String get orderStatus => 'Status';

  @override
  String get orderStatusSubmitted => 'Submitted';

  @override
  String get orderStatusInProgress => 'In Progress';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get modifierSheetConfirm => 'Confirm';

  @override
  String get orderTicketCustomerNameHint => 'Customer name';

  @override
  String get ordersColumnCustomer => 'Customer';

  @override
  String get posStockManagement => 'Stock';

  @override
  String posStockItemCount(int available, int total) {
    return '$available/$total in stock';
  }

  @override
  String get cartItemUnavailable => 'Unavailable';

  @override
  String get cartRemoveUnavailableToCheckout =>
      'Remove unavailable items to proceed';

  @override
  String get actionStart => 'Start';

  @override
  String get actionMarkReady => 'Mark Ready';

  @override
  String get actionComplete => 'Complete';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get cancelOrderDialogTitle => 'Cancel Order?';

  @override
  String cancelOrderDialogMessage(String orderNumber) {
    return 'Are you sure you want to cancel order $orderNumber? This cannot be undone.';
  }

  @override
  String get cancelOrderDialogConfirm => 'Yes, Cancel';

  @override
  String get cancelOrderDialogDismiss => 'No';

  @override
  String get ordersPendingEditHint => 'Tap to edit';
}
