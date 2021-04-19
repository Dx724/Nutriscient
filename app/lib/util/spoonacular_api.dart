import 'package:http/http.dart' as http;
import 'package:nutriscient/cred.dart';

Future<http.Response> searchIngredient(String query) {
  final String _url = 'https://api.spoonacular.com/food/ingredients/search'
      '?query=$query&apiKey=$spoonacular_api_key';
  return http.get(Uri.parse(_url));
}

// TODO: Parse response