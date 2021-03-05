import 'package:angular_router/angular_router.dart';
import 'home/home_component.template.dart' as home_component;
import 'tos/tos_component.template.dart' as tos_component;
import 'tutorial/tutorial_component.template.dart' as tutorial_component;

class Routes {
  static final home = RouteDefinition(
      routePath: RoutePaths.home,
      useAsDefault: true,
      component: home_component.HomeComponentNgFactory);

  static final tos = RouteDefinition(
      routePath: RoutePaths.tos,
      component: tos_component.TosComponentNgFactory);

  static final tutorial = RouteDefinition(
      routePath: RoutePaths.tutorial,
      component: tutorial_component.TutorialComponentNgFactory);

  static final all = <RouteDefinition> [home, tos, tutorial];
}

class RoutePaths {
  static final home = RoutePath(path: '/', useAsDefault: true);
  static final tos = RoutePath(path: '/tos');
  static final tutorial = RoutePath(path: '/tutorial');
}
