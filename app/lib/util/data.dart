import 'package:nutriscient/util/backend.dart';

Map visualizationData;
List<String> nutritions;
List ingredientsList;

Future<void> getVisualizationData() async {
  Map rawVisualizationData = await getVisualizeAll();
  visualizationData = {};
  rawVisualizationData.forEach((k, v) {
    String key = k;
    key = key.split('_')[0];
    key = "${key[0].toUpperCase()}${key.substring(1)}";
    visualizationData[key] = v;
  });

  nutritions = List<String>.from(visualizationData.keys);
  nutritions = nutritions..sort();
}

Future<void> getIngredientsListData() async {
  ingredientsList = await getIngredients();
}

Map<String, double> kDV = {
  'Vitamin A': 900,
  'Vitamin C': 90,
  'Calcium': 1300,
  'Iron': 18,
  'Vitamin D': 20,
  'Vitamin E': 15,
  'Vitamin K': 120,
  'Vitamin B1': 1.2,
  'Vitamin B2': 1.3,
  'Vitamin B3': 16,
  'Vitamin B6': 1.7,
  'Folate': 400,
  'Vitamin B12': 2.4,
  'Biotin': 30,
  'Pantothenic acid': 5,
  'Phosphorus': 1250,
  'Iodine': 150,
  'Magnesium': 420,
  'Zinc': 11,
  'Selenium': 55,
  'Copper': 0.9,
  'Manganese': 2.3,
  'Chromium': 35,
  'Molybdenum': 45,
  'Chloride': 2300,
  'Potassium': 4700,
  'Choline': 550,

  'Fat': 178,
  'Saturated Fat': 120,
  'Cholesterol': 300,
  'Net Carbohydrates': 1275,
  'Sodium': 2300,
  'Fiber': 128,
  'Protein': 150,
  'Sugar': 150,
  // Average for men and women
  'Calories': 2250,
};