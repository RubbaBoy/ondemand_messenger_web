import 'dart:html';

class CookieUtil {
  static void setCookie(String key, String value) {
    document.cookie = '$key=$value;';
  }

  static String getCookie(String key) => document.cookie
      .split(';')
      .map((kv) => kv.split('='))
      .firstWhere((val) => val[0].trim() == key, orElse: () => null)
      ?.elementAt(1)
      ?.trim();
}
