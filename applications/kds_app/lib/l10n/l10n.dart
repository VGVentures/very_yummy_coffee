import 'package:flutter/widgets.dart';
import 'package:very_yummy_coffee_kds_app/l10n/arb/app_localizations.dart';

export 'package:very_yummy_coffee_kds_app/l10n/arb/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
