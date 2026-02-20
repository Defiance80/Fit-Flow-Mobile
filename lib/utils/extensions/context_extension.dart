import 'package:flutter/material.dart';

extension CustomContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  ColorScheme get color => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
