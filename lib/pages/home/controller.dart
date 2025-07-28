import 'package:get/get.dart';

/// 首页控制器
class HomeController extends GetxController {
  HomeController();

  /// 响应式计数器
  final count = 0.obs;

  /// 初始化数据
  void _initData() {
    update(["home"]);
  }

  /// 增加计数
  void increment() {
    count.value++;
  }

  /// 重置计数
  void reset() {
    count.value = 0;
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
