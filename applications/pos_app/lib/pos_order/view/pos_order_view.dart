import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_pos_app/menu/menu.dart';
import 'package:very_yummy_coffee_pos_app/order_ticket/order_ticket.dart';
import 'package:very_yummy_coffee_pos_app/pos_order/view/widgets/pos_top_bar.dart';

class PosOrderView extends StatelessWidget {
  const PosOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PosTopBar(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    MenuCategoryTabs(),
                    Expanded(child: MenuItemGrid()),
                  ],
                ),
              ),
              VerticalDivider(width: 1),
              SizedBox(width: 320, child: OrderTicket()),
            ],
          ),
        ),
      ],
    );
  }
}
