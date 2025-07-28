import 'dart:ui';
import 'package:get/get.dart';

import '../services/index.dart';
import 'locales.dart';

/// 语言管理服务
class LanguageService extends GetxService {
  static LanguageService get to => Get.find();

  /// 当前语言
  final _currentLocale = AppLocales.defaultLocale.obs;

  /// 获取当前语言
  Locale get currentLocale => _currentLocale.value;

  /// 获取当前语言字符串
  String get currentLanguageCode => _currentLocale.value.toString();

  /// 获取当前语言显示名称
  String get currentLanguageName =>
      AppLocales.getLanguageName(_currentLocale.value);

  /// 初始化语言设置
  Future<void> init() async {
    // 从本地存储读取保存的语言设置
    final savedLanguage = Storage().getString('language');

    if (savedLanguage != null) {
      final locale = AppLocales.getLocaleFromCode(savedLanguage);
      if (locale != null) {
        _currentLocale.value = locale;
        await _updateLocale(locale);
        return;
      }
    }

    // 如果没有保存的语言设置，尝试使用系统语言
    final systemLocale = Get.deviceLocale;
    if (systemLocale != null && _isSupportedLocale(systemLocale)) {
      _currentLocale.value = systemLocale;
      await _updateLocale(systemLocale);
    } else {
      // 使用默认语言
      _currentLocale.value = AppLocales.defaultLocale;
      await _updateLocale(AppLocales.defaultLocale);
    }
  }

  /// 切换语言
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale.value == locale) return;

    _currentLocale.value = locale;
    await _updateLocale(locale);

    // 保存到本地存储
    await Storage().setString('language', locale.toString());

    print('语言已切换到: ${AppLocales.getLanguageName(locale)}');
  }

  /// 切换到下一个语言
  Future<void> switchToNextLanguage() async {
    final currentIndex = AppLocales.supportedLocales.indexOf(
      _currentLocale.value,
    );
    final nextIndex = (currentIndex + 1) % AppLocales.supportedLocales.length;
    final nextLocale = AppLocales.supportedLocales[nextIndex];

    await changeLanguage(nextLocale);
  }

  /// 重置为系统语言
  Future<void> resetToSystemLanguage() async {
    final systemLocale = Get.deviceLocale;
    if (systemLocale != null && _isSupportedLocale(systemLocale)) {
      await changeLanguage(systemLocale);
    } else {
      await changeLanguage(AppLocales.defaultLocale);
    }
  }

  /// 重置为默认语言
  Future<void> resetToDefaultLanguage() async {
    await changeLanguage(AppLocales.defaultLocale);
  }

  /// 获取支持的语言列表
  List<Locale> getSupportedLocales() {
    return AppLocales.supportedLocales;
  }

  /// 获取语言选择列表（用于UI显示）
  List<Map<String, dynamic>> getLanguageOptions() {
    return AppLocales.supportedLocales
        .map(
          (locale) => {
            'locale': locale,
            'code': locale.toString(),
            'name': AppLocales.getLanguageName(locale),
            'isSelected': locale == _currentLocale.value,
          },
        )
        .toList();
  }

  /// 检查是否为支持的语言
  bool _isSupportedLocale(Locale locale) {
    return AppLocales.supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode,
    );
  }

  /// 更新GetX的locale设置
  Future<void> _updateLocale(Locale locale) async {
    await Get.updateLocale(locale);
  }

  /// 获取翻译文本（快捷方法）
  String tr(String key, {Map<String, String>? args}) {
    return key.tr;
  }

  /// 检查翻译键是否存在
  bool hasTranslation(String key) {
    try {
      final result = key.tr;
      return result != key; // 如果翻译不存在，通常返回原始key
    } catch (e) {
      return false;
    }
  }
}
