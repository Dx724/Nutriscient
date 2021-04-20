import 'package:charts_flutter/flutter.dart' as charts;

class PieChartModel {
  final int x;
  final int y;
  final String name;

  PieChartModel(this.x, this.y, this.name);
}

class BarChartModel {
  final String dayOfWeek;
  final int y;

  BarChartModel(this.dayOfWeek, this.y);
}

List<charts.Series<PieChartModel, int>> createSamplePieChartData() {
  final data = [
    new PieChartModel(1, 25, "candy"),
    new PieChartModel(2, 10, "milk"),
    new PieChartModel(3, 60, "beef"),
    new PieChartModel(4, 5, "egg"),
  ];

  return [
    new charts.Series<PieChartModel, int>(
      id: 'Daily Intake Constitution',
      domainFn: (PieChartModel data, _) => data.x,
      measureFn: (PieChartModel data, _) => data.y,
      data: data,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (PieChartModel row, _) => '${row.name}\n${row.y}%',
      colorFn: (_, index) => charts.MaterialPalette.blue
          .makeShades((data.length * 1.5).toInt())[index],
      fillColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault.lighter,
    )
  ];
}

List<charts.Series<BarChartModel, String>> createSampleBarChartData() {
  final barData = [
    new BarChartModel('Mon', 5),
    new BarChartModel('Tue', 10),
    new BarChartModel('Wed', 5),
    new BarChartModel('Thu', 30),
    new BarChartModel('Fri', 5),
    new BarChartModel('Sat', 20),
    new BarChartModel('Sun', 15),
  ];

  final lineData = [
    new BarChartModel('Mon', 5),
    new BarChartModel('Tue', 15),
    new BarChartModel('Wed', 20),
    new BarChartModel('Thu', 50),
    new BarChartModel('Fri', 55),
    new BarChartModel('Sat', 75),
    new BarChartModel('Sun', 80),
  ];

  return [
    new charts.Series<BarChartModel, String>(
        id: 'Daily',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (BarChartModel data, _) => data.dayOfWeek,
        measureFn: (BarChartModel data, _) => data.y,
        data: barData),
    new charts.Series<BarChartModel, String>(
        id: 'Cumulative',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (BarChartModel data, _) => data.dayOfWeek,
        measureFn: (BarChartModel data, _) => data.y,
        data: lineData)..setAttribute(charts.rendererIdKey, 'customLine'),
  ];
}
