import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../lib/common/index.dart';

/// 简单的i18n功能测试
void main() async {
  print('🌐 测试i18n功能');
  print('==================');

  // 初始化GetX翻译
  Get.testMode = true;
  Get.translations = Messages();

  // 测试语言切换
  print('当前支持的语言:');
  for (final locale in AppLocales.supportedLocales) {
    print('  - ${locale.toString()}: ${AppLocales.getLanguageName(locale)}');
  }

  print('');
  print('测试翻译功能:');

  // 设置中文
  Get.locale = AppLocales.zhCN;
  print('中文 (zh_CN):');
  print('  app_name: ${'app_name'.tr}');
  print('  home_title: ${'home_title'.tr}');
  print('  home_welcome: ${'home_welcome'.tr}');

  print('');

  // 设置英文
  Get.locale = AppLocales.enUS;
  print('英文 (en_US):');
  print('  app_name: ${'app_name'.tr}');
  print('  home_title: ${'home_title'.tr}');
  print('  home_welcome: ${'home_welcome'.tr}');

  print('');
  print('✅ i18n功能测试完成!');
}
