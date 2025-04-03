import 'dart:developer';

import 'package:remove_unused_localizations_keys/remove_unused_localizations_keys.dart';

void main(List<String> arguments) {
  bool keepUnused = arguments.contains('--keep-unused');
  bool dryRun = arguments.contains('--dry-run');
  LocalizationSystem system = LocalizationSystem.arb;

  if (arguments.contains('--getx')) {
    system = LocalizationSystem.getx;
  } else if (arguments.contains('--easyloc')) {
    system = LocalizationSystem.easyLoc;
  }

  print('Running Localization Cleaner...');
  runLocalizationCleaner(keepUnused: keepUnused, system: system, dryRun: dryRun);
  if (keepUnused) {
    print('✅ Unused keys saved to unused_localization_keys.txt');
  }
  print('Done.');
}
