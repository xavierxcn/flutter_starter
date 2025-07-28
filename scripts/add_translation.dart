import 'dart:io';

/// 添加新翻译的脚本
/// 使用方法: dart run scripts/add_translation.dart <key> <zh_value> <en_value>
/// 例如: dart run scripts/add_translation.dart "new_feature" "新功能" "New Feature"
void main(List<String> arguments) async {
  if (arguments.length < 3) {
    print(
      '使用方法: dart run scripts/add_translation.dart <key> <zh_value> <en_value>',
    );
    print(
      '例如: dart run scripts/add_translation.dart "new_feature" "新功能" "New Feature"',
    );
    exit(1);
  }

  final key = arguments[0];
  final zhValue = arguments[1];
  final enValue = arguments[2];

  // 验证key格式
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(key)) {
    print('❌ 翻译键格式不正确，必须以小写字母开头，只能包含小写字母、数字和下划线');
    exit(1);
  }

  final adder = TranslationAdder();
  await adder.addTranslation(key, zhValue, enValue);
}

/// 翻译添加器
class TranslationAdder {
  static const String _messagesFile = 'lib/common/i18n/messages.dart';

  /// 添加新翻译
  Future<void> addTranslation(
    String key,
    String zhValue,
    String enValue,
  ) async {
    final file = File(_messagesFile);
    if (!file.existsSync()) {
      print('❌ 翻译文件不存在: $_messagesFile');
      exit(1);
    }

    var content = await file.readAsString();

    // 检查是否已存在
    if (content.contains("'$key':")) {
      print('⚠️  翻译键 "$key" 已存在');
      print('是否要覆盖? (y/N)');
      final input = stdin.readLineSync()?.toLowerCase();
      if (input != 'y' && input != 'yes') {
        print('❌ 操作已取消');
        return;
      }
    }

    try {
      // 添加中文翻译
      content = _addTranslationToLanguage(content, 'zh_CN', key, zhValue);

      // 添加英文翻译
      content = _addTranslationToLanguage(content, 'en_US', key, enValue);

      await file.writeAsString(content);

      print('✅ 翻译添加成功!');
      print('   键: $key');
      print('   中文: $zhValue');
      print('   英文: $enValue');
    } catch (e) {
      print('❌ 添加翻译失败: $e');
      exit(1);
    }
  }

  /// 添加翻译到指定语言
  String _addTranslationToLanguage(
    String content,
    String language,
    String key,
    String value,
  ) {
    // 转义单引号
    final escapedValue = value.replaceAll("'", "\\'");
    final translationLine = "      '$key': '$escapedValue',";

    // 找到语言块的结束位置
    final languageStartPattern = RegExp("'$language':\\s*\\{");
    final languageStartMatch = languageStartPattern.firstMatch(content);

    if (languageStartMatch == null) {
      throw Exception('找不到语言块: $language');
    }

    final startPos = languageStartMatch.end;

    // 找到对应的结束大括号
    int braceCount = 1;
    int endPos = startPos;

    while (endPos < content.length && braceCount > 0) {
      if (content[endPos] == '{') {
        braceCount++;
      } else if (content[endPos] == '}') {
        braceCount--;
      }
      endPos++;
    }

    if (braceCount != 0) {
      throw Exception('语言块格式错误: $language');
    }

    // 在结束大括号前插入新翻译
    final insertPos = endPos - 1;

    // 检查是否已存在该键
    final languageBlock = content.substring(startPos, insertPos);
    final existingKeyPattern = RegExp("'$key':\\s*'[^']*'");

    if (existingKeyPattern.hasMatch(languageBlock)) {
      // 替换现有翻译
      content = content.replaceFirst(
        RegExp("('$key':\\s*')[^']*'"),
        "\$1$escapedValue'",
      );
    } else {
      // 添加新翻译
      final beforeInsert = content.substring(0, insertPos);
      final afterInsert = content.substring(insertPos);

      // 确保前面有换行
      final needsNewline =
          !beforeInsert.endsWith('\n') && !beforeInsert.endsWith(',\n');
      final prefix = needsNewline ? '\n' : '';

      content =
          beforeInsert + prefix + translationLine + '\n      ' + afterInsert;
    }

    return content;
  }
}
