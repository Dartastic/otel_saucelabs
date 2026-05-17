// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_saucelabs/otel_saucelabs.dart';
import 'package:test/test.dart';

void main() {
  group('otel_saucelabs', () {
    test('suppression toggles in zone', () async {
      expect(sauceLabsInstrumentationSuppressed(), isFalse);
      await runWithoutSauceLabsInstrumentationAsync(() async {
        expect(sauceLabsInstrumentationSuppressed(), isTrue);
      });
      expect(sauceLabsInstrumentationSuppressed(), isFalse);
    });

    test('SauceLabsResult fields default null', () {
      const r = SauceLabsResult();
      expect(r.statusCode, isNull);
    });
  });
}
