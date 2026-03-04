import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/pos_order_complete/bloc/pos_order_complete_bloc.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class PosOrderCompleteView extends StatelessWidget {
  const PosOrderCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PosOrderCompleteBloc, PosOrderCompleteState>(
      builder: (context, state) {
        if (state.status == PosOrderCompleteStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == PosOrderCompleteStatus.failure) {
          return Center(child: Text(l10n.menuError));
        }
        final order = state.order;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.orderCompleteTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                order.orderNumber,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.name}'),
                      Text(
                        (item.price * item.quantity).asDollarString,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.orderTicketTotal,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${(order.total / 100).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: BaseButton(
                  label: l10n.orderCompleteNewOrder,
                  onPressed: () => context.read<PosOrderCompleteBloc>().add(
                    const PosOrderCompleteNewOrderRequested(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on int {
  String get asDollarString => '\$${(this / 100).toStringAsFixed(2)}';
}
