import 'package:test/test.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

void main() {
  group('ModifierOption', () {
    test('can be instantiated', () {
      expect(
        const ModifierOption(
          id: 'opt-1',
          name: 'Oat Milk',
          priceDeltaCents: 75,
        ),
        isNotNull,
      );
    });

    test('priceDeltaCents defaults to 0', () {
      const option = ModifierOption(id: 'opt-1', name: 'Whole Milk');
      expect(option.priceDeltaCents, 0);
    });

    test('fromMap/toMap roundtrip', () {
      const option = ModifierOption(
        id: 'opt-1',
        name: 'Oat Milk',
        priceDeltaCents: 75,
      );
      final map = option.toMap();
      final restored = ModifierOptionMapper.fromMap(map);
      expect(restored, equals(option));
    });
  });

  group('SelectionMode', () {
    test('has single and multi values', () {
      expect(
        SelectionMode.values,
        containsAll([SelectionMode.single, SelectionMode.multi]),
      );
    });
  });

  group('ModifierGroup', () {
    const sizeGroup = ModifierGroup(
      id: 'mg-size',
      name: 'Size',
      appliesToGroupIds: ['2'],
      required: true,
      defaultOptionId: 'size-tall',
      options: [
        ModifierOption(id: 'size-short', name: 'Short'),
        ModifierOption(id: 'size-tall', name: 'Tall'),
        ModifierOption(id: 'size-grande', name: 'Grande', priceDeltaCents: 50),
      ],
    );

    test('can be instantiated', () {
      expect(sizeGroup, isNotNull);
    });

    test('defaults', () {
      const group = ModifierGroup(
        id: 'mg-1',
        name: 'Test',
        options: [],
      );
      expect(group.appliesToGroupIds, isEmpty);
      expect(group.selectionMode, SelectionMode.single);
      expect(group.required, isFalse);
      expect(group.defaultOptionId, isNull);
    });

    test('fromMap/toMap roundtrip', () {
      final map = sizeGroup.toMap();
      final restored = ModifierGroupMapper.fromMap(map);
      expect(restored, equals(sizeGroup));
    });

    test('fromMap/toMap roundtrip with multi-select and no default', () {
      const syrupGroup = ModifierGroup(
        id: 'mg-syrup',
        name: 'Syrup',
        appliesToGroupIds: ['2'],
        selectionMode: SelectionMode.multi,
        options: [
          ModifierOption(
            id: 'syrup-vanilla',
            name: 'Vanilla',
            priceDeltaCents: 50,
          ),
        ],
      );
      final map = syrupGroup.toMap();
      final restored = ModifierGroupMapper.fromMap(map);
      expect(restored, equals(syrupGroup));
    });
  });

  group('ModifierGroupFiltering', () {
    const allGroups = [
      ModifierGroup(
        id: 'mg-size',
        name: 'Size',
        appliesToGroupIds: ['2'],
        options: [],
      ),
      ModifierGroup(
        id: 'mg-milk',
        name: 'Milk',
        appliesToGroupIds: ['2'],
        options: [],
      ),
      ModifierGroup(
        id: 'mg-universal',
        name: 'Universal',
        options: [],
      ),
    ];

    test('returns groups applicable to drinks (group "2")', () {
      final result = allGroups.applicableTo('2');
      expect(result, hasLength(3));
      expect(
        result.map((g) => g.name),
        containsAll(['Size', 'Milk', 'Universal']),
      );
    });

    test('returns only universal groups for food (group "1")', () {
      final result = allGroups.applicableTo('1');
      expect(result, hasLength(1));
      expect(result.first.name, 'Universal');
    });

    test('returns only universal groups for desserts (group "3")', () {
      final result = allGroups.applicableTo('3');
      expect(result, hasLength(1));
      expect(result.first.name, 'Universal');
    });

    test('returns empty when no groups match', () {
      const drinksOnly = [
        ModifierGroup(
          id: 'mg-size',
          name: 'Size',
          appliesToGroupIds: ['2'],
          options: [],
        ),
      ];
      expect(drinksOnly.applicableTo('1'), isEmpty);
      expect(drinksOnly.applicableTo('3'), isEmpty);
    });

    test('empty appliesToGroupIds applies to all groups', () {
      const universalOnly = [
        ModifierGroup(id: 'mg-uni', name: 'Uni', options: []),
      ];
      expect(universalOnly.applicableTo('1'), hasLength(1));
      expect(universalOnly.applicableTo('2'), hasLength(1));
      expect(universalOnly.applicableTo('99'), hasLength(1));
    });
  });
}
