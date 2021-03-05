import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:LakWebsite/phone_pipe.dart';
import 'package:LakWebsite/primary_routes.dart';
import 'package:LakWebsite/services/captcha_verification.dart';
import 'package:LakWebsite/services/request_service.dart';
import 'package:LakWebsite/utils/cookie_util.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'tutorial',
  styleUrls: ['../info_style.css'],
  templateUrl: 'tutorial_component.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [RoutePaths],
  providers: [],
  pipes: [],
)
class TutorialComponent {
}
