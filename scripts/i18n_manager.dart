import 'dart:io';
import 'dart:convert';

/// i18n翻译管理脚本
/// 使用方法:
/// dart run scripts/i18n_manager.dart --check       # 检查缺失的翻译
/// dart run scripts/i18n_manager.dart --export      # 导出翻译到JSON
/// dart run scripts/i18n_manager.dart --stats       # 显示翻译统计
/// dart run scripts/i18n_manager.dart --validate    # 验证翻译格式
void main(List<String> arguments) async {
  if (arguments.isEmpty ||
      arguments.contains('--help') ||
      arguments.contains('-h')) {
    _showHelp();
    return;
  }

  final manager = I18nManager();

  try {
    if (arguments.contains('--check')) {
      await manager.checkMissingTranslations();
    } else if (arguments.contains('--export')) {
      await manager.exportTranslations();
    } else if (arguments.contains('--stats')) {
      await manager.showStatistics();
    } else if (arguments.contains('--validate')) {
      await manager.validateTranslations();
    } else {
      print('❌ 未知命令: ${arguments.join(' ')}');
      _showHelp();
    }
  } catch (e) {
    print('❌ 执行失败: $e');
    exit(1);
  }
}

/// 显示帮助信息
void _showHelp() {
  print('''
🌐 i18n翻译管理工具
==================

用法:
  dart run scripts/i18n_manager.dart --check       # 检查缺失的翻译
  dart run scripts/i18n_manager.dart --export      # 导出翻译到JSON
  dart run scripts/i18n_manager.dart --stats       # 显示翻译统计
  dart run scripts/i18n_manager.dart --validate    # 验证翻译格式

选项:
  -h, --help     显示此帮助信息

示例:
  dart run scripts/i18n_manager.dart --check
  dart run scripts/i18n_manager.dart --export
''');
}

/// i18n管理器
class I18nManager {
  static const String _messagesFile = 'lib/common/i18n/messages.dart';
  static const String _outputDir = 'assets/i18n';

  /// 检查缺失的翻译
  Future<void> checkMissingTranslations() async {
    print('🔍 检查缺失的翻译...');

    final translations = await _parseTranslations();
    if (translations.isEmpty) {
      print('❌ 无法解析翻译文件');
      return;
    }

    final languages = translations.keys.toList();
    if (languages.length < 2) {
      print('⚠️  只找到 ${languages.length} 种语言');
      return;
    }

    print('📋 支持的语言: ${languages.join(', ')}');
    print('');

    bool hasMissing = false;

    // 以第一种语言为基准检查其他语言
    final baseLanguage = languages.first;
    final baseKeys = translations[baseLanguage]!.keys.toSet();

    for (final language in languages.skip(1)) {
      final currentKeys = translations[language]!.keys.toSet();
      final missingKeys = baseKeys.difference(currentKeys);
      final extraKeys = currentKeys.difference(baseKeys);

      if (missingKeys.isNotEmpty || extraKeys.isNotEmpty) {
        hasMissing = true;
        print('❌ 语言 $language:');

        if (missingKeys.isNotEmpty) {
          print('   缺失翻译 (${missingKeys.length} 个):');
          for (final key in missingKeys.take(10)) {
            print('     - $key');
          }
          if (missingKeys.length > 10) {
            print('     ... 还有 ${missingKeys.length - 10} 个');
          }
        }

        if (extraKeys.isNotEmpty) {
          print('   多余翻译 (${extraKeys.length} 个):');
          for (final key in extraKeys.take(5)) {
            print('     + $key');
          }
          if (extraKeys.length > 5) {
            print('     ... 还有 ${extraKeys.length - 5} 个');
          }
        }
        print('');
      }
    }

    if (!hasMissing) {
      print('✅ 所有语言的翻译都是完整的!');
    }
  }

  /// 导出翻译到JSON文件
  Future<void> exportTranslations() async {
    print('📤 导出翻译文件...');

    final translations = await _parseTranslations();
    if (translations.isEmpty) {
      print('❌ 无法解析翻译文件');
      return;
    }

    // 创建输出目录
    final outputDir = Directory(_outputDir);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    // 为每种语言创建JSON文件
    for (final entry in translations.entries) {
      final language = entry.key;
      final data = entry.value;

      final jsonFile = File('$_outputDir/$language.json');
      final jsonContent = const JsonEncoder.withIndent('  ').convert(data);

      await jsonFile.writeAsString(jsonContent);
      print('📄 已导出: ${jsonFile.path} (${data.length} 个翻译)');
    }

    print('✅ 翻译导出完成!');
  }

  /// 显示翻译统计
  Future<void> showStatistics() async {
    print('📊 翻译统计信息');
    print('${'=' * 50}');

    final translations = await _parseTranslations();
    if (translations.isEmpty) {
      print('❌ 无法解析翻译文件');
      return;
    }

    final languages = translations.keys.toList();
    print('支持的语言数量: ${languages.length}');
    print('');

    // 按类别统计
    final categories = <String, int>{};

    for (final entry in translations.entries) {
      final language = entry.key;
      final data = entry.value;

      print('🌐 $language:');
      print('   总翻译数: ${data.length}');

      // 按前缀分类统计
      final categoryCount = <String, int>{};
      for (final key in data.keys) {
        final prefix = key.split('_').first;
        categoryCount[prefix] = (categoryCount[prefix] ?? 0) + 1;
      }

      print('   分类统计:');
      for (final cat in categoryCount.entries) {
        print('     ${cat.key}: ${cat.value} 个');
        categories[cat.key] = (categories[cat.key] ?? 0) + cat.value;
      }
      print('');
    }

    print('📈 总体分类统计:');
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final cat in sortedCategories) {
      print('   ${cat.key}: ${cat.value} 个翻译');
    }
  }

  /// 验证翻译格式
  Future<void> validateTranslations() async {
    print('🔧 验证翻译格式...');

    final translations = await _parseTranslations();
    if (translations.isEmpty) {
      print('❌ 无法解析翻译文件');
      return;
    }

    bool hasIssues = false;

    for (final entry in translations.entries) {
      final language = entry.key;
      final data = entry.value;

      print('🔍 检查 $language...');

      // 检查空值
      final emptyKeys = data.entries
          .where((e) => e.value.trim().isEmpty)
          .map((e) => e.key);
      if (emptyKeys.isNotEmpty) {
        hasIssues = true;
        print(
          '   ⚠️  空翻译 (${emptyKeys.length} 个): ${emptyKeys.take(5).join(', ')}',
        );
      }

      // 检查重复值
      final valueCount = <String, List<String>>{};
      for (final entry in data.entries) {
        final value = entry.value.trim();
        if (value.isNotEmpty) {
          valueCount[value] = (valueCount[value] ?? [])..add(entry.key);
        }
      }

      final duplicates = valueCount.entries.where((e) => e.value.length > 1);
      if (duplicates.isNotEmpty) {
        hasIssues = true;
        print('   ⚠️  重复翻译 (${duplicates.length} 组):');
        for (final dup in duplicates.take(3)) {
          print('     "${dup.key}" -> ${dup.value.join(', ')}');
        }
      }

      // 检查命名规范
      final invalidKeys = data.keys.where(
        (key) => !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(key),
      );
      if (invalidKeys.isNotEmpty) {
        hasIssues = true;
        print(
          '   ⚠️  命名不规范 (${invalidKeys.length} 个): ${invalidKeys.take(5).join(', ')}',
        );
      }
    }

    if (!hasIssues) {
      print('✅ 翻译格式验证通过!');
    } else {
      print('❌ 发现格式问题，建议修复');
    }
  }

  /// 解析翻译文件
  Future<Map<String, Map<String, String>>> _parseTranslations() async {
    final file = File(_messagesFile);
    if (!file.existsSync()) {
      print('❌ 翻译文件不存在: $_messagesFile');
      return {};
    }

    try {
      final content = await file.readAsString();

      // 简单的正则表达式解析（适用于当前格式）
      final translations = <String, Map<String, String>>{};

      // 匹配语言块 'zh_CN': { ... }
      final languagePattern = RegExp(
        r"'([^']+)':\s*\{([^}]+(?:\}[^}]*)*)\}",
        multiLine: true,
        dotAll: true,
      );
      final matches = languagePattern.allMatches(content);

      for (final match in matches) {
        final language = match.group(1)!;
        final blockContent = match.group(2)!;

        // 匹配键值对 'key': 'value',
        final keyValuePattern = RegExp(
          r"'([^']+)':\s*'([^']*)'",
          multiLine: true,
        );
        final kvMatches = keyValuePattern.allMatches(blockContent);

        final langTranslations = <String, String>{};
        for (final kvMatch in kvMatches) {
          final key = kvMatch.group(1)!;
          final value = kvMatch.group(2)!;
          langTranslations[key] = value;
        }

        if (langTranslations.isNotEmpty) {
          translations[language] = langTranslations;
        }
      }

      return translations;
    } catch (e) {
      print('❌ 解析翻译文件失败: $e');
      return {};
    }
  }

  /// 找到匹配的大括号位置
  int _findMatchingBrace(String content, int startPos) {
    int braceCount = 1;
    int pos = startPos + 1;

    while (pos < content.length && braceCount > 0) {
      if (content[pos] == '{') {
        braceCount++;
      } else if (content[pos] == '}') {
        braceCount--;
      }
      pos++;
    }

    return pos - 1;
  }
}
