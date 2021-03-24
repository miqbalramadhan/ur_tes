import 'package:ur_tes/base/api_base_helper.dart';

class ApiBase extends ApiBaseHelper {
  Map<String, String> header() {
    Map<String, String> header = {
      "Content-type": "application/json",
      "Accept": "application/json",
    };
    return header;
  }
}
