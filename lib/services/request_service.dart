import 'dart:convert';

import 'package:LakWebsite/services/captcha_verification.dart';
import 'package:LakWebsite/utils/cookie_util.dart';
import 'package:angular/angular.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

@Injectable()
class RequestService {
  final CaptchaVerification _captchaVerification;
  Function(String) errorHandler;

  RequestService(this._captchaVerification);

  void error(String error) => errorHandler?.call(error);

  void init(Function(String) errorHandler) {
    this.errorHandler = errorHandler;
  }

  /// Returns if it's successful
  Future<bool> requestToken(String name, String password) async {
    var res = await postRequest('https://ondemand.yarr.is/requestToken',
        {'name': name, 'password': password});
    if (!setToken(res.headers)) {
      error('Invalid credentials');
      return false;
    }

    return true;
  }

  /// Sets a token from given headers. Returns if this was successful or not.
  bool setToken(Map<String, String> headers) {
    var tokenHeader = headers['x-token']?.split(';');
    if (tokenHeader == null) {
      return false;
    }

    var token = tokenHeader[0];
    var expiryUTC = tokenHeader[1];

    CookieUtil.setCookie('token', token, expiryDateTime: expiryUTC);
    return true;
  }

  Future<Map<String, dynamic>> bookRequest(
      String url, {Map<String, dynamic> body = const {}, int iterations = 0}) async {
    var token = CookieUtil.getCookie('token');
    var response = await postRequest(url, {'token': token, ...body}, catchError: false);
    var json = jsonDecode(response.body);

    if (response.statusCode == 401) {
      if (json['error'] == 'Expired token') {
        error('Book session expired');
      } else {
        error('Invalid book token');
      }
      return null;
    }

    if (json.containsKey('error')) {
      print('Error on request to "$url":');
      print(json['error']);
      throw json['error'];
    }

    return json;
  }

  /// Makes a post request with reCaptcha enabled. This should be used with
  /// every request.
  Future<Response> postRequest(String url, Map<String, dynamic> body, {bool catchError = true}) async {
    var captchaToken = await _captchaVerification.getCaptchaToken();

    var response = await http.post(url,
        body: jsonEncode({'captchaToken': captchaToken, ...body}));
    var json = jsonDecode(response.body);

    if (catchError && json.containsKey('error')) {
      print('Error on request to "$url":');
      print(json['error']);
      throw Exception(json['error']);
    }

    // If this was a request that responded with a token header, set it as the
    // token.
    setToken(response.headers);

    return response;
  }
}
