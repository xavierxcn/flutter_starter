import 'dart:io';

/// 快速项目设置脚本
/// 使用方法: dart run scripts/quick_setup.dart --name="我的应用" --package="com.company.myapp" [--description="应用描述"] [--icon="icon.png"]
void main(List<String> arguments) async {
  if (arguments.isEmpty ||
      arguments.contains('--help') ||
      arguments.contains('-h')) {
    _showHelp();
    return;
  }

  try {
    final config = _parseArguments(arguments);
    final setupTool = QuickSetupTool(config);
    await setupTool.setup();
  } catch (e) {
    print('❌ 设置失败: $e');
    exit(1);
  }
}

/// 显示帮助信息
void _showHelp() {
  print('''
⚡ 快速项目设置工具
==================

用法:
  dart run scripts/quick_setup.dart --name="应用名称" --package="包名" [选项]

必需参数:
  --name="应用名称"        应用显示名称
  --package="包名"         应用包名 (如: com.company.app)

可选参数:
  --description="描述"     应用描述
  --icon="图标路径"        应用图标文件路径
  --output="输出目录"      输出目录 (默认: 当前目录)

示例:
  dart run scripts/quick_setup.dart --name="我的应用" --package="com.mycompany.myapp"
  dart run scripts/quick_setup.dart --name="TodoApp" --package="com.example.todo" --description="任务管理应用" --icon="assets/icon.png"
''');
}

/// 解析命令行参数
Map<String, String> _parseArguments(List<String> arguments) {
  final config = <String, String>{};

  for (final arg in arguments) {
    if (arg.startsWith('--')) {
      final parts = arg.substring(2).split('=');
      if (parts.length == 2) {
        final key = parts[0];
        final value = parts[1].replaceAll('"', '').replaceAll("'", '');
        config[key] = value;
      }
    }
  }

  // 验证必需参数
  if (!config.containsKey('name') || config['name']!.isEmpty) {
    throw Exception('缺少必需参数: --name');
  }

  if (!config.containsKey('package') || config['package']!.isEmpty) {
    throw Exception('缺少必需参数: --package');
  }

  // 验证包名格式
  final packageRegex = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');
  if (!packageRegex.hasMatch(config['package']!)) {
    throw Exception('包名格式不正确: ${config['package']}');
  }

  // 设置默认值
  config['description'] ??= '基于Flutter Starter创建的${config['name']}应用';
  config['output'] ??= '.';

  return config;
}

/// 快速设置工具
class QuickSetupTool {
  final Map<String, String> config;

  QuickSetupTool(this.config);

  /// 执行设置
  Future<void> setup() async {
    print('⚡ 快速设置项目');
    print('=' * 50);
    print('应用名称: ${config['name']}');
    print('包名: ${config['package']}');
    print('描述: ${config['description']}');
    if (config.containsKey('icon')) {
      print('图标: ${config['icon']}');
    }
    if (config['output'] != '.') {
      print('输出目录: ${config['output']}');
    }
    print('');

    // 如果指定了输出目录，先复制项目
    if (config['output'] != '.') {
      await _copyProject();
    }

    // 应用配置
    await _applyConfiguration();

    print('');
    print('✅ 项目设置完成!');
    print('');
    print('🔄 建议执行以下命令:');
    if (config['output'] != '.') {
      print('   cd ${config['output']}');
    }
    print('   flutter clean');
    print('   flutter pub get');
    if (config.containsKey('icon')) {
      print('   flutter pub run icons_launcher:create');
    }
    print('   flutter run');
  }

  /// 复制项目到新目录
  Future<void> _copyProject() async {
    final outputDir = config['output']!;
    print('📂 复制项目到: $outputDir');

    final targetDir = Directory(outputDir);
    if (targetDir.existsSync()) {
      print('⚠️  目标目录已存在，将覆盖内容');
    } else {
      await targetDir.create(recursive: true);
    }

    // 复制文件和目录
    await _copyDirectory(
      Directory('.'),
      targetDir,
      excludes: {
        '.git',
        'build',
        '.dart_tool',
        'ios/Pods',
        'android/.gradle',
        '.idea',
        '.vscode',
        '*.iml',
        'pubspec.lock',
      },
    );

    // 切换工作目录
    Directory.current = targetDir.path;
    print('✅ 项目复制完成');
  }

  /// 应用配置
  Future<void> _applyConfiguration() async {
    print('🔧 应用配置...');

    // 更新 pubspec.yaml
    await _updatePubspec();

    // 更新 Android 配置
    await _updateAndroid();

    // 更新 iOS 配置 (如果存在)
    await _updateIOS();

    // 更新翻译文件
    await _updateI18n();

    // 更新图标 (如果指定)
    if (config.containsKey('icon')) {
      await _updateIcon();
    }

    print('✅ 配置应用完成');
  }

  /// 更新 pubspec.yaml
  Future<void> _updatePubspec() async {
    final file = File('pubspec.yaml');
    if (!file.existsSync()) return;

    var content = await file.readAsString();

    // 更新项目名称
    content = content.replaceFirst(
      RegExp(r'^name:.*$', multiLine: true),
      'name: ${_toSnakeCase(config['name']!)}',
    );

    // 更新描述
    content = content.replaceFirst(
      RegExp(r'^description:.*$', multiLine: true),
      'description: ${config['description']}',
    );

    await file.writeAsString(content);
    print('   📝 更新 pubspec.yaml');
  }

  /// 更新 Android 配置
  Future<void> _updateAndroid() async {
    // 更新 AndroidManifest.xml
    await _updateAndroidManifest();

    // 更新 build.gradle.kts
    await _updateBuildGradle();

    // 更新 MainActivity
    await _updateMainActivity();
  }

  /// 更新 AndroidManifest.xml
  Future<void> _updateAndroidManifest() async {
    final file = File('android/app/src/main/AndroidManifest.xml');
    if (!file.existsSync()) return;

    var content = await file.readAsString();

    // 更新包名
    content = content.replaceFirst(
      RegExp(r'package="[^"]*"'),
      'package="${config['package']}"',
    );

    // 更新应用标签
    content = content.replaceFirst(
      RegExp(r'android:label="[^"]*"'),
      'android:label="${config['name']}"',
    );

    await file.writeAsString(content);
    print('   📝 更新 AndroidManifest.xml');
  }

  /// 更新 build.gradle.kts
  Future<void> _updateBuildGradle() async {
    final file = File('android/app/build.gradle.kts');
    if (!file.existsSync()) return;

    var content = await file.readAsString();

    // 更新 applicationId
    content = content.replaceFirst(
      RegExp(r'applicationId\s*=\s*"[^"]*"'),
      'applicationId = "${config['package']}"',
    );

    await file.writeAsString(content);
    print('   📝 更新 build.gradle.kts');
  }

  /// 更新 MainActivity
  Future<void> _updateMainActivity() async {
    final oldPath =
        'android/app/src/main/kotlin/com/example/flutter_starter/MainActivity.kt';
    final newPath =
        'android/app/src/main/kotlin/${config['package']!.replaceAll('.', '/')}/MainActivity.kt';

    final oldFile = File(oldPath);
    if (!oldFile.existsSync()) return;

    // 创建新目录
    final newFile = File(newPath);
    await newFile.parent.create(recursive: true);

    // 更新内容
    var content = await oldFile.readAsString();
    content = content.replaceFirst(
      RegExp(r'package\s+[^\s]+'),
      'package ${config['package']}',
    );

    await newFile.writeAsString(content);
    await oldFile.delete();

    // 清理空目录
    await _cleanupEmptyDirs(Directory('android/app/src/main/kotlin/com'));

    print('   📝 更新 MainActivity');
  }

  /// 更新 iOS 配置
  Future<void> _updateIOS() async {
    final infoPlist = File('ios/Runner/Info.plist');
    if (!infoPlist.existsSync()) return;

    var content = await infoPlist.readAsString();

    // 更新 Bundle Identifier
    content = content.replaceFirst(
      RegExp(r'<key>CFBundleIdentifier</key>\s*<string>[^<]*</string>'),
      '<key>CFBundleIdentifier</key>\n\t<string>${config['package']}</string>',
    );

    // 更新显示名称
    if (content.contains('CFBundleDisplayName')) {
      content = content.replaceFirst(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleDisplayName</key>\n\t<string>${config['name']}</string>',
      );
    } else {
      content = content.replaceFirst(
        '<key>CFBundleName</key>',
        '<key>CFBundleDisplayName</key>\n\t<string>${config['name']}</string>\n\t<key>CFBundleName</key>',
      );
    }

    await infoPlist.writeAsString(content);
    print('   📝 更新 iOS Info.plist');

    // 更新 project.pbxproj
    final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
    if (pbxproj.existsSync()) {
      var pbxContent = await pbxproj.readAsString();
      pbxContent = pbxContent.replaceAll(
        RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[^;]+;'),
        'PRODUCT_BUNDLE_IDENTIFIER = ${config['package']};',
      );
      await pbxproj.writeAsString(pbxContent);
      print('   📝 更新 project.pbxproj');
    }
  }

  /// 更新翻译文件
  Future<void> _updateI18n() async {
    final file = File('lib/common/i18n/messages.dart');
    if (!file.existsSync()) return;

    var content = await file.readAsString();

    // 更新应用名称翻译
    content = content.replaceFirst(
      RegExp(r"'app_name':\s*'[^']*'"),
      "'app_name': '${config['name']}'",
    );

    await file.writeAsString(content);
    print('   📝 更新翻译文件');
  }

  /// 更新图标
  Future<void> _updateIcon() async {
    final iconPath = config['icon']!;
    final iconFile = File(iconPath);

    if (!iconFile.existsSync()) {
      print('   ⚠️  图标文件不存在: $iconPath');
      return;
    }

    // 创建目标目录
    final targetDir = Directory('assets/icon');
    await targetDir.create(recursive: true);

    // 复制图标
    final targetIcon = File('assets/icon/app_icon.png');
    await iconFile.copy(targetIcon.path);

    // 更新 pubspec.yaml 添加图标配置
    final pubspecFile = File('pubspec.yaml');
    var content = await pubspecFile.readAsString();

    if (!content.contains('icons_launcher:')) {
      final iconConfig = '''

icons_launcher:
  image_path: "assets/icon/app_icon.png"
  platforms:
    android:
      enable: true
    ios:
      enable: true
''';

      // 在 dev_dependencies 前添加配置
      final devDepIndex = content.indexOf('dev_dependencies:');
      if (devDepIndex != -1) {
        content =
            content.substring(0, devDepIndex) +
            iconConfig +
            '\n' +
            content.substring(devDepIndex);
        await pubspecFile.writeAsString(content);
      }
    }

    print('   📝 设置应用图标');
  }

  /// 复制目录
  Future<void> _copyDirectory(
    Directory source,
    Directory destination, {
    Set<String>? excludes,
  }) async {
    excludes ??= {};

    await for (final entity in source.list()) {
      final name = entity.path.split(Platform.pathSeparator).last;

      // 检查排除列表
      if (excludes.any(
        (exclude) => exclude.contains('*')
            ? name.endsWith(exclude.replaceAll('*', ''))
            : name == exclude,
      )) {
        continue;
      }

      if (entity is Directory) {
        final newDirectory = Directory(
          '${destination.path}${Platform.pathSeparator}$name',
        );
        await newDirectory.create();
        await _copyDirectory(entity, newDirectory, excludes: excludes);
      } else if (entity is File) {
        final newFile = File(
          '${destination.path}${Platform.pathSeparator}$name',
        );
        await entity.copy(newFile.path);
      }
    }
  }

  /// 清理空目录
  Future<void> _cleanupEmptyDirs(Directory dir) async {
    if (!dir.existsSync()) return;

    try {
      final entities = dir.listSync();
      if (entities.isEmpty) {
        await dir.delete();
        await _cleanupEmptyDirs(dir.parent);
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 转换为 snake_case
  String _toSnakeCase(String input) {
    return input
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
