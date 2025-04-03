import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';

enum LocalizationSystem { arb, getx, easyLoc }

class LocalizationConfig {
  final Directory localizationDir;
  final Set<String> excludedFiles;
  final LocalizationSystem system;

  LocalizationConfig(this.localizationDir, this.excludedFiles, this.system);
}

void runLocalizationCleaner({
  bool keepUnused = false,
  LocalizationSystem system = LocalizationSystem.arb,
  bool dryRun = false,
}) {
  try {
    final config = _readConfig(system);
    final allKeys = _extractLocalizationKeys(config);
    final usedKeys = _findUsedKeys(allKeys, config);
    _processUnusedKeys(usedKeys, allKeys, config, keepUnused, dryRun);
  } catch (e) {
    print('Error: $e');
  }
}

LocalizationConfig _readConfig(LocalizationSystem system) {
  if (system == LocalizationSystem.arb) {
    final yamlFile = File('l10n.yaml');
    if (!yamlFile.existsSync()) {
      return LocalizationConfig(Directory('lib/l10n'), {}, system);
    }

    final yamlData = loadYaml(yamlFile.readAsStringSync());
    final arbDir = yamlData['arb-dir'] as String;
    final outputDir = yamlData['output-dir'] ?? "";
    final outputFile = yamlData['output-localization-file'] ?? "";

    return LocalizationConfig(
      Directory(arbDir),
      {'$outputDir/$outputFile'},
      system,
    );
  }

  return LocalizationConfig(
    system == LocalizationSystem.getx
        ? Directory('assets/translations')
        : Directory('lib/l10n'),
    {},
    system,
  );
}

Set<String> _extractLocalizationKeys(LocalizationConfig config) {
  final files = config.localizationDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json') || file.path.endsWith('.arb'))
      .toList();

  final allKeys = <String>{};

  for (final file in files) {
    final content = json.decode(file.readAsStringSync());

    if (config.system == LocalizationSystem.getx) {
      final Map<String, dynamic> locales = content;
      for (final locale in locales.values) {
        allKeys.addAll((locale ).keys);
      }
    } else {
      allKeys.addAll(content.keys.where((key) => !key.startsWith('@')));
    }
  }

  return allKeys;
}

Set<String> _findUsedKeys(Set<String> allKeys, LocalizationConfig config) {
  final usedKeys = <String>{};
  final libDir = Directory('lib');

  String pattern;
  switch (config.system) {
    case LocalizationSystem.getx:
      pattern = r'''['"](.*?)['"]\.tr\b''';
      break;
    case LocalizationSystem.easyLoc:
      pattern = r'''['"](.*?)['"]\.tr\(\)''';
      break;
    default:
      pattern = allKeys.map(RegExp.escape).join('|');
  }

  final regex = RegExp(pattern);

  for (final file in libDir.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart') || config.excludedFiles.contains(file.path)) {
      continue;
    }

    final content = file.readAsStringSync();
    for (final match in regex.allMatches(content)) {
      usedKeys.add(match.group(1)!);
    }
  }

  return usedKeys;
}

void _processUnusedKeys(
    Set<String> usedKeys,
    Set<String> allKeys,
    LocalizationConfig config,
    bool keepUnused,
    bool dryRun,
    ) {
  final unusedKeys = allKeys.difference(usedKeys);

  if (unusedKeys.isEmpty) {
    print('No unused localization keys found.');
    return;
  }

  if (keepUnused) {
    File('unused_keys.txt').writeAsStringSync(unusedKeys.join('\n'));
    print('Unused keys saved to unused_keys.txt');
    return;
  }

  if (dryRun) {
    print('Dry run mode: The following keys would be removed:');
    unusedKeys.forEach(print);
    return;
  }

  for (final file in config.localizationDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.json') && !file.path.endsWith('.arb')) continue;

    try {
      final content = json.decode(file.readAsStringSync());
      bool updated = false;

      if (config.system == LocalizationSystem.getx) {
        for (final locale in content.keys) {
          for (final key in unusedKeys) {
            if (content[locale].containsKey(key)) {
              content[locale].remove(key);
              updated = true;
            }
          }
        }
      } else {
        for (final key in unusedKeys) {
          if (content.containsKey(key)) {
            content.remove(key);
            content.remove('@$key');
            updated = true;
          }
        }
      }

      if (updated) {
        file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(content));
        print('Updated ${file.path}, removed ${unusedKeys.length} keys.');
      }
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }
  print('Removed ${unusedKeys.length} unused keys.');
}
