import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connect_diagnostics.dart';

/// Provider the guided-connect wizard and the connection form read; tests
/// override it with a [ConnectDiagnostics] built on fakes. Lives in its own
/// file so [ConnectDiagnostics] itself stays Flutter-free (the `bin/` smoke
/// harness runs it on the pure Dart VM).
final connectDiagnosticsProvider = Provider<ConnectDiagnostics>(
  (ref) => ConnectDiagnostics(),
);
