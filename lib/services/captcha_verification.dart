
import 'dart:async';
import 'dart:js';
import 'dart:js_util' as js;

import 'package:angular/angular.dart';

@Injectable()
class CaptchaVerification {

  bool ready = false;
  Completer waiting = Completer();

  void init() {
    context['captchaReady'] = () {
      ready = true;
      waiting.complete();
    };
  }

  Future<String> getCaptchaToken() async {
    if (!ready) {
      await waiting.future;
    }

    var completer = Completer<String>();
    var grecaptcha = context['grecaptcha'] as JsObject;
    context['callback'] = completer.complete;
    grecaptcha.callMethod('reset');
    grecaptcha.callMethod('execute');
    return completer.future;
  }
}
