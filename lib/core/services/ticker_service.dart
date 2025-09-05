import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TickerService {
  const TickerService();

  Stream<int> countdown({required int fromSeconds}) {
    return Stream<int>.periodic(
      const Duration(seconds: 1),
      (i) => fromSeconds - i - 1,
    ).take(fromSeconds);
  }
}

final tickerServiceProvider = Provider<TickerService>(
  (ref) {
    return const TickerService();
  },
);
