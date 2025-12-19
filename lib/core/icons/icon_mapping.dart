import 'package:flutter/material.dart';

/// Maps a legacy Material icon codePoint to a const Icons.* value.
/// This avoids constructing IconData dynamically (which breaks icon
/// tree-shaking in release builds) while preserving reasonable fallbacks.
IconData materialIconFromCodePoint(int codePoint) {
  if (codePoint == Icons.water_drop.codePoint) return Icons.water_drop;
  if (codePoint == Icons.fitness_center.codePoint) return Icons.fitness_center;
  if (codePoint == Icons.restaurant.codePoint) return Icons.restaurant;
  if (codePoint == Icons.school.codePoint) return Icons.school;
  if (codePoint == Icons.groups.codePoint) return Icons.groups;
  if (codePoint == Icons.account_balance_wallet.codePoint) {
    return Icons.account_balance_wallet;
  }
  if (codePoint == Icons.receipt_long.codePoint) return Icons.receipt_long;
  if (codePoint == Icons.smoke_free.codePoint) return Icons.smoke_free;
  if (codePoint == Icons.phonelink_off.codePoint) return Icons.phonelink_off;
  if (codePoint == Icons.notifications_off.codePoint) {
    return Icons.notifications_off;
  }
  if (codePoint == Icons.book.codePoint) return Icons.book;
  if (codePoint == Icons.free_breakfast.codePoint) return Icons.free_breakfast;
  if (codePoint == Icons.bedtime.codePoint) return Icons.bedtime;
  if (codePoint == Icons.dark_mode.codePoint) return Icons.dark_mode;
  if (codePoint == Icons.no_drinks.codePoint) return Icons.no_drinks;
  if (codePoint == Icons.icecream.codePoint) return Icons.icecream;
  if (codePoint == Icons.no_food.codePoint) return Icons.no_food;
  if (codePoint == Icons.check_circle.codePoint) return Icons.check_circle;
  if (codePoint == Icons.help.codePoint) return Icons.help;
  if (codePoint == Icons.check_circle_outline.codePoint) {
    return Icons.check_circle_outline;
  }
  if (codePoint == Icons.numbers.codePoint) return Icons.numbers;
  if (codePoint == Icons.timer_outlined.codePoint) return Icons.timer_outlined;
  if (codePoint == Icons.timer.codePoint) return Icons.timer;
  if (codePoint == Icons.local_fire_department.codePoint) {
    return Icons.local_fire_department;
  }
  if (codePoint == Icons.hourglass_bottom.codePoint) {
    return Icons.hourglass_bottom;
  }
  if (codePoint == Icons.restart_alt.codePoint) return Icons.restart_alt;
  if (codePoint == Icons.flag.codePoint) return Icons.flag;
  if (codePoint == Icons.save.codePoint) return Icons.save;
  if (codePoint == Icons.settings.codePoint) return Icons.settings;
  if (codePoint == Icons.person_outline.codePoint) return Icons.person_outline;
  // Default fallback
  return Icons.check_circle;
}
