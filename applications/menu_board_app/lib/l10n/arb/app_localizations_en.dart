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
  String get connecting => 'Connecting...';

  @override
  String get notAvailable => 'Not available';

  @override
  String get failedToLoadMenu => 'Failed to load menu.';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusReady => 'Ready for Pickup';

  @override
  String orderStatusMoreCount(int count) {
    return '+$count more';
  }
}
