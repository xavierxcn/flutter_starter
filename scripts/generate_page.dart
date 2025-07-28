import 'dart:io';

import 'history_manager.dart';

/// 页面生成脚本
/// 使用方法: dart run scripts/generate_page.dart page_name [module_name]
/// 例如: dart run scripts/generate_page.dart user_profile user
void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('错误: 请提供页面名称');
    print('使用方法: dart run scripts/generate_page.dart page_name [module_name]');
    print('例如: dart run scripts/generate_page.dart user_profile user');
    exit(1);
  }

  final pageName = arguments[0];
  final moduleName = arguments.length > 1 ? arguments[1] : null;

  // 验证名称格式
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(pageName)) {
    print('错误: 页面名称必须以小写字母开头，只能包含小写字母、数字和下划线');
    exit(1);
  }

  final generator = PageGenerator(pageName, moduleName);
  await generator.generate();
}

/// 页面生成器
class PageGenerator {
  final String pageName;
  final String? moduleName;
  late final String className;
  late final String controllerName;
  late final String pagePath;

  // 用于记录操作历史
  final List<String> _createdFiles = [];
  final Map<String, String> _modifiedFiles = {};

  PageGenerator(this.pageName, this.moduleName) {
    className = _toPascalCase(pageName);
    controllerName = '${className}Controller';

    if (moduleName != null) {
      pagePath = 'lib/pages/$moduleName/$pageName';
    } else {
      pagePath = 'lib/pages/$pageName';
    }
  }

  /// 生成页面文件
  Future<void> generate() async {
    print('正在生成页面: $pageName');
    print('页面路径: $pagePath');

    // 创建目录
    _createDirectory();

    // 生成文件
    _generateIndexFile();
    _generateControllerFile();
    _generateViewFile();

    // 更新pages/index.dart
    await _updatePagesIndex();

    // 记录操作历史
    await _recordOperation();

    print('✅ 页面生成完成!');
    print('生成的文件:');
    print('  - $pagePath/index.dart');
    print('  - $pagePath/controller.dart');
    print('  - $pagePath/view.dart');
    print('');
    print('📝 请手动更新路由配置:');
    print('1. 在 lib/common/routers/names.dart 中添加:');
    print(
      '   static const String ${_toCamelCase(pageName)} = \'/${_toKebabCase(pageName)}\';',
    );
    print('');
    print('2. 在 lib/common/routers/pages.dart 中添加:');
    print(
      '   GetPage(name: RouteNames.${_toCamelCase(pageName)}, page: () => const ${className}Page()),',
    );
    print('');
    print('💡 如需撤回此操作，请运行: dart run scripts/revert.dart');
  }

  /// 创建目录
  void _createDirectory() {
    final dir = Directory(pagePath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('📁 创建目录: $pagePath');
    }
  }

  /// 生成index.dart文件
  void _generateIndexFile() {
    final content = _loadTemplate('templates/page/index.dart.template', {
      'libraryName': _toCamelCase(pageName),
    });
    _writeFile('$pagePath/index.dart', content);
  }

  /// 生成controller.dart文件
  void _generateControllerFile() {
    final content = _loadTemplate('templates/page/controller.dart.template', {
      'className': className,
      'controllerName': controllerName,
      'pageName': pageName,
    });
    _writeFile('$pagePath/controller.dart', content);
  }

  /// 生成view.dart文件
  void _generateViewFile() {
    final content = _loadTemplate('templates/page/view.dart.template', {
      'className': className,
      'controllerName': controllerName,
      'pageName': pageName,
    });
    _writeFile('$pagePath/view.dart', content);
  }

  /// 更新pages/index.dart
  Future<void> _updatePagesIndex() async {
    final indexFile = File('lib/pages/index.dart');
    if (!indexFile.existsSync()) return;

    // 记录原始内容
    final originalContent = indexFile.readAsStringSync();
    _modifiedFiles['lib/pages/index.dart'] = originalContent;

    var content = originalContent;
    final exportPath = moduleName != null
        ? '$moduleName/$pageName/index.dart'
        : '$pageName/index.dart';
    final exportStatement = "export '$exportPath';";

    // 检查是否已存在
    if (content.contains(exportStatement)) {
      print('⚠️  导出语句已存在，跳过更新');
      return;
    }

    // 在最后一个export后添加新的export
    final lastExportPattern = RegExp(r"export '[^']+';");
    final matches = lastExportPattern.allMatches(content);

    if (matches.isNotEmpty) {
      final lastMatch = matches.last;
      final insertPosition = lastMatch.end;

      content =
          content.substring(0, insertPosition) +
          '\n$exportStatement' +
          content.substring(insertPosition);
      indexFile.writeAsStringSync(content);
      print('📝 更新页面导出: $exportStatement');
    }
  }

  /// 加载模板文件并替换变量
  String _loadTemplate(String templatePath, Map<String, String> variables) {
    final templateFile = File(templatePath);
    if (!templateFile.existsSync()) {
      throw Exception('模板文件不存在: $templatePath');
    }

    var content = templateFile.readAsStringSync();

    // 替换所有变量
    variables.forEach((key, value) {
      content = content.replaceAll('{{$key}}', value);
    });

    return content;
  }

  /// 写入文件
  void _writeFile(String path, String content) {
    final file = File(path);
    file.writeAsStringSync(content);
    _createdFiles.add(path);
    print('📄 生成文件: $path');
  }

  /// 记录操作历史
  Future<void> _recordOperation() async {
    await HistoryManager.recordGeneration(
      type: 'page',
      name: pageName,
      createdFiles: _createdFiles,
      modifiedFiles: _modifiedFiles,
      metadata: {
        'className': className,
        'controllerName': controllerName,
        'moduleName': moduleName,
        'pagePath': pagePath,
      },
    );
  }

  /// 转换为PascalCase
  String _toPascalCase(String input) {
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  /// 转换为camelCase
  String _toCamelCase(String input) {
    final words = input.split('_');
    return words[0] +
        words
            .skip(1)
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join('');
  }

  /// 转换为kebab-case
  String _toKebabCase(String input) {
    return input.replaceAll('_', '-');
  }
}
