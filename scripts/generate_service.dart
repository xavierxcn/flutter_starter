import 'dart:io';

import 'history_manager.dart';

/// 服务生成脚本
/// 使用方法: dart run scripts/generate_service.dart service_name
/// 例如: dart run scripts/generate_service.dart user_service
void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('错误: 请提供服务名称');
    print('使用方法: dart run scripts/generate_service.dart service_name');
    print('例如: dart run scripts/generate_service.dart user_service');
    exit(1);
  }

  final serviceName = arguments[0];

  // 验证名称格式
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(serviceName)) {
    print('错误: 服务名称必须以小写字母开头，只能包含小写字母、数字和下划线');
    exit(1);
  }

  final generator = ServiceGenerator(serviceName);
  await generator.generate();
}

/// 服务生成器
class ServiceGenerator {
  final String serviceName;
  late final String className;
  late final String modelName;
  late final String apiName;

  // 用于记录操作历史
  final List<String> _createdFiles = [];
  final Map<String, String> _modifiedFiles = {};

  ServiceGenerator(this.serviceName) {
    className = _toPascalCase(serviceName);
    // 移除 _service 后缀用于模型和API名称
    final baseName = serviceName.replaceAll('_service', '');
    modelName = '${_toPascalCase(baseName)}Model';
    apiName = '${_toPascalCase(baseName)}Api';
  }

  /// 生成服务相关文件
  Future<void> generate() async {
    print('正在生成服务: $serviceName');

    // 生成服务文件
    _generateServiceFile();

    // 生成模型文件
    _generateModelFile();

    // 生成API文件
    _generateApiFile();

    // 更新index文件
    await _updateIndexFiles();

    // 记录操作历史
    await _recordOperation();

    print('✅ 服务生成完成!');
    print('生成的文件:');
    print('  - lib/common/services/$serviceName.dart');
    print('  - lib/common/models/${modelName.toLowerCase()}.dart');
    print('  - lib/common/api/${apiName.toLowerCase()}.dart');
    print('');
    print('💡 如需撤回此操作，请运行: dart run scripts/revert.dart');
  }

  /// 生成服务文件
  void _generateServiceFile() {
    final content = _loadTemplate('templates/service/service.dart.template', {
      'className': className,
      'apiName': apiName,
      'modelName': modelName,
    });
    _writeFile('lib/common/services/$serviceName.dart', content);
  }

  /// 生成模型文件
  void _generateModelFile() {
    final content = _loadTemplate('templates/service/model.dart.template', {
      'modelName': modelName,
    });
    _writeFile('lib/common/models/${modelName.toLowerCase()}.dart', content);
  }

  /// 生成API文件
  void _generateApiFile() {
    final kebabName = _toKebabCase(serviceName.replaceAll('_service', ''));
    final content = _loadTemplate('templates/service/api.dart.template', {
      'apiName': apiName,
      'kebabName': kebabName,
    });
    _writeFile('lib/common/api/${apiName.toLowerCase()}.dart', content);
  }

  /// 更新index文件
  Future<void> _updateIndexFiles() async {
    await _updateIndexFile(
      'lib/common/services/index.dart',
      '$serviceName.dart',
    );
    await _updateIndexFile(
      'lib/common/models/index.dart',
      '${modelName.toLowerCase()}.dart',
    );
    await _updateIndexFile(
      'lib/common/api/index.dart',
      '${apiName.toLowerCase()}.dart',
    );
  }

  /// 更新指定的index文件
  Future<void> _updateIndexFile(String indexPath, String fileName) async {
    final indexFile = File(indexPath);
    final exportStatement = "export '$fileName';";

    if (indexFile.existsSync()) {
      // 记录原始内容
      final originalContent = indexFile.readAsStringSync();
      _modifiedFiles[indexPath] = originalContent;

      var content = originalContent;

      // 检查是否已存在
      if (content.contains(exportStatement)) {
        print('⚠️  导出语句已存在: $exportStatement');
        return;
      }

      // 添加到文件末尾
      if (!content.endsWith('\n')) {
        content += '\n';
      }
      content += exportStatement;

      indexFile.writeAsStringSync(content);
      print('📝 更新导出: $exportStatement');
    } else {
      // 创建新的index文件
      _modifiedFiles[indexPath] = ''; // 记录文件是新创建的

      final dir = indexFile.parent;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      indexFile.writeAsStringSync('$exportStatement\n');
      print('📝 创建导出文件: $indexPath');
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
    final dir = file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    file.writeAsStringSync(content);
    _createdFiles.add(path);
    print('📄 生成文件: $path');
  }

  /// 记录操作历史
  Future<void> _recordOperation() async {
    await HistoryManager.recordGeneration(
      type: 'service',
      name: serviceName,
      createdFiles: _createdFiles,
      modifiedFiles: _modifiedFiles,
      metadata: {
        'className': className,
        'modelName': modelName,
        'apiName': apiName,
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

  /// 转换为kebab-case
  String _toKebabCase(String input) {
    return input.replaceAll('_', '-');
  }
}
