import 'dart:html';

class CookieUtil {
  static void setCookie(String key, String value, {String expiryDateTime}) {
    var cookieString = '$key=$value;';
    if (expiryDateTime != null) {
      cookieString += 'Expiry=$expiryDateTime;';
    }

    document.cookie = cookieString;
  }

  static String getCookie(String key) => document.cookie
      .split(';')
      .map((kv) => kv.split('='))
      .firstWhere((val) => val[0].trim() == key, orElse: () => null)
      ?.elementAt(1)
      ?.trim();
}
