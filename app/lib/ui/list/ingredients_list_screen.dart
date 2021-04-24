import 'dart:math';

import 'package:nutriscient/ui/common_widgets.dart';
import 'package:nutriscient/ui/nutriscient_app_theme.dart';
import 'package:nutriscient/ui/ui_view/title_view.dart';
import 'package:nutriscient/ui/list/table_view.dart';
import 'package:nutriscient/ui/models/row_data.dart';
import 'package:flutter/material.dart';
import 'package:nutriscient/util/data.dart';

class IngredientsListScreen extends StatefulWidget {
  const IngredientsListScreen({Key key, this.animationController}) : super(key: key);

  final AnimationController animationController;

  @override
  _IngredientsListScreenState createState() => _IngredientsListScreenState();
}

class _IngredientsListScreenState extends State<IngredientsListScreen>
    with TickerProviderStateMixin {
  Animation<double> topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  List<IngredientRow> ingredientTableData;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

        ingredientTableData = _buildIngredientList();
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

  void addAllListData() {
    const int count = 2;
    listViews = [];

    listViews.add(
      TitleView(
        titleTxt: ingredientTableData.length == 0 ? 'Start tracking by adding an item' : 'Time for some restocking?',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );

    listViews.add(
      TableView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
            Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
        data: ingredientTableData,
      ),
    );
  }

  Future<bool> getData() async {
    // await getIngredientData();
    return true;
  }

  List<IngredientRow> _buildIngredientList() {
    List<IngredientRow> ret = [];
    for (int i = 0; i < ingredientsList.length; i++) {
      String name = ingredientsList[i]['name'];
      double consumed = ingredientsList[i]['last_refill'] - ingredientsList[i]['recent_weight'];
      double lastRefillTime = ingredientsList[i]['latest_refill_time'];
      ret.add(
        IngredientRow(name, consumed, lastRefillTime)
      );
    }
    return ret;
    
    return [
      IngredientRow('salt', 300, 30),
      IngredientRow('pepper', 50, 50),
      IngredientRow('beef', 500, 90),
      IngredientRow('chicken', 200, 100),
    ];
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
                                  'Ingredients',
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
                            // buildButton(
                            //   buttonText: 'Refresh',
                            //   callback: () {
                            //     getIngredientsListData().then((value) {
                            //       setState(() {
                            //         ingredientTableData = _buildIngredientList();
                            //         addAllListData();
                            //       });
                            //       // ingredientTableData = _buildIngredientList();
                            //       // addAllListData();
                            //     });
                            //   },
                            //   icon: Icons.refresh,
                            // )
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