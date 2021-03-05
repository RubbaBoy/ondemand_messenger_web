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
  selector: 'home',
  styleUrls: ['home_component.css'],
  templateUrl: 'home_component.html',
  directives: [
    coreDirectives,
  ],
  providers: [
    ClassProvider(CaptchaVerification),
    ClassProvider(RequestService),
  ],
  pipes: [PhoneNumberPipe],
)
class HomeComponent implements OnInit {

  final CaptchaVerification _captchaVerification;
  final RequestService _requestService;

  final messages = <SentMessage>[];
  String errorMessage;
  bool error = false;
  bool showingBook = false;
  bool loggedIn = false;
  bool loading = false;

  int bookId;
  List<Number> numbers = [];

  HomeComponent(this._captchaVerification, this._requestService);

  @override
  Future<void> ngOnInit() async {
    _captchaVerification.init();
    _requestService.init(showError);
    var token = CookieUtil.getCookie('token') ?? '';

    if (token != '') {
      if (await loginBook(token)) {
        loggedIn = true;
        showingBook = true;
      }
    }
  }

  void send(String number, String message) {
    try {
      loading = true;
      _requestService.postRequest('https://ondemand.yarr.is/sendSMS',
          {
            'number': number,
            'message': message,
          })
          .then((res) =>
          messages.insert(
              0, SentMessage(number, message, res.statusCode == 200)))
      .then((_) => loading = false);
    } catch (e) {
      showError('Unable to send message: $e');
    }
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
    loggedIn = false;
    showingBook = false;
    numbers.clear();
  }

  Future<void> requestToken(String name, String password) async {
    loading = true;
    if (await _requestService.requestToken(name, password)) {
      loggedIn = true;
      showingBook = true;
      await loginBook(CookieUtil.getCookie('token'));
    }
  }

  /// Logs in the user to the book with the given [token]. Returns if this login
  /// was successful.
  Future<bool> loginBook(String token) async {
    loading = true;
    try {
      var res = await _requestService.bookRequest(
          'https://ondemand.yarr.is/getBook');
      if (res == null) {
        return false;
      }

      numbers.clear();
      for (var number in res['numbers']) {
        numbers.add(
            Number(number['numberId'], number['name'], number['number']));
      }
      return true;
    } catch (e) {
      showError('Unable to get book: $e');
      return false;
    } finally {
      loading = false;
    }
  }

  Future<void> createBook(String name, String password) async {
    try {
      loading = true;
      var res = await _requestService.postRequest(
          'https://ondemand.yarr.is/createBook', {
        'name': name,
        'password': password
      });
      if (res == null) {
        return;
      }

      showingBook = true;
      loggedIn = true;
    } catch (e) {
      showError('Unable to create book: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> removeNumber(Number number) async {
    try {
      loading = true;
      var res = await _requestService.bookRequest(
          'https://ondemand.yarr.is/removeNumber',
          body: {'numberId': number.numberId});
      if (res == null) {
        return;
      }

      numbers.remove(number);
    } catch (e) {
      showError('Unable to remove number: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> addNumber(TextInputElement nameInput, TextInputElement numberInput) async {
    try {
      loading = true;
      var res = await _requestService.bookRequest(
          'https://ondemand.yarr.is/addNumber',
          body: {'numberName': nameInput.value, 'number': numberInput.value});

      if (res == null) {
        return;
      }

      nameInput.value = '';
      numberInput.value = '';
      numbers.add(Number.fromJson(res['number']));
    } catch (e) {
      showError('Unable to add number: $e');
    } finally {
      loading = false;
    }
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
