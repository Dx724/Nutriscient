import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutriscient/cred.dart';
import 'package:nutriscient/util/constants.dart';

Future<http.Response> _getUnregistered() {
  final String _url = '$kBackend/return_unregistered_rfid';
  return http.get(Uri.parse(_url), headers: {'Client-Id': '$kScaleId'});
}

Future<http.Response> _registerRfid(String rfid, int ingredientId) {
  final String _url =
      '$kBackend/label_rfid?Client-Id=$kScaleId&RFID-Id=$rfid&Ingredient-Id=$ingredientId';
  return http.get(Uri.parse(_url));
}

Future<http.Response> _getVisualizeAll() {
  final String _url = '$kBackend/visualize?Client-Id=$kScaleId';
  return http.get(Uri.parse(_url));
}

Future<http.Response> _getVisualizeOne(String rfid) {
  final String _url =
      '$kBackend/visualize_ingredient?Client-Id=$kScaleId&RFID-Id=$rfid';
  return http.get(Uri.parse(_url));
}

Future<http.Response> _getIngredients() {
  final String _url = '$kBackend/get_all_ingredient?Client-Id=$kScaleId';
  return http.get(Uri.parse(_url));
}

Future<Map> getUnregistered() async {
  final response = await _getUnregistered();
  if (response.statusCode == 200) {
    var parsed = jsonDecode(response.body);
    return parsed;
  } else
    throw Exception('API Call Failed');
}

Future<bool> registerRfid(String rfid, int ingredientId) async {
  final response = await _registerRfid(rfid, ingredientId);
  if (response.statusCode == 200) {
    if (response.body == 'OK') return true;
  } else
    throw Exception('API Call Failed');
  return false;
}

Future<Map> getVisualizeAll() async {
  final response = await _getVisualizeAll();
  if (response.statusCode == 200) {
    var parsed = jsonDecode(response.body);
    if (parsed['ok'])
      return jsonDecode(parsed['message']);
    else
      throw Exception('API Call Failed: $parsed');
  } else
    throw Exception('API Call Failed');
}

Future<Map> getVisualizeOne(String rfid) async {
  final response = await _getVisualizeOne(rfid);
  if (response.statusCode == 200) {
    var parsed = jsonDecode(response.body);
    return parsed;
  } else
    throw Exception('API Call Failed');
}

Future<Map> getIngredients() async {
  final response = await _getIngredients();
  if (response.statusCode == 200) {
    var parsed = jsonDecode(response.body);
    return parsed;
  } else
    throw Exception('API Call Failed');
}
