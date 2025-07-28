import 'dart:io';

/// 路由扫描脚本
/// 使用方法: dart run scripts/scan_routes.dart
/// 扫描lib/pages目录下的所有页面，并自动更新路由配置
void main() {
  final scanner = RouteScanner();
  scanner.scan();
}

/// 路由扫描器
class RouteScanner {
  final List<PageInfo> pages = [];

  /// 扫描页面并更新路由
  void scan() {
    print('🔍 扫描页面文件...');

    _scanPagesDirectory();

    if (pages.isEmpty) {
      print('❌ 未找到任何页面文件');
      return;
    }

    print('📋 找到 ${pages.length} 个页面:');
    for (final page in pages) {
      print('  - ${page.className} (${page.path})');
    }

    print('\n📝 更新路由配置文件...');
    _updateRouteNames();
    _updateRoutePages();
    _updatePagesIndex();

    print('✅ 路由扫描完成！');
  }

  /// 扫描pages目录
  void _scanPagesDirectory() {
    final pagesDir = Directory('lib/pages');
    if (!pagesDir.existsSync()) {
      print('❌ lib/pages 目录不存在');
      return;
    }

    _scanDirectory(pagesDir);
  }

  /// 递归扫描目录
  void _scanDirectory(Directory dir) {
    final entities = dir.listSync();

    for (final entity in entities) {
      if (entity is Directory) {
        // 检查是否包含view.dart文件（页面标识）
        final viewFile = File('${entity.path}/view.dart');
        if (viewFile.existsSync()) {
          _processPageDirectory(entity);
        } else {
          // 递归扫描子目录
          _scanDirectory(entity);
        }
      }
    }
  }

  /// 处理页面目录
  void _processPageDirectory(Directory pageDir) {
    final viewFile = File('${pageDir.path}/view.dart');
    if (!viewFile.existsSync()) return;

    try {
      final content = viewFile.readAsStringSync();
      final className = _extractClassName(content);

      if (className != null) {
        final pagePath = pageDir.path
            .replaceAll('lib/pages/', '')
            .replaceAll('\\', '/');
        final pageName = _getPageName(pagePath);
        final routeName = _toRouteFormat(pageName);

        pages.add(
          PageInfo(
            className: className,
            path: pagePath,
            pageName: pageName,
            routeName: routeName,
          ),
        );
      }
    } catch (e) {
      print('⚠️  处理页面文件失败: ${pageDir.path} - $e');
    }
  }

  /// 从view.dart内容中提取类名
  String? _extractClassName(String content) {
    final classPattern = RegExp(r'class\s+(\w+Page)\s+extends\s+GetView');
    final match = classPattern.firstMatch(content);
    return match?.group(1);
  }

  /// 获取页面名称
  String _getPageName(String pagePath) {
    final parts = pagePath.split('/');
    return parts.last;
  }

  /// 转换为路由格式
  String _toRouteFormat(String pageName) {
    return pageName.replaceAll('_', '-');
  }

  /// 更新路由名称文件
  void _updateRouteNames() {
    final namesFile = File('lib/common/routers/names.dart');
    if (!namesFile.existsSync()) {
      print('❌ lib/common/routers/names.dart 不存在');
      return;
    }

    var content = namesFile.readAsStringSync();

    // 找到类的结束位置
    final classEndPattern = RegExp(r'}\s*$');
    final classEndMatch = classEndPattern.firstMatch(content);

    if (classEndMatch == null) {
      print('❌ 无法找到RouteNames类的结束位置');
      return;
    }

    final insertPosition = classEndMatch.start;
    var newRoutes = '';

    for (final page in pages) {
      final routeVarName = _toCamelCase(page.pageName);
      final routePath = '/${page.routeName}';

      // 检查是否已存在
      if (!content.contains('static const String $routeVarName =')) {
        newRoutes += '  \n  /// ${page.className.replaceAll('Page', '')}\n';
        newRoutes += '  static const String $routeVarName = \'$routePath\';\n';
      }
    }

    if (newRoutes.isNotEmpty) {
      content =
          content.substring(0, insertPosition) +
          newRoutes +
          content.substring(insertPosition);
      namesFile.writeAsStringSync(content);
      print('📝 更新了 RouteNames');
    } else {
      print('ℹ️  RouteNames 无需更新');
    }
  }

  /// 更新路由页面文件
  void _updateRoutePages() {
    final pagesFile = File('lib/common/routers/pages.dart');
    if (!pagesFile.existsSync()) {
      print('❌ lib/common/routers/pages.dart 不存在');
      return;
    }

    var content = pagesFile.readAsStringSync();

    // 找到路由列表的结束位置
    final listEndPattern = RegExp(
      r'static\s+List<GetPage>\s+list\s*=\s*\[(.*?)\];',
      dotAll: true,
    );
    final listMatch = listEndPattern.firstMatch(content);

    if (listMatch == null) {
      print('❌ 无法找到路由列表');
      return;
    }

    final listContent = listMatch.group(1)!;
    var newRoutes = listContent;

    for (final page in pages) {
      final routeVarName = _toCamelCase(page.pageName);

      // 检查是否已存在
      if (!content.contains('RouteNames.$routeVarName')) {
        if (!newRoutes.trim().endsWith(',')) {
          newRoutes += ',';
        }
        newRoutes +=
            '''
    GetPage(
      name: RouteNames.$routeVarName,
      page: () => const ${page.className}(),
    ),''';
      }
    }

    if (newRoutes != listContent) {
      final newListContent = 'static List<GetPage> list = [$newRoutes\n  ];';
      content = content.replaceFirst(listMatch.group(0)!, newListContent);
      pagesFile.writeAsStringSync(content);
      print('📝 更新了 RoutePages');
    } else {
      print('ℹ️  RoutePages 无需更新');
    }
  }

  /// 更新pages/index.dart
  void _updatePagesIndex() {
    final indexFile = File('lib/pages/index.dart');
    if (!indexFile.existsSync()) {
      print('❌ lib/pages/index.dart 不存在');
      return;
    }

    var content = indexFile.readAsStringSync();
    var hasUpdates = false;

    for (final page in pages) {
      final exportPath = '${page.path}/index.dart';
      final exportStatement = "export '$exportPath';";

      if (!content.contains(exportStatement)) {
        content += '\n$exportStatement';
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      indexFile.writeAsStringSync(content);
      print('📝 更新了 pages/index.dart');
    } else {
      print('ℹ️  pages/index.dart 无需更新');
    }
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
}

/// 页面信息
class PageInfo {
  final String className;
  final String path;
  final String pageName;
  final String routeName;

  PageInfo({
    required this.className,
    required this.path,
    required this.pageName,
    required this.routeName,
  });
}
