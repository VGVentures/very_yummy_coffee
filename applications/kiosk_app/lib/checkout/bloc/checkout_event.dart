part of 'checkout_bloc.dart';

@MappableClass()
sealed class CheckoutEvent with CheckoutEventMappable {
  const CheckoutEvent();
}

@MappableClass()
class CheckoutSubscriptionRequested extends CheckoutEvent
    with CheckoutSubscriptionRequestedMappable {
  const CheckoutSubscriptionRequested();
}

@MappableClass()
class CheckoutConfirmed extends CheckoutEvent with CheckoutConfirmedMappable {
  const CheckoutConfirmed({this.customerName = ''});

  final String customerName;
}
