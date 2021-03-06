import 'package:LakWebsite/primary_routes.dart';
import 'package:LakWebsite/services/captcha_verification.dart';
import 'package:LakWebsite/services/request_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'footer/footer_component.dart';

@Component(
  selector: 'app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
    routerDirectives,
    FooterComponent
  ],
  providers: [
    ClassProvider(CaptchaVerification),
    ClassProvider(RequestService),
  ],
  exports: [Routes],
  pipes: [],
)
class AppComponent implements OnInit {

  @override
  void ngOnInit() {

  }

}
