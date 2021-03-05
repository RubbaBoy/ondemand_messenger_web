
import 'package:LakWebsite/primary_routes.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'footer',
  styleUrls: ['footer_component.css'],
  templateUrl: 'footer_component.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [Routes, RoutePaths],
  pipes: [],
)
class FooterComponent {
}
