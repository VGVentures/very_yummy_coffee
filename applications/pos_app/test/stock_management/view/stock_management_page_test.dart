import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/stock_management.dart';

import '../../helpers/pump_app.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('StockManagementPage', () {
    late MenuRepository menuRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('renders StockManagementView', (tester) async {
      await tester.pumpApp(
        const StockManagementPage(),
        menuRepository: menuRepository,
      );

      expect(find.byType(StockManagementView), findsOneWidget);
    });

    testWidgets('provides StockManagementBloc', (tester) async {
      await tester.pumpApp(
        const StockManagementPage(),
        menuRepository: menuRepository,
      );

      expect(
        () => tester
            .element(find.byType(StockManagementView))
            .read<StockManagementBloc>(),
        returnsNormally,
      );
    });
  });
}
