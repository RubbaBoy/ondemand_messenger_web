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

  Future<void> requestToken(String name, String password) async {
    var token = postRequest('https://ondemand.yarr.is/requestToken',
        {'name': name, 'password': password});
    print((await token).body);
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
