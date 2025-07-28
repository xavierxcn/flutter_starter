import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common/index.dart';

/// 全局配置
class Global {
  /// 初始化应用
  static Future<void> init() async {
    // 确保Flutter插件已初始化
    WidgetsFlutterBinding.ensureInitialized();

    // 初始化本地存储
    await Storage().init();

    // 初始化服务
    Get.put<ConfigService>(ConfigService());
    Get.put<HttpService>(HttpService());
    Get.put<LanguageService>(LanguageService());

    // 初始化配置
    await ConfigService.to.init();

    // 初始化语言设置
    await LanguageService.to.init();
  }
}
