part of 'checkout_bloc.dart';

@MappableEnum()
enum CheckoutStatus { loading, idle, submitting, success, failure }

@MappableClass()
class CheckoutState with CheckoutStateMappable {
  const CheckoutState({
    this.status = CheckoutStatus.loading,
    this.order,
  });

  final CheckoutStatus status;
  final Order? order;
}
