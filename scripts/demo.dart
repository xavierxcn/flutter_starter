import 'dart:io';

/// 演示脚本
/// 使用方法: dart run scripts/demo.dart
/// 演示脚手架的各种功能
void main() {
  print('🎉 Flutter Starter 脚手架演示');
  print('==============================\n');

  print('📱 当前项目结构:');
  _showProjectStructure();

  print('\n🛠️  可用的代码生成工具:');
  _showGenerators();

  print('\n📝 使用示例:');
  _showExamples();

  print('\n✨ 项目特色:');
  _showFeatures();

  print('\n🚀 开始开发:');
  print('1. flutter pub get          # 安装依赖');
  print('2. flutter run              # 运行项目');
  print('3. 使用生成脚本创建新页面和服务');
  print('4. 享受高效的开发体验！');
}

/// 显示项目结构
void _showProjectStructure() {
  print('''
lib/
├── common/              # 公共模块
│   ├── api/            # API接口
│   ├── models/         # 数据模型
│   ├── services/       # 服务层
│   ├── routers/        # 路由管理
│   └── ...
├── pages/              # 页面模块
│   └── home/          # 首页示例
└── global.dart        # 全局配置

scripts/               # 代码生成脚本
├── generate_page.dart
├── generate_service.dart
├── scan_routes.dart
├── revert.dart
├── history_manager.dart
└── demo.dart

templates/             # 代码模板
├── page/             # 页面模板
└── service/          # 服务模板
''');
}

/// 显示生成器
void _showGenerators() {
  print('1. 📄 页面生成器');
  print('   dart run scripts/generate_page.dart user_profile');
  print('   → 生成完整的MVC页面结构\n');

  print('2. 🔧 服务生成器');
  print('   dart run scripts/generate_service.dart user_service');
  print('   → 生成Service + Model + API\n');

  print('3. 🗺️  路由扫描器');
  print('   dart run scripts/scan_routes.dart');
  print('   → 自动更新路由配置');
  print('');
  print('4. ↩️  操作撤回器');
  print('   dart run scripts/revert.dart');
  print('   → 撤回错误的生成操作');
  print('');
  print('5. 🌐 国际化管理器');
  print('   dart run scripts/i18n_manager.dart --check');
  print('   → 检查和管理多语言翻译');
  print('');
  print('6. ⚙️  项目配置器');
  print('   dart run scripts/configure_project.dart');
  print('   → 配置应用名称、包名和图标');
  print('');
  print('7. 📋 项目克隆器');
  print('   dart run scripts/clone_project.dart my_app');
  print('   → 创建干净的项目副本');
}

/// 显示使用示例
void _showExamples() {
  print('🔹 创建用户管理页面:');
  print('   dart run scripts/generate_page.dart user_management user');
  print('');

  print('🔹 创建商品服务:');
  print('   dart run scripts/generate_service.dart product_service');
  print('');

  print('🔹 扫描并更新所有路由:');
  print('   dart run scripts/scan_routes.dart');
  print('');

  print('🔹 撤回错误操作:');
  print('   dart run scripts/revert.dart');
  print('   dart run scripts/revert.dart --list');
  print('');

  print('🔹 管理多语言翻译:');
  print('   dart run scripts/i18n_manager.dart --check');
  print('   dart run scripts/add_translation.dart "new_key" "中文" "English"');
  print('');

  print('🔹 配置新项目:');
  print('   dart run scripts/clone_project.dart my_app');
  print('   dart run scripts/configure_project.dart');
  print(
    '   dart run scripts/quick_setup.dart --name="应用" --package="com.company.app"',
  );
  print('');

  print('🔹 页面导航示例:');
  print('   Get.toNamed(RouteNames.userManagement);');
  print('');

  print('🔹 服务调用示例:');
  print('   final products = await ProductService.to.getList();');
}

/// 显示项目特色
void _showFeatures() {
  print('✅ GetX状态管理 - 响应式编程');
  print('✅ 完整的MVC架构 - 代码分层清晰');
  print('✅ 自动路由管理 - 无需手动配置');
  print('✅ HTTP服务封装 - 统一的网络请求');
  print('✅ 本地存储服务 - 数据持久化');
  print('✅ 代码自动生成 - 提升开发效率');
  print('✅ 模块化设计 - 易于维护扩展');
  print('✅ Material Design 3 - 现代UI设计');
  print('✅ 模板分离设计 - 易于自定义模板');
  print('✅ 最小化脚手架 - 快速上手开发');
  print('✅ 国际化支持 - 完整的多语言方案');
  print('✅ 项目配置工具 - 一键修改应用信息');
  print('✅ 项目克隆功能 - 快速创建新项目');
}
