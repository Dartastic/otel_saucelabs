// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_saucelabs_suppression.dart';

class SauceLabsResult {
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

class SauceLabsCallResult<T> {
  const SauceLabsCallResult({required this.value, this.result});
  final T value;
  final SauceLabsResult? result;
}

Future<T> tracedSauceLabs<T>({
  required String operation,
  required Future<SauceLabsCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (sauceLabsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_saucelabs');
  final span = t.startSpan('saucelabs $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'saucelabs')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.sessionId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('saucelabs.session.id', res.sessionId!)]));
      }
      if (res.buildName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('cicd.pipeline.run.name', res.buildName!)]));
      }
      if (res.browser != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('browser.name', res.browser!)]));
      }
      if (res.browserVersion != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('browser.version', res.browserVersion!)]));
      }
      if (res.os != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('os.name', res.os!)]));
      }
      if (res.osVersion != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('os.version', res.osVersion!)]));
      }
      if (res.device != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('device.model.name', res.device!)]));
      }
      if (res.testName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('test.name', res.testName!)]));
      }
      if (res.testStatus != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('test.status', res.testStatus!)]));
      }
      if (res.tunnelId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('saucelabs.tunnel.id', res.tunnelId!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('saucelabs.region', res.region!)]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('test.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('saucelabs.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
