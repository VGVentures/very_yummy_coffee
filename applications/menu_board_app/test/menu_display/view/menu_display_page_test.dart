import 'package:flutter_test/flutter_test.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/menu_display_page.dart';

import '../../helpers/helpers.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('MenuDisplayPage', () {
    late MenuRepository menuRepository;

    setUp(() {
      menuRepository = _MockMenuRepository();
      when(
        () => menuRepository.getMenuGroupsAndItems(),
      ).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('provides MenuDisplayBloc and dispatches subscription event', (
      tester,
    ) async {
      await tester.pumpApp(
        const MenuDisplayPage(),
        menuRepository: menuRepository,
      );

      verify(() => menuRepository.getMenuGroupsAndItems()).called(1);
    });
  });
}
