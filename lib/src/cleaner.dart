import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  runLocalizationCleaner(
    dryRun: true, // يعرض المفاتيح غير المستخدمة دون حذفها
    keepUnused: false,
  );
}

/// تنظيف مفاتيح الترجمة غير المستخدمة
void runLocalizationCleaner({
  bool dryRun = false,
  bool keepUnused = false,
}) {
  // 1. قراءة الإعدادات من l10n.yaml
  final config = _loadConfig();

  // 2. استخراج جميع المفاتيح من ملفات .arb
  final (allKeys, fileKeyMap) = _extractAllKeys(config);

  if (allKeys.isEmpty) {
    print('❌ No localization keys found in ${config.localizationDir.path}');
    return;
  }

  // 3. البحث عن المفاتيح المستخدمة في الكود
  final usedKeys = _findUsedKeys(allKeys, config);

  // 4. تحديد المفاتيح غير المستخدمة
  final unusedKeys = allKeys.difference(usedKeys);
  if (unusedKeys.isEmpty) {
    print('✅ No unused keys found.');
    return;
  }

  // 5. معالجة المفاتيح غير المستخدمة
  _handleUnusedKeys(
    unusedKeys: unusedKeys,
    fileKeyMap: fileKeyMap,
    dryRun: dryRun,
    keepUnused: keepUnused,
  );
}

class Config {
  final Directory localizationDir;
  final Set<String> excludedFiles;

  Config(this.localizationDir, this.excludedFiles);
}

/// 1. تحميل الإعدادات من l10n.yaml
Config _loadConfig() {
  const defaultDir = 'lib/l10n';
  const defaultExcluded = {'lib/l10n/app_localizations.dart'};

  final yamlFile = File('l10n.yaml');
  if (!yamlFile.existsSync()) {
    print('⚠️ l10n.yaml not found. Using default directory: $defaultDir');
    return Config(Directory(defaultDir), defaultExcluded);
  }

  try {
    final yamlData = loadYaml(yamlFile.readAsStringSync()) as Map;
    final arbDir = yamlData['arb-dir'] as String? ?? defaultDir;
    final outputDir = yamlData['output-dir'] as String? ?? '';
    final outputFile = yamlData['output-localization-file'] as String? ?? '';

    return Config(
      Directory(arbDir),
      {'$outputDir/$outputFile'},
    );
  } catch (e) {
    print('❌ Error parsing l10n.yaml: $e');
    return Config(Directory(defaultDir), defaultExcluded);
  }
}

/// 2. استخراج جميع المفاتيح من ملفات ARB
(Set<String>, Map<File, Set<String>>) _extractAllKeys(Config config) {
  final allKeys = <String>{};
  final fileKeyMap = <File, Set<String>>{};

  final arbFiles = config.localizationDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList();

  for (final file in arbFiles) {
    try {
      final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final keys = data.keys.where((k) => !k.startsWith('@')).toSet();
      allKeys.addAll(keys);
      fileKeyMap[file] = keys;
    } catch (e) {
      print('❌ Error reading ${file.path}: $e');
    }
  }

  return (allKeys, fileKeyMap);
}

/// 3. البحث عن المفاتيح المستخدمة في الكود
Set<String> _findUsedKeys(Set<String> allKeys, Config config) {
  final usedKeys = <String>{};
  final libDir = Directory('lib');
  final keysPattern = allKeys.map(RegExp.escape).join('|');

  final regex = RegExp(
    r'(?:[\w.]+\.of\(.*?\)\.|[\w.]+\.)(' + keysPattern + r')\b',
    multiLine: true,
  );

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File ||
        !entity.path.endsWith('.dart') ||
        config.excludedFiles.contains(entity.path)) {
      continue;
    }

    final content = entity.readAsStringSync();
    if (!content.contains(RegExp(keysPattern))) continue;

    for (final match in regex.allMatches(content)) {
      usedKeys.add(match.group(1)!);
    }
  }

  return usedKeys;
}

/// 4. معالجة المفاتيح غير المستخدمة
void _handleUnusedKeys({
  required Set<String> unusedKeys,
  required Map<File, Set<String>> fileKeyMap,
  required bool dryRun,
  required bool keepUnused,
}) {
  print('🔍 Found ${unusedKeys.length} unused keys:');
  print(unusedKeys.join('\n'));

  if (dryRun) {
    print('🚀 Dry run completed (no changes made)');
    return;
  }

  if (keepUnused) {
    File('unused_keys.txt').writeAsStringSync(unusedKeys.join('\n'));
    print('📄 Saved unused keys to unused_keys.txt');
    return;
  }

  // حذف المفاتيح غير المستخدمة
  for (final entry in fileKeyMap.entries) {
    final file = entry.key;
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    bool updated = false;

    for (final key in unusedKeys) {
      if (data.containsKey(key)) {
        data.remove(key);
        data.remove('@$key');
        updated = true;
      }
    }

    if (updated) {
      file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
      print('✂️ Removed keys from ${file.path}');
    }
  }

  print('✅ Successfully removed unused keys');
}