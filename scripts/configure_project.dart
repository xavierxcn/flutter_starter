import 'dart:io';

/// 项目配置脚本
/// 使用方法: dart run scripts/configure_project.dart
/// 交互式配置应用名称、包名和图标
void main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _showHelp();
    return;
  }

  print('🚀 Flutter项目配置向导');
  print('=' * 50);
  print('');

  final configurator = ProjectConfigurator();
  await configurator.configure();
}

/// 显示帮助信息
void _showHelp() {
  print('''
🚀 Flutter项目配置向导
=====================

这是一个交互式的项目配置工具，用于快速修改应用的基本信息。

用法:
  dart run scripts/configure_project.dart

功能:
  - 修改应用名称
  - 修改包名（applicationId/Bundle ID）
  - 修改应用描述
  - 设置应用图标

注意:
  - 此脚本会直接修改当前项目的配置文件
  - 建议在修改前备份项目或使用版本控制
  - 如需创建新项目副本，请使用 clone_project.dart

示例流程:
  1. dart run scripts/configure_project.dart
  2. 按提示输入应用信息
  3. 确认配置并等待完成
  4. flutter clean && flutter pub get
  5. flutter run

相关脚本:
  dart run scripts/clone_project.dart my_app     # 克隆项目副本
  dart run scripts/quick_setup.dart --help       # 非交互式配置
''');
}

/// 项目配置器
class ProjectConfigurator {
  late String appName;
  late String packageName;
  late String appDescription;
  String? iconPath;

  /// 开始配置
  Future<void> configure() async {
    try {
      // 收集配置信息
      await _collectInformation();

      // 确认配置
      if (await _confirmConfiguration()) {
        print('\n🔧 开始配置项目...\n');

        // 执行配置
        await _updateProjectName();
        await _updatePackageName();
        await _updateAppDescription();

        if (iconPath != null) {
          await _updateAppIcon();
        }

        print('\n✅ 项目配置完成!');
        print('');
        print('📋 配置摘要:');
        print('   应用名称: $appName');
        print('   包名: $packageName');
        print('   描述: $appDescription');
        if (iconPath != null) {
          print('   图标: $iconPath');
        }
        print('');
        print('🔄 建议执行以下命令来清理和重新构建:');
        print('   flutter clean');
        print('   flutter pub get');
        print('   flutter run');
      } else {
        print('❌ 配置已取消');
      }
    } catch (e) {
      print('❌ 配置失败: $e');
      exit(1);
    }
  }

  /// 收集配置信息
  Future<void> _collectInformation() async {
    // 应用名称
    stdout.write('📱 请输入应用名称 (例如: 我的应用): ');
    appName = stdin.readLineSync()?.trim() ?? '';
    if (appName.isEmpty) {
      throw Exception('应用名称不能为空');
    }

    // 包名
    stdout.write('📦 请输入包名 (例如: com.mycompany.myapp): ');
    packageName = stdin.readLineSync()?.trim() ?? '';
    if (packageName.isEmpty || !_isValidPackageName(packageName)) {
      throw Exception('包名格式不正确，应该类似: com.company.appname');
    }

    // 应用描述
    stdout.write('📝 请输入应用描述 (可选): ');
    appDescription = stdin.readLineSync()?.trim() ?? '基于Flutter Starter创建的应用';

    // 应用图标
    stdout.write('🎨 请输入图标路径 (可选，留空跳过): ');
    final iconInput = stdin.readLineSync()?.trim();
    if (iconInput != null && iconInput.isNotEmpty) {
      final iconFile = File(iconInput);
      if (iconFile.existsSync()) {
        iconPath = iconInput;
      } else {
        print('⚠️  图标文件不存在，将跳过图标设置');
      }
    }
  }

  /// 确认配置
  Future<bool> _confirmConfiguration() async {
    print('\n📋 请确认配置信息:');
    print('   应用名称: $appName');
    print('   包名: $packageName');
    print('   描述: $appDescription');
    if (iconPath != null) {
      print('   图标: $iconPath');
    }
    print('');
    stdout.write('确认配置并继续? (y/N): ');
    final input = stdin.readLineSync()?.toLowerCase();
    return input == 'y' || input == 'yes';
  }

  /// 更新项目名称
  Future<void> _updateProjectName() async {
    print('📝 更新项目名称...');

    // 更新 pubspec.yaml
    await _updatePubspecYaml();

    // 更新 Android 配置
    await _updateAndroidAppName();

    // 更新 iOS 配置
    await _updateIOSAppName();

    // 更新翻译文件中的app_name
    await _updateI18nAppName();

    print('✅ 项目名称更新完成');
  }

  /// 更新包名
  Future<void> _updatePackageName() async {
    print('📦 更新包名...');

    // 更新 Android 包名
    await _updateAndroidPackageName();

    // 更新 iOS Bundle ID
    await _updateIOSBundleId();

    print('✅ 包名更新完成');
  }

  /// 更新应用描述
  Future<void> _updateAppDescription() async {
    print('📝 更新应用描述...');

    // 更新 pubspec.yaml 中的描述
    await _updateFile('pubspec.yaml', (content) {
      return content.replaceFirst(
        RegExp(r'^description:.*$', multiLine: true),
        'description: $appDescription',
      );
    });

    print('✅ 应用描述更新完成');
  }

  /// 更新应用图标
  Future<void> _updateAppIcon() async {
    print('🎨 更新应用图标...');

    try {
      // 复制图标到合适的位置
      final sourceIcon = File(iconPath!);
      final targetIcon = File('assets/icon/app_icon.png');

      // 创建目录
      await targetIcon.parent.create(recursive: true);

      // 复制文件
      await sourceIcon.copy(targetIcon.path);

      // 更新 pubspec.yaml 添加 icons_launcher 配置
      await _updatePubspecForIcon();

      print('✅ 应用图标更新完成');
      print('📝 请运行以下命令生成图标:');
      print('   flutter pub get');
      print('   flutter pub run icons_launcher:create');
    } catch (e) {
      print('⚠️  图标更新失败: $e');
    }
  }

  /// 更新 pubspec.yaml
  Future<void> _updatePubspecYaml() async {
    await _updateFile('pubspec.yaml', (content) {
      // 更新项目名称
      content = content.replaceFirst(
        RegExp(r'^name:.*$', multiLine: true),
        'name: ${_toSnakeCase(appName)}',
      );

      return content;
    });
  }

  /// 更新 Android 应用名称
  Future<void> _updateAndroidAppName() async {
    final manifestFile = 'android/app/src/main/AndroidManifest.xml';
    await _updateFile(manifestFile, (content) {
      return content.replaceFirst(
        RegExp(r'android:label="[^"]*"'),
        'android:label="$appName"',
      );
    });
  }

  /// 更新 iOS 应用名称
  Future<void> _updateIOSAppName() async {
    final infoPlistFile = 'ios/Runner/Info.plist';
    if (File(infoPlistFile).existsSync()) {
      await _updateFile(infoPlistFile, (content) {
        // 更新 CFBundleDisplayName
        content = content.replaceFirst(
          RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleDisplayName</key>\n\t<string>$appName</string>',
        );

        // 如果没有 CFBundleDisplayName，添加它
        if (!content.contains('CFBundleDisplayName')) {
          content = content.replaceFirst(
            '<key>CFBundleName</key>',
            '<key>CFBundleDisplayName</key>\n\t<string>$appName</string>\n\t<key>CFBundleName</key>',
          );
        }

        return content;
      });
    }
  }

  /// 更新翻译文件中的应用名称
  Future<void> _updateI18nAppName() async {
    final messagesFile = 'lib/common/i18n/messages.dart';
    await _updateFile(messagesFile, (content) {
      // 更新中文应用名称
      content = content.replaceFirst(
        RegExp(r"'app_name':\s*'[^']*'"),
        "'app_name': '$appName'",
      );

      return content;
    });
  }

  /// 更新 Android 包名
  Future<void> _updateAndroidPackageName() async {
    // 更新 build.gradle.kts
    final buildGradleFile = 'android/app/build.gradle.kts';
    await _updateFile(buildGradleFile, (content) {
      return content.replaceFirst(
        RegExp(r'applicationId\s*=\s*"[^"]*"'),
        'applicationId = "$packageName"',
      );
    });

    // 更新 AndroidManifest.xml
    final manifestFile = 'android/app/src/main/AndroidManifest.xml';
    await _updateFile(manifestFile, (content) {
      return content.replaceFirst(
        RegExp(r'package="[^"]*"'),
        'package="$packageName"',
      );
    });

    // 更新 MainActivity 文件
    await _updateMainActivity();
  }

  /// 更新 MainActivity
  Future<void> _updateMainActivity() async {
    final mainActivityPath =
        'android/app/src/main/kotlin/${packageName.replaceAll('.', '/')}/MainActivity.kt';
    final currentMainActivity =
        'android/app/src/main/kotlin/com/example/flutter_starter/MainActivity.kt';

    if (File(currentMainActivity).existsSync()) {
      // 创建新的目录结构
      final newDir = Directory(mainActivityPath).parent;
      await newDir.create(recursive: true);

      // 更新文件内容并移动
      final content = await File(currentMainActivity).readAsString();
      final newContent = content.replaceFirst(
        RegExp(r'package\s+[^\s]+'),
        'package $packageName',
      );

      await File(mainActivityPath).writeAsString(newContent);

      // 删除旧文件和空目录
      await File(currentMainActivity).delete();
      await _cleanupEmptyDirectories(
        Directory('android/app/src/main/kotlin/com'),
      );
    }
  }

  /// 更新 iOS Bundle ID
  Future<void> _updateIOSBundleId() async {
    final infoPlistFile = 'ios/Runner/Info.plist';
    if (File(infoPlistFile).existsSync()) {
      await _updateFile(infoPlistFile, (content) {
        return content.replaceFirst(
          RegExp(r'<key>CFBundleIdentifier</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleIdentifier</key>\n\t<string>$packageName</string>',
        );
      });
    }

    // 更新 project.pbxproj
    final pbxprojFile = 'ios/Runner.xcodeproj/project.pbxproj';
    if (File(pbxprojFile).existsSync()) {
      await _updateFile(pbxprojFile, (content) {
        return content.replaceAll(
          RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[^;]+;'),
          'PRODUCT_BUNDLE_IDENTIFIER = $packageName;',
        );
      });
    }
  }

  /// 更新 pubspec.yaml 添加图标配置
  Future<void> _updatePubspecForIcon() async {
    await _updateFile('pubspec.yaml', (content) {
      // 检查是否已经有 icons_launcher 配置
      if (!content.contains('icons_launcher:')) {
        // 在 dev_dependencies 之后添加图标配置
        final insertPosition = content.indexOf('flutter_test:');
        if (insertPosition != -1) {
          final beforeInsert = content.substring(0, insertPosition);
          final afterInsert = content.substring(insertPosition);

          final iconConfig = '''
  icons_launcher:
    image_path: "assets/icon/app_icon.png"
    platforms:
      android:
        enable: true
      ios:
        enable: true
  ''';

          content = beforeInsert + iconConfig + afterInsert;
        }
      }

      return content;
    });
  }

  /// 通用文件更新方法
  Future<void> _updateFile(
    String filePath,
    String Function(String) updater,
  ) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  文件不存在: $filePath');
      return;
    }

    try {
      final content = await file.readAsString();
      final newContent = updater(content);
      await file.writeAsString(newContent);
      print('   📝 已更新: $filePath');
    } catch (e) {
      print('   ❌ 更新失败: $filePath - $e');
    }
  }

  /// 清理空目录
  Future<void> _cleanupEmptyDirectories(Directory dir) async {
    if (!dir.existsSync()) return;

    try {
      final entities = dir.listSync();
      if (entities.isEmpty) {
        await dir.delete();
        // 递归清理父目录
        await _cleanupEmptyDirectories(dir.parent);
      }
    } catch (e) {
      // 忽略删除失败的情况
    }
  }

  /// 验证包名格式
  bool _isValidPackageName(String packageName) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');
    return regex.hasMatch(packageName);
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
