import 'package:nutriscient/util/backend.dart';

Map visualizationData;
List<String> nutritions;
Map ingredientsList;

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
