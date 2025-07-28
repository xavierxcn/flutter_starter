import 'package:get/get.dart';

/// GetX翻译类
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    // 中文简体
    'zh_CN': {
      // 通用
      'app_name': 'flutter_starter',
      'confirm': '确认',
      'cancel': '取消',
      'ok': '好的',
      'yes': '是',
      'no': '否',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'add': '添加',
      'loading': '加载中...',
      'success': '成功',
      'error': '错误',
      'warning': '警告',
      'info': '提示',
      'retry': '重试',
      'refresh': '刷新',
      'search': '搜索',
      'filter': '筛选',
      'sort': '排序',
      'more': '更多',
      'back': '返回',
      'next': '下一步',
      'previous': '上一步',
      'finish': '完成',
      'close': '关闭',

      // 首页
      'home_title': 'Flutter Starter',
      'home_welcome': '欢迎使用Flutter脚手架项目！',
      'home_description': '这是一个功能完整的Flutter项目模板，集成了GetX状态管理、完善的项目结构和代码生成工具。',
      'home_counter': '计数器值',
      'home_increment': '点击增加',
      'home_features_title': '项目特性',
      'home_quick_start_title': '快速开始',
      'home_settings': '设置',
      'home_language': '语言设置',

      // 特性描述
      'feature_getx': 'GetX状态管理',
      'feature_getx_desc': '响应式编程和状态管理',
      'feature_mvc': 'MVC架构',
      'feature_mvc_desc': '清晰的代码分层结构',
      'feature_router': '路由管理',
      'feature_router_desc': '统一的路由名称和页面管理',
      'feature_generator': '代码生成',
      'feature_generator_desc': '自动生成页面、服务和模型',
      'feature_http': 'HTTP服务',
      'feature_http_desc': '集成Dio的网络请求',
      'feature_storage': '本地存储',
      'feature_storage_desc': 'SharedPreferences封装',
      'feature_i18n': '国际化',
      'feature_i18n_desc': '多语言支持',
      'feature_revert': '操作撤回',
      'feature_revert_desc': '支持撤回错误的生成操作',

      // 代码生成相关
      'generate_page': '生成新页面',
      'generate_page_cmd': 'dart run scripts/generate_page.dart my_page',
      'generate_page_desc': '创建完整的MVC页面结构',
      'generate_service': '生成服务模块',
      'generate_service_cmd':
          'dart run scripts/generate_service.dart my_service',
      'generate_service_desc': '生成Service + Model + API',
      'scan_routes': '扫描路由',
      'scan_routes_cmd': 'dart run scripts/scan_routes.dart',
      'scan_routes_desc': '自动更新路由配置',
      'revert_operation': '撤回操作',
      'revert_operation_cmd': 'dart run scripts/revert.dart',
      'revert_operation_desc': '撤回错误的生成操作',

      // 设置相关
      'settings_title': '设置',
      'settings_language': '语言',
      'settings_theme': '主题',
      'settings_about': '关于',
      'language_changed': '语言已切换',
      'theme_light': '浅色主题',
      'theme_dark': '深色主题',
      'theme_system': '跟随系统',

      // 错误信息
      'error_network': '网络连接错误',
      'error_timeout': '请求超时',
      'error_server': '服务器错误',
      'error_unknown': '未知错误',
      'error_file_not_found': '文件未找到',
      'error_permission_denied': '权限被拒绝',

      // 验证信息
      'validation_required': '此字段为必填项',
      'validation_email': '请输入有效的邮箱地址',
      'validation_phone': '请输入有效的手机号码',
      'validation_password': '密码长度至少6位',
      'validation_confirm_password': '两次输入的密码不一致',
    
      'test_key': '测试翻译',
      },

    // 英文
    'en_US': {
      // Common
      'app_name': 'Flutter Starter',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'loading': 'Loading...',
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'info': 'Info',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'more': 'More',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'finish': 'Finish',
      'close': 'Close',

      // Home
      'home_title': 'Flutter Starter',
      'home_welcome': 'Welcome to Flutter Starter!',
      'home_description':
          'A comprehensive Flutter project template with GetX state management, well-structured architecture, and code generation tools.',
      'home_counter': 'Counter Value',
      'home_increment': 'Tap to Increment',
      'home_features_title': 'Features',
      'home_quick_start_title': 'Quick Start',
      'home_settings': 'Settings',
      'home_language': 'Language',

      // Features
      'feature_getx': 'GetX State Management',
      'feature_getx_desc': 'Reactive programming and state management',
      'feature_mvc': 'MVC Architecture',
      'feature_mvc_desc': 'Clear code layering structure',
      'feature_router': 'Route Management',
      'feature_router_desc': 'Unified route naming and page management',
      'feature_generator': 'Code Generation',
      'feature_generator_desc': 'Auto-generate pages, services and models',
      'feature_http': 'HTTP Service',
      'feature_http_desc': 'Integrated Dio network requests',
      'feature_storage': 'Local Storage',
      'feature_storage_desc': 'SharedPreferences wrapper',
      'feature_i18n': 'Internationalization',
      'feature_i18n_desc': 'Multi-language support',
      'feature_revert': 'Operation Revert',
      'feature_revert_desc': 'Support reverting wrong generation operations',

      // Code generation
      'generate_page': 'Generate New Page',
      'generate_page_cmd': 'dart run scripts/generate_page.dart my_page',
      'generate_page_desc': 'Create complete MVC page structure',
      'generate_service': 'Generate Service Module',
      'generate_service_cmd':
          'dart run scripts/generate_service.dart my_service',
      'generate_service_desc': 'Generate Service + Model + API',
      'scan_routes': 'Scan Routes',
      'scan_routes_cmd': 'dart run scripts/scan_routes.dart',
      'scan_routes_desc': 'Auto-update route configuration',
      'revert_operation': 'Revert Operation',
      'revert_operation_cmd': 'dart run scripts/revert.dart',
      'revert_operation_desc': 'Revert wrong generation operations',

      // Settings
      'settings_title': 'Settings',
      'settings_language': 'Language',
      'settings_theme': 'Theme',
      'settings_about': 'About',
      'language_changed': 'Language changed',
      'theme_light': 'Light Theme',
      'theme_dark': 'Dark Theme',
      'theme_system': 'Follow System',

      // Errors
      'error_network': 'Network connection error',
      'error_timeout': 'Request timeout',
      'error_server': 'Server error',
      'error_unknown': 'Unknown error',
      'error_file_not_found': 'File not found',
      'error_permission_denied': 'Permission denied',

      // Validation
      'validation_required': 'This field is required',
      'validation_email': 'Please enter a valid email address',
      'validation_phone': 'Please enter a valid phone number',
      'validation_password': 'Password must be at least 6 characters',
      'validation_confirm_password': 'Passwords do not match',
    
      'test_key': 'Test Translation',
      },
  };
}
