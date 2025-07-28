import 'package:get/get.dart';

import '../../pages/index.dart';
import 'names.dart';
import 'observers.dart';

/// 路由页面管理
class RoutePages {
  /// 历史记录
  static final List<String> history = <String>[];

  /// 观察者
  static RouteObserver observer = RouteObserver();

  /// 路由列表
  static List<GetPage> list = [
    GetPage(name: RouteNames.main, page: () => const HomePage()),
    GetPage(name: RouteNames.home, page: () => const HomePage()),
  ];
}
