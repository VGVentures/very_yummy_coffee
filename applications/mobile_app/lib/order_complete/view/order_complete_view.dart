import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_mobile_app/order_complete/order_complete.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class OrderCompleteView extends StatelessWidget {
  const OrderCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocBuilder<OrderCompleteBloc, OrderCompleteState>(
        builder: (context, state) {
          if (state.status == OrderCompleteStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == OrderCompleteStatus.failure) {
            return Scaffold(
              backgroundColor: context.colors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.errorSomethingWentWrong,
                      style: context.typography.body.copyWith(
                        color: context.colors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: context.spacing.xl),
                    BaseButton(
                      label: context.l10n.orderCompleteBackToMenu,
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = state.order;
          if (order == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final orderNumber = order.id
              .substring(order.id.length - 4)
              .toUpperCase();
          final isCancelled = order.status == OrderStatus.cancelled;

          return Scaffold(
            backgroundColor: context.colors.background,
            body: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: context.spacing.xxl),
                    _CelebratoryHero(orderNumber: orderNumber),
                    SizedBox(height: context.spacing.xxl),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.xl,
                      ),
                      child: OrderStepTracker(
                        activeStep: switch (order.status) {
                          OrderStatus.pending => 0,
                          OrderStatus.submitted => 1,
                          OrderStatus.ready => 2,
                          OrderStatus.completed => 3,
                          OrderStatus.cancelled => -1,
                        },
                        labels: [
                          context.l10n.orderCompleteStep1,
                          context.l10n.orderCompleteStep2,
                          context.l10n.orderCompleteStep3,
                          context.l10n.orderCompleteStep4,
                        ],
                      ),
                    ),
                    if (isCancelled) ...[
                      SizedBox(height: context.spacing.md),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.xl,
                        ),
                        child: Text(
                          context.l10n.orderCompleteCancelledLabel,
                          textAlign: TextAlign.center,
                          style: context.typography.body.copyWith(
                            color: context.colors.destructive,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: context.spacing.xxl),
                    _OrderDetails(order: order),
                    SizedBox(height: context.spacing.xl),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.xl,
                      ),
                      child: BaseButton(
                        label: context.l10n.orderCompleteBackToMenu,
                        onPressed: () => context.go('/home'),
                      ),
                    ),
                    SizedBox(height: context.spacing.xxl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CelebratoryHero extends StatelessWidget {
  const _CelebratoryHero({required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 72,
            color: context.colors.success,
          ),
          SizedBox(height: context.spacing.lg),
          Text(
            context.l10n.orderCompleteTitle,
            style: context.typography.headline.copyWith(
              color: context.colors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            context.l10n.orderCompleteOrderNumber(orderNumber),
            style: context.typography.subtitle.copyWith(
              color: context.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  const _OrderDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(context.radius.large),
          border: Border.all(color: context.colors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.orderCompleteOrderDetailsLabel,
                style: context.typography.subtitle.copyWith(
                  color: context.colors.foreground,
                ),
              ),
              SizedBox(height: context.spacing.md),
              ...order.items.map((item) {
                final lineTotal = (item.price * item.quantity / 100)
                    .toStringAsFixed(2);
                return Padding(
                  padding: EdgeInsets.only(bottom: context.spacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}× ${item.name}',
                          style: context.typography.body.copyWith(
                            color: context.colors.foreground,
                          ),
                        ),
                      ),
                      Text(
                        '\$$lineTotal',
                        style: context.typography.body.copyWith(
                          color: context.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Divider(color: context.colors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cartTotalLabel,
                    style: context.typography.subtitle.copyWith(
                      color: context.colors.foreground,
                    ),
                  ),
                  Text(
                    '\$${(order.grandTotal / 100).toStringAsFixed(2)}',
                    style: context.typography.subtitle.copyWith(
                      color: context.colors.foreground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
