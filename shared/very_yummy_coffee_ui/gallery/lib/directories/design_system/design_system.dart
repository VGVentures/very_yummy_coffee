import 'package:gallery/directories/design_system/components/components.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook folder for design system tokens (colors, spacing, typography).
final designSystemFolder = WidgetbookFolder(
  name: 'Design System',
  children: [colorsComponent, spacingComponent, typographyComponent],
);
