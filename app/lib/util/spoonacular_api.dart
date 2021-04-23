import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:nutriscient/cred.dart';

Future<http.Response> spoonacularSearch(String query) {
  final String _url = 'https://api.spoonacular.com/food/ingredients/search'
      '?query=$query&apiKey=$spoonacular_api_key';
  return http.get(Uri.parse(_url));
}

Future<http.Response> _barcodeProductSearch(String barcode) {
  String barcode_14 = barcode.padLeft(14, '0');
  final String _url = 'https://www.gtinsearch.org/api/items/$barcode_14';
  print("$_url");
  return http.get(Uri.parse(_url));
}

Future<List> searchIngredient(String query) async {
  final response = await spoonacularSearch(query);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var parsed = jsonDecode(response.body);
    return parsed['results'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('API Call Failed');
  }
}

Future<String> barcodeProductSearch(String barcode) async {
  final response = await _barcodeProductSearch(barcode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var parsed = jsonDecode(response.body);
    print("raw=$parsed");
    if (parsed.length == 0)
      return '';
    else
      return parsed[0]['name'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('API Call Failed');
  }
}