import 'package:flutter/material.dart';

extension ColorAdjust on Color {
  Color a(double alpha) => withValues(alpha: alpha); // shorthand
}
