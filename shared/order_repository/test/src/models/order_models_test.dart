import 'package:order_repository/order_repository.dart';
import 'package:test/test.dart';

void main() {
  group('SelectedOption', () {
    test('can be instantiated', () {
      expect(
        const SelectedOption(
          id: 'opt-1',
          name: 'Oat Milk',
          priceDeltaCents: 75,
        ),
        isNotNull,
      );
    });

    test('priceDeltaCents defaults to 0', () {
      const option = SelectedOption(id: 'opt-1', name: 'Whole Milk');
      expect(option.priceDeltaCents, 0);
    });

    test('fromMap/toMap roundtrip', () {
      const option = SelectedOption(
        id: 'opt-1',
        name: 'Oat Milk',
        priceDeltaCents: 75,
      );
      final map = option.toMap();
      final restored = SelectedOptionMapper.fromMap(map);
      expect(restored, equals(option));
    });
  });

  group('SelectedModifier', () {
    test('can be instantiated', () {
      expect(
        const SelectedModifier(
          modifierGroupId: 'mg-milk',
          modifierGroupName: 'Milk',
        ),
        isNotNull,
      );
    });

    test('options defaults to empty list', () {
      const modifier = SelectedModifier(
        modifierGroupId: 'mg-milk',
        modifierGroupName: 'Milk',
      );
      expect(modifier.options, isEmpty);
    });

    test('fromMap/toMap roundtrip', () {
      const modifier = SelectedModifier(
        modifierGroupId: 'mg-milk',
        modifierGroupName: 'Milk',
        options: [
          SelectedOption(id: 'milk-oat', name: 'Oat Milk', priceDeltaCents: 75),
        ],
      );
      final map = modifier.toMap();
      final restored = SelectedModifierMapper.fromMap(map);
      expect(restored, equals(modifier));
    });
  });

  group('LineItem', () {
    test('modifierPriceDelta returns 0 with no modifiers', () {
      const item = LineItem(id: '1', name: 'Latte', price: 450);
      expect(item.modifierPriceDelta, 0);
    });

    test('modifierPriceDelta sums all option deltas', () {
      const item = LineItem(
        id: '1',
        name: 'Latte',
        price: 450,
        modifiers: [
          SelectedModifier(
            modifierGroupId: 'mg-milk',
            modifierGroupName: 'Milk',
            options: [
              SelectedOption(
                id: 'milk-oat',
                name: 'Oat Milk',
                priceDeltaCents: 75,
              ),
            ],
          ),
          SelectedModifier(
            modifierGroupId: 'mg-size',
            modifierGroupName: 'Size',
            options: [
              SelectedOption(
                id: 'size-grande',
                name: 'Grande',
                priceDeltaCents: 50,
              ),
            ],
          ),
        ],
      );
      expect(item.modifierPriceDelta, 125);
    });

    test('unitPriceWithModifiers equals price when no modifiers', () {
      const item = LineItem(id: '1', name: 'Croissant', price: 450);
      expect(item.unitPriceWithModifiers, 450);
    });

    test('unitPriceWithModifiers includes modifier deltas', () {
      const item = LineItem(
        id: '1',
        name: 'Latte',
        price: 450,
        modifiers: [
          SelectedModifier(
            modifierGroupId: 'mg-milk',
            modifierGroupName: 'Milk',
            options: [
              SelectedOption(
                id: 'milk-oat',
                name: 'Oat Milk',
                priceDeltaCents: 75,
              ),
            ],
          ),
        ],
      );
      expect(item.unitPriceWithModifiers, 525);
    });
  });

  group('Order', () {
    test('total uses unitPriceWithModifiers', () {
      const order = Order(
        id: 'order-1',
        status: OrderStatus.pending,
        items: [
          LineItem(
            id: '1',
            name: 'Latte',
            price: 450,
            quantity: 2,
            modifiers: [
              SelectedModifier(
                modifierGroupId: 'mg-milk',
                modifierGroupName: 'Milk',
                options: [
                  SelectedOption(
                    id: 'milk-oat',
                    name: 'Oat Milk',
                    priceDeltaCents: 75,
                  ),
                ],
              ),
            ],
          ),
          LineItem(id: '2', name: 'Croissant', price: 450),
        ],
      );
      // Latte: (450 + 75) * 2 = 1050, Croissant: 450 * 1 = 450
      expect(order.total, 1500);
    });

    test('total works with no modifiers', () {
      const order = Order(
        id: 'order-1',
        status: OrderStatus.pending,
        items: [
          LineItem(id: '1', name: 'Croissant', price: 450),
          LineItem(id: '2', name: 'Sandwich', price: 1200),
        ],
      );
      expect(order.total, 1650);
    });
  });
}
