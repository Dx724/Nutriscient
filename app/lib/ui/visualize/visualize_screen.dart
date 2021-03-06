import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:nutriscient/ui/common_widgets.dart';

import 'package:nutriscient/ui/nutriscient_app_theme.dart';
import 'package:nutriscient/ui/visualize/chart_card_view.dart';
import 'package:nutriscient/ui/visualize/select_nutrient_view.dart';

import 'package:nutriscient/ui/models/chart_2d_data.dart';
import 'package:nutriscient/util/data.dart';

class VisualizeScreen extends StatefulWidget {
  const VisualizeScreen({Key key, this.animationController}) : super(key: key);

  final AnimationController animationController;

  @override
  _VisualizeScreenState createState() => _VisualizeScreenState();
}

class _VisualizeScreenState extends State<VisualizeScreen>
    with TickerProviderStateMixin {
  Animation<double> topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  Widget pieChart, barChart;
  List<charts.Series<PieChartModel, int>> pieChartData;
  List<charts.Series<BarChartModel, String>> barChartData;
  List<String> allNutrients;
  String currentNutrient;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    // TODO: Replace with API Calls
    allNutrients = nutritions;
    currentNutrient = nutritions[0];
    addAllListData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  void selectedNutrient(String selectedNutrient) {
    setState(() {
      currentNutrient = selectedNutrient;
      rebuildCharts();
    });
  }

  void addAllListData() {
    const int count = 3;

    listViews.add(
      SelectNutrientView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
        values: allNutrients,
        value: currentNutrient,
        callback: selectedNutrient,
      ),
    );

    rebuildCharts();
  }

  void rebuildCharts() {
    const int count = 3;
    pieChartData = createPieChartData(currentNutrient);

    pieChart = charts.PieChart(
      pieChartData,
      animate: true,
      // defaultRenderer: new charts.ArcRendererConfig(
      //     arcRendererDecorators: [
      //       new charts.ArcLabelDecorator(
      //           labelPosition:
      //           charts.ArcLabelPosition.auto)
      //     ]),
      defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 60,
          arcRendererDecorators: [
            new charts.ArcLabelDecorator(
                labelPosition: charts.ArcLabelPosition.auto)
          ]),
    );

    barChartData = createBarChartData(currentNutrient);

    barChart = new charts.OrdinalComboChart(
      barChartData,
      animate: true,
      // Configure the default renderer as a bar renderer.
      defaultRenderer: new charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.grouped),
      // Custom renderer configuration for the line series. This will be used for
      // any series that does not define a rendererIdKey.
      customSeriesRenderers: [
        new charts.LineRendererConfig(
          // ID used to link series to this renderer.
            customRendererId: 'customLine')
      ],
    );

    if (listViews.length == 3)
      listViews.removeAt(2);

    if (listViews.length == 2)
      listViews.removeAt(1);

    listViews.add(
      ChartCardView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
            Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
        chart: pieChart,
        title: 'Daily $currentNutrient Source',
      ),
    );

    listViews.add(
      ChartCardView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
            Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
        chart: barChart,
        title: 'Daily $currentNutrient Consumption \n(% DV)',
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NutriscientAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: NutriscientAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: NutriscientAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Statistics',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: NutriscientAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: NutriscientAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            buildButton(
                              buttonText: 'Refresh',
                              callback: () {
                                getVisualizationData().then((value) {
                                  setState(() {
                                    rebuildCharts();
                                  });
                                });
                              },
                              icon: Icons.refresh,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
