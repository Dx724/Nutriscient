import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutriscient/cred.dart';
import 'package:nutriscient/util/constants.dart';

Future<http.Response> _getUnregistered() {
  final String _url = '$kBackend/return_unregistered_rfid';
  return http.get(Uri.parse(_url), headers: {
    'Client-Id': '$kScaleId'
  });
}

Future<Map> getUnregistered() async {
  final response = await _getUnregistered();
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var parsed = jsonDecode(response.body);
    return parsed;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('API Call Failed');
  }
}
