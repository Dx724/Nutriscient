import 'package:charts_flutter/flutter.dart' as charts;

class Chart2DModel {
  final int x;
  final int y;

  Chart2DModel(this.x, this.y);
}


List<charts.Series<Chart2DModel, int>> createSamplePieChartData() {
  final data = [
    new Chart2DModel(0, 100),
    new Chart2DModel(1, 75),
    new Chart2DModel(2, 25),
    new Chart2DModel(3, 5),
  ];

  return [
    new charts.Series<Chart2DModel, int>(
      id: 'Daily Intake Constitution',
      domainFn: (Chart2DModel data, _) => data.x,
      measureFn: (Chart2DModel data, _) => data.y,
      data: data,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (Chart2DModel row, _) => '${row.x}: ${row.y}%',
    )
  ];
}