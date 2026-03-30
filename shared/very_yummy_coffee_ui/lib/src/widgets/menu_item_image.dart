import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// Layout variant for [MenuItemImage].
enum MenuItemImageLayout {
  /// Fills the parent; use inside a bounded tight parent (e.g. [SizedBox],
  /// [Expanded], or [Positioned.fill]).
  hero,

  /// Fixed square extent for optional list/grid thumbnails.
  thumbnail,
}

/// {@template menu_item_image}
/// Product photo from a URL with loading and error handling.
///
/// [imageUrl] may be null, empty, or whitespace-only — those cases show the
/// same placeholder as a failed network load. Does not import domain types.
/// {@endtemplate}
class MenuItemImage extends StatelessWidget {
  /// {@macro menu_item_image}
  const MenuItemImage({
    super.key,
    this.imageUrl,
    this.layout = MenuItemImageLayout.hero,
    this.fit,
    this.borderRadius,
  });

  /// Square edge length for [MenuItemImageLayout.thumbnail].
  static const double thumbnailExtent = 72;

  /// Optional HTTPS (or local test) image URL; null or blank uses placeholder.
  final String? imageUrl;

  /// [MenuItemImageLayout.hero] fills the parent; thumbnail uses a fixed
  /// square extent.
  final MenuItemImageLayout layout;

  /// How the decoded image is inscribed; defaults to cover fit.
  final BoxFit? fit;

  /// Outer clip; defaults to theme radius tokens for each layout mode.
  final BorderRadius? borderRadius;

  String? get _resolvedUrl {
    final trimmed = imageUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final radius =
        borderRadius ??
        BorderRadius.circular(
          layout == MenuItemImageLayout.hero
              ? context.radius.large
              : context.radius.small,
        );
    final effectiveFit = fit ?? BoxFit.cover;

    final inner = url == null
        ? _MenuItemImagePlaceholder(layout: layout)
        : Image.network(
            url,
            fit: effectiveFit,
            width: layout == MenuItemImageLayout.thumbnail
                ? thumbnailExtent
                : null,
            height: layout == MenuItemImageLayout.thumbnail
                ? thumbnailExtent
                : null,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _MenuItemImagePlaceholder(layout: layout);
            },
            errorBuilder: (context, error, stackTrace) =>
                _MenuItemImagePlaceholder(layout: layout),
          );

    return ClipRRect(
      borderRadius: radius,
      child: layout == MenuItemImageLayout.thumbnail
          ? SizedBox(
              width: thumbnailExtent,
              height: thumbnailExtent,
              child: inner,
            )
          : SizedBox.expand(child: inner),
    );
  }
}

class _MenuItemImagePlaceholder extends StatelessWidget {
  const _MenuItemImagePlaceholder({required this.layout});

  final MenuItemImageLayout layout;

  @override
  Widget build(BuildContext context) {
    final iconSize = switch (layout) {
      MenuItemImageLayout.hero => 64.0,
      MenuItemImageLayout.thumbnail => 32.0,
    };
    return ColoredBox(
      color: context.colors.imagePlaceholder,
      child: Center(
        child: Icon(
          Icons.local_cafe_outlined,
          size: iconSize,
          color: context.colors.mutedForeground,
        ),
      ),
    );
  }
}
