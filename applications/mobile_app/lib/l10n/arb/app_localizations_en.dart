// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Very Yummy Coffee';

  @override
  String get errorSomethingWentWrong => 'Something went wrong';

  @override
  String get itemDetailSizeLabel => 'Size';

  @override
  String get itemDetailMilkLabel => 'Milk';

  @override
  String get itemDetailExtrasLabel => 'Extras';

  @override
  String get itemDetailAddToCart => 'Add to Cart';
}
