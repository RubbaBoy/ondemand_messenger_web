import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:LakWebsite/phone_pipe.dart';
import 'package:LakWebsite/services/captcha_verification.dart';
import 'package:LakWebsite/services/request_service.dart';
import 'package:LakWebsite/utils/cookie_util.dart';
import 'package:angular/angular.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
  ],
  providers: [
    ClassProvider(CaptchaVerification),
    ClassProvider(RequestService),
  ],
  pipes: [PhoneNumberPipe],
)
class AppComponent implements OnInit {

  final CaptchaVerification _captchaVerification;
  final RequestService _requestService;

  final messages = <SentMessage>[];
  String errorMessage;
  bool error = false;
  bool showingBook = false;
  bool loggedIn = false;

  String name;
  String password;
  int bookId;
  List<Number> numbers = [];

  AppComponent(this._captchaVerification, this._requestService);

  @override
  Future<void> ngOnInit() async {
    var username = CookieUtil.getCookie('username') ?? '';
    var password = CookieUtil.getCookie('password') ?? '';

    if (username != '' && password != '') {
      loggedIn = true;
      showingBook = true;
      await loginBook(name = username, this.password = password);
    }
  }

  void send(String number, String message) {
    _requestService.postRequest('https://ondemand.yarr.is/sendSMS',
            {
              'number': number,
              'message': message,
            })
        .then((res) => messages.insert(
            0, SentMessage(number, message, res.statusCode == 200)));
  }

  void setValues(SentMessage message, InputElement numberInput,
      TextAreaElement messageInput) {
    numberInput.value = message.number;
    messageInput.value = message.message;
  }

  void setNumber(String number, InputElement numberInput) =>
      numberInput.value = formatNumber(number);

  void toggleBook() {
    showingBook = !showingBook;
  }

  void logOut() {
    CookieUtil.setCookie('username', '');
    CookieUtil.setCookie('password', '');
    loggedIn = false;
    showingBook = false;
    numbers.clear();
  }

  Future<void> loginBook(String name, String password) async {
    this.name = name;
    this.password = password;

    print('$name:$password');

    await _requestService.requestToken(name, password);

    var res = await _requestService.bookRequest('https://ondemand.yarr.is/getBook', {});
    print(res);
    if (res == null) {
      return;
    }

    setCredentials(name, password);

    numbers.clear();
    for (var number in res['numbers']) {
      numbers.add(Number(number['numberId'], number['name'], number['number']));
    }
  }

  Future<void> createBook(String name, String password) async {
    this.name = name;
    this.password = password;

    var res = await _requestService.bookRequest('https://ondemand.yarr.is/createBook', {});
    if (res == null) {
      return;
    }

    showingBook = true;
    setCredentials(name, password);
  }

  Future<void> removeNumber(Number number) async {
    var res = await _requestService.bookRequest('https://ondemand.yarr.is/removeNumber',
        {'numberId': number.numberId});
    if (res == null) {
      return;
    }

    numbers.remove(number);
  }

  Future<void> addNumber(TextInputElement nameInput, TextInputElement numberInput) async {
    var res = await _requestService.bookRequest('https://ondemand.yarr.is/addNumber',
        {'numberName': nameInput.value, 'number': numberInput.value});

    if (res == null) {
      return;
    }

    nameInput.value = '';
    numberInput.value = '';
    numbers.add(Number.fromJson(res['number']));
  }



  void setCredentials(String name, String password) {
    CookieUtil.setCookie('username', name);
    CookieUtil.setCookie('password', password);

    loggedIn = true;
  }

  void loginSubmit(KeyboardEvent event, ButtonElement button) {
    if (event.keyCode == 13) { // enter
      button.click();
    }
  }

  void showError(String message) {
    errorMessage = message;
    error = true;
    Timer(Duration(seconds: 3), () => error = false);
  }
}

class SentMessage {
  final String number;
  final String message;
  final bool success;

  SentMessage(this.number, this.message, this.success);
}

class Number {
  final int numberId;
  final String name;
  final String number;

  Number(this.numberId, this.name, this.number);

  Number.fromJson(Map<String, dynamic> json)
      : numberId = json['numberId'],
        name = json['name'],
        number = json['number'];

  @override
  String toString() {
    return 'Number{numberId: $numberId, name: $name, number: $number}';
  }
}
