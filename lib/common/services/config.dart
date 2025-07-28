import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'storage.dart';

/// 配置服务
class ConfigService extends GetxService {
  static ConfigService get to => Get.find();

  PackageInfo? _packageInfo;

  // 应用信息
  String get appName => _packageInfo?.appName ?? '';
  String get packageName => _packageInfo?.packageName ?? '';
  String get version => _packageInfo?.version ?? '';
  String get buildNumber => _packageInfo?.buildNumber ?? '';

  // 存储实例
  final Storage _storage = Storage();

  /// 初始化配置
  Future<void> init() async {
    // 获取应用信息
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 保存配置
  Future<bool> saveConfig(String key, dynamic value) async {
    if (value is String) {
      return await _storage.setString(key, value);
    } else if (value is int) {
      return await _storage.setInt(key, value);
    } else if (value is bool) {
      return await _storage.setBool(key, value);
    } else if (value is double) {
      return await _storage.setDouble(key, value);
    } else if (value is List<String>) {
      return await _storage.setStringList(key, value);
    }
    return false;
  }

  /// 获取配置
  T? getConfig<T>(String key) {
    if (T == String) {
      return _storage.getString(key) as T?;
    } else if (T == int) {
      return _storage.getInt(key) as T?;
    } else if (T == bool) {
      return _storage.getBool(key) as T?;
    } else if (T == double) {
      return _storage.getDouble(key) as T?;
    } else if (T == List<String>) {
      return _storage.getStringList(key) as T?;
    }
    return null;
  }

  /// 删除配置
  Future<bool> removeConfig(String key) async {
    return await _storage.remove(key);
  }

  /// 清空所有配置
  Future<bool> clearConfig() async {
    return await _storage.clear();
  }
}
