import 'dart:ui';

/// 支持的语言配置
class AppLocales {
  /// 中文简体
  static const zhCN = Locale('zh', 'CN');

  /// 英文
  static const enUS = Locale('en', 'US');

  /// 支持的语言列表
  static const supportedLocales = [zhCN, enUS];

  /// 回退语言
  static const fallbackLocale = zhCN;

  /// 默认语言
  static const defaultLocale = zhCN;

  /// 获取语言显示名称
  static String getLanguageName(Locale locale) {
    switch (locale.toString()) {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      default:
        return locale.toString();
    }
  }

  /// 获取语言代码对应的Locale
  static Locale? getLocaleFromCode(String code) {
    switch (code) {
      case 'zh_CN':
        return zhCN;
      case 'en_US':
        return enUS;
      default:
        return null;
    }
  }
}
