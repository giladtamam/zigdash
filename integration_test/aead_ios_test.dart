import 'package:integration_test/integration_test.dart';

import '../test/core/crypto/aead_vectors.dart';

/// The App Store build's CryptoKit and CommonCrypto path against Node, on an
/// iOS simulator: `tool/flutter test integration_test/aead_ios_test.dart -d
/// SIMULATOR --flavor appstore --dart-define=ZIGDASH_FLAVOR=appstore`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  aeadVectorTests();
}
