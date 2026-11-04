// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_saucelabs_suppression.dart';

class SauceLabsResult {
  /// Creates a result.
  const SauceLabsResult({
    this.sessionId,
    this.buildName,
    this.browser,
    this.browserVersion,
    this.os,
    this.osVersion,
    this.device,
    this.testName,
    this.testStatus,
    this.tunnelId,
    this.region,
    this.durationMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? sessionId;
  final String? buildName;
  final String? browser;
  final String? browserVersion;
  final String? os;
  final String? osVersion;
  final String? device;
  final String? testName;
  final String? testStatus;
  final String? tunnelId;
  final String? region;
  final int? durationMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class SauceLabsCallResult<T> {
  /// Creates a call result.
  const SauceLabsCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final SauceLabsResult? result;
}

Future<T> tracedSauceLabs<T>({
  required String operation,
  required Future<SauceLabsCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (sauceLabsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_saucelabs');
  final span = t.startSpan('saucelabs $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'saucelabs')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.sessionId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('saucelabs.session.id', res.sessionId!)]));
      }
      if (res.buildName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('cicd.pipeline.run.name', res.buildName!)
        ]));
      }
      if (res.browser != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('browser.name', res.browser!)]));
      }
      if (res.browserVersion != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('browser.version', res.browserVersion!)]));
      }
      if (res.os != null) {
        span.addAttributes(
            OTelAPI.attributes([OTelAPI.attributeString('os.name', res.os!)]));
      }
      if (res.osVersion != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('os.version', res.osVersion!)]));
      }
      if (res.device != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('device.model.name', res.device!)]));
      }
      if (res.testName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('test.name', res.testName!)]));
      }
      if (res.testStatus != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('test.status', res.testStatus!)]));
      }
      if (res.tunnelId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('saucelabs.tunnel.id', res.tunnelId!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('saucelabs.region', res.region!)]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('test.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('saucelabs.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'saucelabs.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
