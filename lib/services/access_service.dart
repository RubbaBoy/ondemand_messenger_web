
import '../utils/cookie_util.dart';
import 'package:angular/angular.dart';

@Injectable()
class AccessService {

  Future<String> getAPIKey() {
    var api = CookieUtil.getCookie('api') ?? '';
    if (api == '') {

    }
  }

  Future<String> _generateAPIKey() {

  }

}