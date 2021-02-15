import 'dart:convert';
import 'dart:html';

import 'package:LakWebsite/phone_pipe.dart';
import 'package:angular/angular.dart';
import 'package:http/http.dart' as http;

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
  ],
  pipes: [PhoneNumberPipe],
)
class AppComponent {
  final messages = <SentMessage>[];

  void send(String number, String message) {
    http
        .post('https://ondemand.yarr.is/sendSMS',
            body: jsonEncode({
              'number': number,
              'message': message,
            }))
        .then((res) => messages.insert(
            0, SentMessage(number, message, res.statusCode == 200)));
  }

  void setValues(SentMessage message, InputElement numberInput, TextAreaElement messageInput) {
    numberInput.value = message.number;
    messageInput.value = message.message;
  }
}

class SentMessage {
  final String number;
  final String message;
  final bool success;

  SentMessage(this.number, this.message, this.success);
}
