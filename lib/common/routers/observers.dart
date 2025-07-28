import 'package:flutter/material.dart';

import 'pages.dart';

/// 路由观察者
class RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    var routeName = route.settings.name;
    if (routeName != null) {
      RoutePages.history.add(routeName);
      print('路由跳转: $routeName');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    var routeName = route.settings.name;
    if (routeName != null && RoutePages.history.isNotEmpty) {
      RoutePages.history.removeLast();
      print('路由返回: $routeName');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    var routeName = route.settings.name;
    if (routeName != null) {
      RoutePages.history.remove(routeName);
      print('路由移除: $routeName');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    var oldRouteName = oldRoute?.settings.name;
    var newRouteName = newRoute?.settings.name;

    if (oldRouteName != null && newRouteName != null) {
      var index = RoutePages.history.indexOf(oldRouteName);
      if (index != -1) {
        RoutePages.history[index] = newRouteName;
      }
      print('路由替换: $oldRouteName -> $newRouteName');
    }
  }
}
