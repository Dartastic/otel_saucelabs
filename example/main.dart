// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_saucelabs/otel_saucelabs.dart';

/// Traces Saucelabs calls with OpenTelemetry.
///
/// `otel_saucelabs` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Saucelabs call in
/// [tracedSauceLabs]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'saucelabs-example');

  // Traces a Saucelabs call.
  final sauceLabsId = await tracedSauceLabs<String>(
    operation: 'create',
    invoke: () async {
      // Make the Saucelabs call here, then report what it returned.
      const id = 'saucelabs_8f3a2c';
      return const SauceLabsCallResult(
          value: id,
          result: SauceLabsResult(
              sessionId: 'session_8f3a2c',
              buildName: 'example',
              browser: 'example',
              browserVersion: '1',
              os: 'example',
              osVersion: '1',
              device: 'example',
              testName: 'example',
              testStatus: 'succeeded',
              tunnelId: 'tunnel_8f3a2c',
              region: 'us-east-1',
              durationMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedSauceLabs create returned $sauceLabsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutSauceLabsInstrumentationAsync.
  await runWithoutSauceLabsInstrumentationAsync(
    () => tracedSauceLabs<String>(
      operation: 'create',
      invoke: () async {
        const id = 'saucelabs_8f3a2c';
        return const SauceLabsCallResult(
            value: id,
            result: SauceLabsResult(
                sessionId: 'session_8f3a2c',
                buildName: 'example',
                browser: 'example',
                browserVersion: '1',
                os: 'example',
                osVersion: '1',
                device: 'example',
                testName: 'example',
                testStatus: 'succeeded',
                tunnelId: 'tunnel_8f3a2c',
                region: 'us-east-1',
                durationMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
