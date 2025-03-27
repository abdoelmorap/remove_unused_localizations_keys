import 'dart:developer';

import 'package:remove_unused_localizations_keys/remove_unused_localizations_keys.dart';

void main(List<String> arguments) {
  bool keepUnused = arguments.contains('--keep-unused');

  log('Running Localization Cleaner...');
  runLocalizationCleaner(keepUnused: keepUnused);
  if (keepUnused) {
    log('✅ Unused keys saved to unused_localization_keys.txt');
  }
  log('Done.');
}
