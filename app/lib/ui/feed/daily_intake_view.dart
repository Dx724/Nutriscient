import 'dart:math';

import 'package:nutriscient/ui/nutriscient_app_theme.dart';
import 'package:nutriscient/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:nutriscient/util/constants.dart';

class DailyIntakeView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  Map data;
  int caloriesConsumed, caloriesLeft, sugarConsumed, carbsLeft, proteinLeft, fatLeft;
  double carbsPercentage, proteinPercentage, fatPercentage;

  DailyIntakeView(
      {Key key, this.animationController, this.animation, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    caloriesConsumed = max(data['calories'].toInt(), 0);
    caloriesLeft = max(kCaloriesTotal - caloriesConsumed.toInt(), 0);
    sugarConsumed = max(data['sugar'].toInt(), 0);

    carbsLeft = max(kCarbsTotal - data['carbs'].toInt(), 0);
    carbsPercentage = 1 - (carbsLeft / kCarbsTotal);
    proteinLeft = max(kProteinTotal - data['protein'].toInt(), 0);
    proteinPercentage = 1 - (proteinLeft / kProteinTotal);
    fatLeft = max(kFatTotal - data['fat'].toInt(), 0);
    fatPercentage = 1 - (fatLeft / kFatTotal);

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: NutriscientAppTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: NutriscientAppTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    buildTopSection(),
                    buildDivider(),
                    buildBottomSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTopSection() {
    return Padding(
      padding:
      const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8, right: 8, top: 4),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 48,
                        width: 2,
                        decoration: BoxDecoration(
                          color: HexColor('#87A0E5')
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.all(
                              Radius.circular(4.0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, bottom: 2),
                              child: Text(
                                'Calories',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily:
                                  NutriscientAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: -0.1,
                                  color: NutriscientAppTheme.grey
                                      .withOpacity(0.5),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Image.asset(
                                      "assets/images/calories.png"),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 4, bottom: 3),
                                      child: Text(
                                        '${(caloriesConsumed * animation.value).toInt()}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                          NutriscientAppTheme
                                              .fontName,
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize: 16,
                                          color: NutriscientAppTheme
                                              .darkerText,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 4, bottom: 3),
                                      child: Text(
                                        'Kcal',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                          NutriscientAppTheme
                                              .fontName,
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize: 12,
                                          letterSpacing: -0.2,
                                          color: NutriscientAppTheme
                                              .grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: 48,
                        width: 2,
                        decoration: BoxDecoration(
                          color: HexColor('#F56E98')
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.all(
                              Radius.circular(4.0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, bottom: 2),
                              child: Text(
                                'Sugar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily:
                                  NutriscientAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: -0.1,
                                  color: NutriscientAppTheme.grey
                                      .withOpacity(0.5),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Image.asset(
                                      "assets/images/sugar.png"),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 4, bottom: 3),
                                      child: Text(
                                        '${(sugarConsumed * animation.value).toInt()}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                          NutriscientAppTheme
                                              .fontName,
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize: 16,
                                          color: NutriscientAppTheme
                                              .darkerText,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 8, bottom: 3),
                                      child: Text(
                                        'grams',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                          NutriscientAppTheme
                                              .fontName,
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize: 12,
                                          letterSpacing: -0.2,
                                          color: NutriscientAppTheme
                                              .grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: NutriscientAppTheme.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(100.0),
                        ),
                        border: new Border.all(
                            width: 4,
                            color: NutriscientAppTheme
                                .nearlyDarkBlue
                                .withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${(caloriesLeft * animation.value).toInt()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily:
                              NutriscientAppTheme.fontName,
                              fontWeight: FontWeight.normal,
                              fontSize: 24,
                              letterSpacing: 0.0,
                              color: NutriscientAppTheme
                                  .nearlyDarkBlue,
                            ),
                          ),
                          Text(
                            'Kcal left',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily:
                              NutriscientAppTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.0,
                              color: NutriscientAppTheme.grey
                                  .withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CustomPaint(
                      painter: CurvePainter(
                          colors: [
                            NutriscientAppTheme.nearlyDarkBlue,
                            HexColor("#8A98E8"),
                            HexColor("#8A98E8")
                          ],
                          angle: 140 +
                              (360 - 140) *
                                  (1.0 - animation.value)),
                      child: SizedBox(
                        width: 108,
                        height: 108,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 24, right: 24, top: 8, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Carbs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: NutriscientAppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.2,
                    color: NutriscientAppTheme.darkText,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      color:
                      HexColor('#87A0E5').withOpacity(0.2),
                      borderRadius: BorderRadius.all(
                          Radius.circular(4.0)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: ((70 * carbsPercentage) * animation.value),
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              HexColor('#87A0E5'),
                              HexColor('#87A0E5')
                                  .withOpacity(0.5),
                            ]),
                            borderRadius: BorderRadius.all(
                                Radius.circular(4.0)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${carbsLeft}g left',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: NutriscientAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:
                      NutriscientAppTheme.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Protein',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: NutriscientAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: -0.2,
                        color: NutriscientAppTheme.darkText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        height: 4,
                        width: 70,
                        decoration: BoxDecoration(
                          color: HexColor('#F56E98')
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.all(
                              Radius.circular(4.0)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: ((70 * proteinPercentage) *
                                  animationController.value),
                              height: 4,
                              decoration: BoxDecoration(
                                gradient:
                                LinearGradient(colors: [
                                  HexColor('#F56E98')
                                      .withOpacity(0.1),
                                  HexColor('#F56E98'),
                                ]),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(4.0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${proteinLeft}g left',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: NutriscientAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: NutriscientAppTheme.grey
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Fat',
                      style: TextStyle(
                        fontFamily: NutriscientAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: -0.2,
                        color: NutriscientAppTheme.darkText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 0, top: 4),
                      child: Container(
                        height: 4,
                        width: 70,
                        decoration: BoxDecoration(
                          color: HexColor('#F1B440')
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.all(
                              Radius.circular(4.0)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: ((70 * fatPercentage) *
                                  animationController.value),
                              height: 4,
                              decoration: BoxDecoration(
                                gradient:
                                LinearGradient(colors: [
                                  HexColor('#F1B440')
                                      .withOpacity(0.1),
                                  HexColor('#F1B440'),
                                ]),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(4.0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${fatLeft}g left',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: NutriscientAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: NutriscientAppTheme.grey
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 24, right: 24, top: 8, bottom: 8),
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: NutriscientAppTheme.background,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double angle;
  final List<Color> colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = List<Color>();
    if (colors != null) {
      colorsList = colors;
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        new Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}
