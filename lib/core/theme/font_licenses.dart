import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled fonts' licences (SIL OFL, Apache 2.0) to the licences
/// page that About › Version opens.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (package, file) in const [
      ('Space Grotesk', 'SpaceGrotesk-OFL.txt'),
      ('IBM Plex Sans', 'IBMPlexSans-OFL.txt'),
      ('IBM Plex Sans Hebrew', 'IBMPlexSansHebrew-OFL.txt'),
      ('Material Symbols', 'MaterialSymbols-LICENSE.txt'),
    ]) {
      final text = await rootBundle.loadString('assets/fonts/licenses/$file');
      yield LicenseEntryWithLineBreaks([package], text);
    }
  });
}
