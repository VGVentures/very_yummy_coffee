import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/widgets/drink_option_row.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/widgets/highlight_on_change.dart';

/// A drink in the order: its photo, name, price and options.
class DrinkCard extends StatelessWidget {
  const DrinkCard({required this.order, super.key});

  final DrinkOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _DrinkPhoto(
                key: ValueKey(order.imageUrl),
                imageUrl: order.imageUrl,
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          HighlightOnChange(
            value: order.displayName,
            builder: (context, strength) => Text(
              order.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: typography.subtitle.copyWith(
                color: Color.lerp(colors.foreground, colors.primary, strength),
              ),
            ),
          ),
          Text(formatCents(order.priceCents), style: typography.caption),
          SizedBox(height: spacing.md),
          DrinkOptionRow(
            label: order.size.label,
            icons: [
              for (final size in DrinkSize.values)
                DrinkOptionIcon(
                  Icons.coffee,
                  active: size == order.size,
                  size: 11.0 + size.index * 3,
                ),
            ],
          ),
          SizedBox(height: spacing.sm),
          DrinkOptionRow(
            label: switch (order.shots) {
              0 => 'No espresso',
              1 => '1 shot',
              final shots => '$shots shots',
            },
            muted: order.shots == 0,
            icons: [
              for (var shot = 1; shot <= VoiceMenu.maxShots; shot++)
                DrinkOptionIcon(Icons.water_drop, active: shot <= order.shots),
            ],
          ),
          SizedBox(height: spacing.sm),
          DrinkOptionRow(
            label: order.milk.label,
            muted: order.milk == Milk.none,
            icons: [
              DrinkOptionIcon(
                Icons.opacity,
                active: order.milk == Milk.whole,
              ),
              DrinkOptionIcon(
                Icons.invert_colors,
                active: order.milk == Milk.twoPercent,
              ),
              DrinkOptionIcon(Icons.grass, active: order.milk == Milk.oat),
              DrinkOptionIcon(
                Icons.spa,
                active: order.milk == Milk.almond || order.milk == Milk.soy,
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          DrinkOptionRow(
            label: order.temperature.label,
            icons: [
              DrinkOptionIcon(
                Icons.local_fire_department,
                active: order.temperature == Temperature.hot,
              ),
              DrinkOptionIcon(
                Icons.ac_unit,
                active: order.temperature == Temperature.iced,
              ),
              // Keeps the two icons at the left of the strip.
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrinkPhoto extends StatelessWidget {
  const _DrinkPhoto({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = Center(
      child: Icon(
        Icons.local_cafe_outlined,
        size: 48,
        color: colors.mutedForeground,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radius.small),
      child: ColoredBox(
        color: colors.imagePlaceholder,
        child: SizedBox.expand(
          // The shared MenuItemImage cannot be used here: on the web it
          // needs the photo host to send CORS headers. Falling back to an
          // <img> element shows the photo either way.
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : placeholder,
            errorBuilder: (context, error, stackTrace) => placeholder,
          ),
        ),
      ),
    );
  }
}
