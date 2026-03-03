import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_kds_app/l10n/arb/app_localizations.dart';

extension TesterL10n on WidgetTester {
  AppLocalizations get l10n {
    final app = widget<MaterialApp>(find.byType(MaterialApp).first);
    final locale = app.locale ?? app.supportedLocales.first;
    return lookupAppLocalizations(locale);
  }
}
