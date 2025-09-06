import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'app_colors.dart';

final seedColorProvider = StateProvider<Color>((_) => AppColors.coral);

final themeProvider = Provider<ThemeData>(
  (ref) {
    final seed = ref.watch(seedColorProvider);
    return AppTheme.lightWithSeed(seed);
  },
);
