import 'package:flutter/material.dart';

import 'package:nutriscient/main.dart';
import 'package:nutriscient/ui/nutriscient_app_theme.dart';

class ChartCardView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;
  final Widget chart;

  ChartCardView({Key key, this.animationController, this.animation, this.chart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 0, bottom: 24),
                  child: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor("#D7E0F9"),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topRight: Radius.circular(8.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color:
                                      NutriscientAppTheme.grey.withOpacity(0.2),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 10.0),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, bottom: 12, right: 12, top: 12),
                                child: Text(
                                  'Text Here',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: NutriscientAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    letterSpacing: 0.0,
                                    color: NutriscientAppTheme.nearlyDarkBlue
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                              SizedBox(
                                // Chart width and height
                                width: 0.8 * MediaQuery.of(context).size.width,
                                height: 0.8 * MediaQuery.of(context).size.width,
                                child: this.chart,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
