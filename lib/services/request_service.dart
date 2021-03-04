import 'dart:convert';

import 'package:LakWebsite/services/captcha_verification.dart';
import 'package:LakWebsite/utils/cookie_util.dart';
import 'package:angular/angular.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

@Injectable()
class RequestService {
  final CaptchaVerification _captchaVerification;

  RequestService(this._captchaVerification);

  // TODO: Proper errors and loading indicators

  Future<void> requestToken(String name, String password) async {
    var res = await postRequest('https://ondemand.yarr.is/requestToken',
        {'name': name, 'password': password});
    var tokenHeader = res.headers['x-token']?.split(';');
    if (tokenHeader == null) {
      print('Couldn\'t get token');
      print(res.body);
      return;
    }

    var token = tokenHeader[0];
    var expiryUTC = tokenHeader[1];

    CookieUtil.setCookie('token', token, expiryDateTime: expiryUTC);
  }

  Future<Map<String, dynamic>> bookRequest(
      String url, Map<String, dynamic> body) async {
    var token = CookieUtil.getCookie('token');
    var response = await postRequest(url, {'token': token, ...body});
    var json = jsonDecode(response.body);

    if (json.containsKey('error')) {
      print('Error on request to "$url":');
      print(json['error']);
      throw 'Error: ${json['error']}';
    }

    return json;
  }

  /// Makes a post request with reCaptcha enabled. This should be used with
  /// every request.
  Future<Response> postRequest(String url, Map<String, dynamic> body) async {
    var captchaToken = await _captchaVerification.getCaptchaToken();

    var response = await http.post(url,
        body: jsonEncode({'captchaToken': captchaToken, ...body}));
    var json = jsonDecode(response.body);

    if (json.containsKey('error')) {
      print('Error on request to "$url":');
      print(json['error']);
      throw 'Error: ${json['error']}';
    }

    return response;
  }
}
