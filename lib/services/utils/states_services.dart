import 'dart:convert';
import 'package:weatherforcasting/model/india.dart';
import 'package:http/http.dart' as http;
import 'package:weatherforcasting/services/utils/app_urls.dart';

class StatesServices {
    Future<India> indiaApi(String city) async {
    final response = await http.get(Uri.parse("${Urls.base}key=${Urls.key}&q=$city&aqi=yes"));
    print("**************");
    print(response.statusCode.toString());
    print("**************");
    if (response.statusCode == 200) {
      
      var data = jsonDecode(response.body.toString());
      return India.fromJson(data);
    } else {
      throw Exception('Error');
    }
  }
}
