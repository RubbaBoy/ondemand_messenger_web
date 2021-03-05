
import 'dart:async';
import 'dart:js';

import 'package:angular/angular.dart';

@Injectable()
class CaptchaVerification {

  bool ready = false;
  Completer waiting = Completer();

  void init() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      var cap = context['grecaptcha'] as JsObject;
      if (cap != null) {
        cap.callMethod('ready', [() {
          ready = true;
          waiting.complete();
        }]);

        timer.cancel();
      }
    });
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
