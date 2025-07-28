import 'dart:io';

/// 项目克隆脚本
/// 使用方法: dart run scripts/clone_project.dart <目标目录>
/// 例如: dart run scripts/clone_project.dart my_new_app
void main(List<String> arguments) async {
  if (arguments.isEmpty ||
      arguments.contains('--help') ||
      arguments.contains('-h')) {
    _showHelp();
    return;
  }

  final targetPath = arguments[0];
  final cloner = ProjectCloner(targetPath);

  try {
    await cloner.clone();
  } catch (e) {
    print('❌ 克隆失败: $e');
    exit(1);
  }
}

/// 显示帮助信息
void _showHelp() {
  print('''
📋 项目克隆工具
===============

用法:
  dart run scripts/clone_project.dart <目标目录>

参数:
  目标目录    新项目的目录名称

示例:
  dart run scripts/clone_project.dart my_new_app
  dart run scripts/clone_project.dart ../todo_app

注意:
  - 将创建干净的项目副本，排除build文件和IDE配置
  - 克隆后可使用配置脚本修改项目信息
''');
}

/// 项目克隆器
class ProjectCloner {
  final String targetPath;

  ProjectCloner(this.targetPath);

  /// 执行克隆
  Future<void> clone() async {
    print('📋 Flutter项目克隆工具');
    print('=' * 40);
    print('源目录: ${Directory.current.path}');
    print('目标目录: $targetPath');
    print('');

    // 检查目标目录
    await _checkTargetDirectory();

    // 执行克隆
    await _performClone();

    print('');
    print('✅ 项目克隆完成!');
    print('');
    print('🔄 接下来的步骤:');
    print('1. cd $targetPath');
    print('2. dart run scripts/configure_project.dart  # 配置项目信息');
    print('3. flutter pub get');
    print('4. flutter run');
    print('');
    print('💡 或者使用快速设置:');
    print('   cd $targetPath');
    print(
      '   dart run scripts/quick_setup.dart --name="应用名" --package="com.company.app"',
    );
  }

  /// 检查目标目录
  Future<void> _checkTargetDirectory() async {
    final targetDir = Directory(targetPath);

    if (targetDir.existsSync()) {
      print('⚠️  目标目录已存在: $targetPath');
      stdout.write('是否覆盖? (y/N): ');
      final input = stdin.readLineSync()?.toLowerCase();

      if (input != 'y' && input != 'yes') {
        print('❌ 操作已取消');
        exit(0);
      }

      // 删除现有目录
      print('🗑️  删除现有目录...');
      await targetDir.delete(recursive: true);
    }

    // 创建目标目录
    await targetDir.create(recursive: true);
  }

  /// 执行克隆
  Future<void> _performClone() async {
    print('📂 开始克隆项目...');

    final sourceDir = Directory.current;
    final targetDir = Directory(targetPath);

    // 定义排除列表
    final excludes = {
      '.git', // Git 仓库
      '.dart_tool', // Dart 工具文件
      'build', // 构建输出
      'ios/Pods', // iOS Pods
      'android/.gradle', // Android Gradle 缓存
      '.idea', // IntelliJ IDEA
      '.vscode', // Visual Studio Code
      '*.iml', // IntelliJ 模块文件
      'pubspec.lock', // 包锁定文件
      '.flutter-plugins', // Flutter 插件
      '.flutter-plugins-dependencies', // Flutter 插件依赖
      '.packages', // 包配置（已废弃）
      '.metadata', // Flutter 元数据
      'ios/Runner.xcworkspace/xcuserdata', // Xcode 用户数据
      'ios/Runner.xcodeproj/xcuserdata', // Xcode 用户数据
      'android/.gradle', // Android Gradle
      'android/app/build', // Android 构建输出
      'android/build', // Android 构建输出
      '.generator_history.json', // 生成器历史记录
    };

    await _copyDirectory(sourceDir, targetDir, excludes: excludes);

    print('✅ 文件克隆完成');

    // 创建干净的状态文件
    await _createCleanState(targetDir);
  }

  /// 创建干净的状态
  Future<void> _createCleanState(Directory targetDir) async {
    // 创建 .gitignore（如果不存在）
    final gitignoreFile = File('${targetDir.path}/.gitignore');
    if (!gitignoreFile.existsSync()) {
      const gitignoreContent = '''
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Web related
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# Generator history
.generator_history.json
''';
      await gitignoreFile.writeAsString(gitignoreContent);
      print('   📝 创建 .gitignore');
    }

    // 创建 README（如果是新项目）
    final readmeFile = File('${targetDir.path}/README_NEW_PROJECT.md');
    const readmeContent = '''
# 新Flutter项目

这是一个基于Flutter Starter脚手架创建的项目。

## 快速开始

1. **配置项目信息**
   ```bash
   dart run scripts/configure_project.dart
   ```
   或使用快速设置:
   ```bash
   dart run scripts/quick_setup.dart --name="应用名" --package="com.company.app"
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行项目**
   ```bash
   flutter run
   ```

## 项目特性

- ✅ GetX状态管理
- ✅ 完整的MVC架构
- ✅ 国际化支持
- ✅ 代码生成工具
- ✅ 操作撤回功能
- ✅ 项目配置工具

## 代码生成工具

```bash
# 生成页面
dart run scripts/generate_page.dart my_page

# 生成服务
dart run scripts/generate_service.dart my_service

# 管理翻译
dart run scripts/i18n_manager.dart --check

# 查看所有工具
dart run scripts/demo.dart
```

更多信息请查看 [README.md](README.md)
''';
    await readmeFile.writeAsString(readmeContent);
    print('   📝 创建新项目说明');
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
      bool shouldExclude = false;
      for (final exclude in excludes) {
        if (exclude.contains('*')) {
          // 通配符匹配
          final pattern = exclude.replaceAll('*', '');
          if (name.contains(pattern)) {
            shouldExclude = true;
            break;
          }
        } else if (exclude.contains('/')) {
          // 路径匹配
          final relativePath = entity.path.substring(source.path.length + 1);
          if (relativePath.startsWith(exclude)) {
            shouldExclude = true;
            break;
          }
        } else {
          // 文件名匹配
          if (name == exclude) {
            shouldExclude = true;
            break;
          }
        }
      }

      if (shouldExclude) {
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
}
