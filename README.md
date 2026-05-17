# otel_saucelabs

Dartastic OpenTelemetry bridge for Sauce Labs (cross-browser cloud testing).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_saucelabs/otel_saucelabs.dart';

await tracedSauceLabs<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return SauceLabsCallResult(value: r, result: SauceLabsResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutSauceLabsInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
