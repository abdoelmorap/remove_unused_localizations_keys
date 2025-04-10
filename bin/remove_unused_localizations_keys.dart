import 'dart:developer';

import 'package:remove_unused_localizations_keys/remove_unused_localizations_keys.dart';

void main(List<String> arguments) {
  bool keepUnused = arguments.contains('--keep-unused');
  bool useEasyLocalization = arguments.contains('--easy-loc');
  
  String? customPath;
  for (int i = 0; i < arguments.length; i++) {
    if (arguments[i].startsWith('path=')) {
      customPath = arguments[i].substring(5); // Remove 'path=' prefix
      break;
    }
  }

  log('Running Localization Cleaner...');
  if (useEasyLocalization) {
    log('Using easy_localization mode');
    if (customPath != null) {
      log('Using custom translations path: $customPath');
    }
  }
  runLocalizationCleaner(
    keepUnused: keepUnused,
    useEasyLocalization: useEasyLocalization,
    easyLocalizationPath: customPath,
  );
  if (keepUnused) {
    log('✅ Unused keys saved to unused_localization_keys.txt');
  }
  log('Done.');
}