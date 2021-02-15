import 'package:angular/core.dart';

@Pipe('phoneNumber')
class PhoneNumberPipe extends PipeTransform {
  String transform(String number) {
    number = number.replaceAll(RegExp(r'\D'), '');
    var last = number.substring(number.length - 4);
    var middle = number.substring(number.length - 7, number.length - 4);
    var area = number.substring(number.length - 10, number.length - 7);
    var international = '';
    if (number.length > 10) {
      international = '+${number.substring(0, number.length - 10)} ';
    }

    return '$international($area) $middle-$last';
  }
}
