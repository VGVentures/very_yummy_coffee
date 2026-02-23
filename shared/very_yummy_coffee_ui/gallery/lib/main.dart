import 'package:flutter/material.dart';
import 'package:gallery/addons/addons.dart';
import 'package:gallery/directories/directories.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const _Gallery());

class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(addons: addons, directories: directories);
  }
}
