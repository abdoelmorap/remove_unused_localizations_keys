import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:yaml/yaml.dart';

/// Scans the project for unused localization keys and removes them from `.arb` files.
/// If [keepUnused] is true, unused keys will be saved to a file instead of being removed.
/// If [useEasyLocalization] is true, only easy_localization patterns will be searched for.
/// If [easyLocalizationPath] is provided, it will be used as the path for easy_localization files.
void runLocalizationCleaner({
  bool keepUnused = false,
  bool useEasyLocalization = false,
  String? easyLocalizationPath,
}) {
  final File yamlFile = File('l10n.yaml'); // Path to your l10n.yaml file

  Directory localizationDir = Directory('lib/l10n');
  Set<String> excludedFiles = {'lib/l10n/app_localizations.dart'};
  if (!yamlFile.existsSync()) {
    log(
      'Error: l10n.yaml file not found! App will use defualts of loc dir $localizationDir',
    );
  } else {
    // Read & parse YAML
    final String yamlContent = yamlFile.readAsStringSync();
    final Map yamlData = loadYaml(yamlContent);

    // Extract values dynamically
    final String arbDir = yamlData['arb-dir'] as String;
    final String outputDir = yamlData['output-dir'] ?? "";
    final String outputFile =
        yamlData['output-localization-file'] ?? excludedFiles;
    // Construct values
    localizationDir = Directory(arbDir);
    excludedFiles = {'$outputDir/$outputFile'};
  }

  // For easy_localization, look for JSON files in the specified path or default to assets/translations
  if (useEasyLocalization) {
    localizationDir = Directory(easyLocalizationPath ?? 'assets/translations');
    if (!localizationDir.existsSync()) {
      log('Error: ${localizationDir.path} directory not found for easy_localization!');
      return;
    }
  }

  final List<File> localizationFiles = localizationDir
      .listSync()
      .whereType<File>()
      .where((file) => useEasyLocalization
          ? file.path.endsWith('.json')
          : file.path.endsWith('.arb'))
      .toList();

  if (localizationFiles.isEmpty) {
    log('No ${useEasyLocalization ? ".json" : ".arb"} files found in ${localizationDir.path}');
    return;
  }

  final Set<String> allKeys = <String>{};
  final Map<File, Set<String>> fileKeyMap = <File, Set<String>>{};

  // Read all keys from localization files
  for (final File file in localizationFiles) {
    final Map<String, dynamic> data =
        json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final Set<String> keys = useEasyLocalization
        ? data.keys.toSet() // For JSON files, all keys are valid
        : data.keys
            .where((key) => !key.startsWith('@'))
            .toSet(); // For ARB files, exclude metadata
    allKeys.addAll(keys);
    fileKeyMap[file] = keys;
  }

  final Set<String> usedKeys = <String>{};
  final Directory libDir = Directory('lib');

  final String keysPattern = allKeys.map(RegExp.escape).join('|');

  // Create appropriate regex based on mode
  final RegExp regex = useEasyLocalization
      ? RegExp(
          // Match easy_localization patterns
          'LocaleKeys\\.($keysPattern)(?:\\.tr\\([^)]*\\)|\\.plural\\([^)]*\\))?|' // LocaleKeys.key with optional .tr() or .plural()
          '(?:context|this)\\.tr\\([\'"]($keysPattern)[\'"]\\)|' // context.tr('key')
          'tr\\([\'"]($keysPattern)[\'"]\\)|' // tr('key')
          '[\'"]($keysPattern)[\'"]\\.tr\\([^)]*\\)', // "key".tr() or 'key'.tr()
          multiLine: true,
          dotAll: true)
      : RegExp(
          r'(?:' // Start non-capturing group for all possible access patterns
                  r'(?:[a-zA-Z0-9_]+\.)+' // e.g., `_appLocalizations.` or `cubit.appLocalizations.`
                  r'|'
                  r'[a-zA-Z0-9_]+\.of\(\s*(?:context|AppNavigation\.context|this\.context|BuildContext\s+\w+)\s*\)\!?\s*\.\s*' // `of(context)!.key` with optional whitespace
                  r'|'
                  r'[a-zA-Z0-9_]+\.\w+\(\s*\)\s*\.\s*' // `SomeClass.method().key`
                  r')'
                  r'(' +
              keysPattern +
              r')\b', // The actual key
          multiLine: true,
          dotAll: true,
        );

  for (final FileSystemEntity file in libDir.listSync(recursive: true)) {
    if (file is File &&
        file.path.endsWith('.dart') &&
        !excludedFiles.contains(file.path)) {
      final String content = file.readAsStringSync();

      // Quick pre-check: Skip files that don't contain any key substring
      if (!content.contains(RegExp(keysPattern))) continue;

      for (final Match match in regex.allMatches(content)) {
        if (useEasyLocalization) {
          // For easy_localization, check all capture groups
          final String? key = match.group(1) ??
              match.group(2) ??
              match.group(3) ??
              match.group(4);
          if (key != null && allKeys.contains(key)) {
            usedKeys.add(key);
          }
        } else {
          usedKeys.add(match.group(1)!);
        }
      }
    }
  }

  // Determine unused keys
  final Set<String> unusedKeys = allKeys.difference(usedKeys);
  if (unusedKeys.isEmpty) {
    log('No unused localization keys found.');
    return;
  }

  log("Unused keys found: ${unusedKeys.join(', ')}");

  if (keepUnused) {
    // Keep unused keys to a file instead of deleting them
    final File unusedKeysFile = File('unused_localization_keys.txt');
    unusedKeysFile.writeAsStringSync(unusedKeys.join('\n'));
    log('✅ Unused keys saved to ${unusedKeysFile.path}');
  } else {
    // Remove unused keys from all localization files
    for (final MapEntry<File, Set<String>> entry in fileKeyMap.entries) {
      final File file = entry.key;
      final Set<String> keys = entry.value;
      final Map<String, dynamic> data =
          json.decode(file.readAsStringSync()) as Map<String, dynamic>;

      bool updated = false;
      for (final key in keys) {
        if (unusedKeys.contains(key)) {
          data.remove(key);
          if (!useEasyLocalization) {
            data.remove('@$key'); // Only remove metadata for ARB files
          }
          updated = true;
        }
      }

      if (updated) {
        file.writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(data),
        );
        log('Updated ${file.path}, removed unused keys.');
      }
    }
    log('✅ Unused keys successfully removed.');
  }
}
