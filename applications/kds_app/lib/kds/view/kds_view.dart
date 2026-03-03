import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_kds_app/kds/bloc/kds_bloc.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/kds_colors.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_column.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/widgets/kds_top_bar.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// The main KDS display: three columns (NEW, IN PROGRESS, READY) in a
/// full-screen landscape layout.
class KdsView extends StatelessWidget {
  const KdsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return BlocBuilder<KdsBloc, KdsState>(
      builder: (context, state) {
        final bloc = context.read<KdsBloc>();

        return Scaffold(
          body: Column(
            children: [
              const KdsTopBar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: KdsColumn(
                        orders: state.newOrders,
                        accentColor: colors.accentGold,
                        label: l10n.columnNew,
                        actionLabel: l10n.actionStart,
                        onAction: (id) => bloc.add(KdsOrderStarted(id)),
                        onCancel: (id) => bloc.add(KdsOrderCancelled(id)),
                      ),
                    ),
                    Expanded(
                      child: KdsColumn(
                        orders: state.inProgressOrders,
                        accentColor: colors.primary,
                        label: l10n.columnInProgress,
                        actionLabel: l10n.actionMarkReady,
                        onAction: (id) => bloc.add(KdsOrderMarkedReady(id)),
                        onCancel: (id) => bloc.add(KdsOrderCancelled(id)),
                      ),
                    ),
                    Expanded(
                      child: KdsColumn(
                        orders: state.readyOrders,
                        accentColor: kdsReadyGreen,
                        label: l10n.columnReady,
                        actionLabel: l10n.actionComplete,
                        onAction: (id) => bloc.add(KdsOrderCompleted(id)),
                        onCancel: (id) => bloc.add(KdsOrderCancelled(id)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
