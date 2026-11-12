/// Formats [cents] as dollars, for example `$5.25`.
String formatCents(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
