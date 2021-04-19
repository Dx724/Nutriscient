import 'package:charts_flutter/flutter.dart' as charts;

class PiechartModel {
  final int name;
  final int percentage;

  PiechartModel(this.name, this.percentage);
}


/// Create one series with sample hard coded data.
List<charts.Series<PiechartModel, int>> createSamplePieChartData() {
  final data = [
    new PiechartModel(0, 100),
    new PiechartModel(1, 75),
    new PiechartModel(2, 25),
    new PiechartModel(3, 5),
  ];

  return [
    new charts.Series<PiechartModel, int>(
      id: 'Sales',
      domainFn: (PiechartModel sales, _) => sales.name,
      measureFn: (PiechartModel sales, _) => sales.percentage,
      data: data,
// Set a label accessor to control the text of the arc label.
      labelAccessorFn: (PiechartModel row, _) => '${row.name}: ${row.percentage}%',
    )
  ];
}