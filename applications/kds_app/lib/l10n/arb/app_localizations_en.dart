// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Very Yummy Coffee — Kitchen Display';

  @override
  String get connecting => 'Connecting to kitchen…';

  @override
  String get columnPending => 'PENDING';

  @override
  String get columnNew => 'NEW';

  @override
  String get columnInProgress => 'IN PROGRESS';

  @override
  String get columnReady => 'READY';

  @override
  String get actionStart => 'Start →';

  @override
  String get actionMarkReady => 'Mark Ready →';

  @override
  String get actionComplete => 'Complete ✓';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get ageJustNow => 'just now';

  @override
  String ageMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String ageHoursMinutesAgo(int hours, int minutes) {
    return '${hours}h ${minutes}m ago';
  }

  @override
  String orderQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in queue',
      one: '1 in queue',
    );
    return '$_temp0';
  }
}
