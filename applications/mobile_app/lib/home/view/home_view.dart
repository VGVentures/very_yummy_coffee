import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/home/home.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_mobile_app/menu_groups/menu_groups.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HomeHeader(greeting: _greeting(context.l10n)),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state.status == HomeStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == HomeStatus.failure) {
                  return const _ErrorState();
                }
                if (state.orders.isEmpty) {
                  return const _EmptyState();
                }
                return _OrderList(orders: state.orders);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocSelector<HomeBloc, HomeState, bool>(
        selector: (state) => state.orders.isNotEmpty,
        builder: (context, hasOrders) => _StartNewOrderBar(hasOrders: hasOrders),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.xl,
            vertical: context.spacing.lg,
          ),
          child: Row(
            children: [
              Icon(
                Icons.coffee,
                color: context.colors.primaryForeground,
                size: context.iconSize.large,
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                greeting,
                style: context.typography.subtitle.copyWith(
                  color: context.colors.primaryForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(context.spacing.xl),
      itemCount: orders.length,
      separatorBuilder: (_, _) => SizedBox(height: context.spacing.lg),
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final orderNumber = order.id.substring(order.id.length - 4).toUpperCase();
    final itemCount = order.items.fold(0, (sum, item) => sum + item.quantity);
    final total = '\$${(order.grandTotal / 100).toStringAsFixed(2)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.card),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.homeOrderNumber(orderNumber),
                  style: context.typography.subtitle.copyWith(
                    color: context.colors.foreground,
                  ),
                ),
                _StatusPill(status: order.status),
              ],
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              '${context.l10n.homeOrderItemCount(itemCount)} · $total',
              style: context.typography.body.copyWith(
                color: context.colors.mutedForeground,
              ),
            ),
            SizedBox(height: context.spacing.lg),
            OrderStepTracker(
              status: order.status,
              labels: [
                context.l10n.orderCompleteStep1,
                context.l10n.orderCompleteStep2,
                context.l10n.orderCompleteStep3,
                context.l10n.orderCompleteStep4,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.pending => (
        context.l10n.orderCompleteStep1,
        context.colors.warning,
      ),
      OrderStatus.submitted => (
        context.l10n.orderCompleteStep2,
        context.colors.primary,
      ),
      OrderStatus.ready => (
        context.l10n.orderCompleteStep3,
        context.colors.success,
      ),
      OrderStatus.completed || OrderStatus.cancelled => (
        context.l10n.orderCompleteStep4,
        context.colors.border,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(context.radius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.sm,
          vertical: context.spacing.xxs,
        ),
        child: Text(
          label,
          style: context.typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 64,
              color: context.colors.mutedForeground,
            ),
            SizedBox(height: context.spacing.lg),
            Text(
              context.l10n.homeEmptyStateTitle,
              style: context.typography.subtitle.copyWith(
                color: context.colors.foreground,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              context.l10n.homeEmptyStateBody,
              style: context.typography.body.copyWith(
                color: context.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.errorSomethingWentWrong,
        style: context.typography.body.copyWith(
          color: context.colors.mutedForeground,
        ),
      ),
    );
  }
}

class _StartNewOrderBar extends StatelessWidget {
  const _StartNewOrderBar({required this.hasOrders});

  final bool hasOrders;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.xl,
          vertical: context.spacing.lg,
        ),
        child: BaseButton(
          label: hasOrders
              ? context.l10n.homeContinueOrderButton
              : context.l10n.homeStartNewOrderButton,
          onPressed: () => context.go(MenuGroupsPage.routeName),
        ),
      ),
    );
  }
}
