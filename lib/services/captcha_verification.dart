
import 'dart:async';
import 'dart:js';

import 'package:angular/angular.dart';

@Injectable()
class CaptchaVerification {

  Future<String> getCaptchaToken() async {
    var completer = Completer<String>();
    var grecaptcha = context['grecaptcha'] as JsObject;
    grecaptcha.callMethod('reset');
    grecaptcha.callMethod('execute');
    context['callback'] = completer.complete;

    return completer.future;
  }
}