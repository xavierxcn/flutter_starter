import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class Storage {
  static Storage? _instance;
  static SharedPreferences? _prefs;

  factory Storage() => _instance ??= Storage._internal();

  Storage._internal();

  /// 初始化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  /// 获取字符串
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  /// 获取整数
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// 删除键
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// 清空所有数据
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// 获取所有键
  Set<String> getKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }
}
