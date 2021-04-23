import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nutriscient/ui/feed/FeedScreen.dart';
import 'package:nutriscient/ui/models/tabIcon_data.dart';
import 'package:nutriscient/ui/traning/training_screen.dart';
import 'package:flutter/material.dart';
import 'package:nutriscient/util/fcm.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'nutriscient_app_theme.dart';

import 'list/ingredients_list_screen.dart';
import 'register/register_screen.dart';
import 'visualize/visualize_screen.dart';
import 'setting/setting_screen.dart';

class NutriscientHomeScreen extends StatefulWidget {
  const NutriscientHomeScreen({Key key, this.redirectTo}) : super(key: key);
  final String redirectTo;

  @override
  _NutriscientHomeScreenState createState() => _NutriscientHomeScreenState();
}

class _NutriscientHomeScreenState extends State<NutriscientHomeScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: NutriscientAppTheme.background,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    if (widget.redirectTo == null)
      tabBody = FeedScreen(animationController: animationController);
    else if (widget.redirectTo == 'register')
      tabBody = RegisterScreen(animationController: animationController);
    else if (widget.redirectTo == 'list')
      tabBody = IngredientsListScreen(animationController: animationController);
    else
      throw Exception('Invalid redirectTo parameter: ${widget.redirectTo}');

    super.initState();

    setupFcmCallbacks(context);
    updatePushNotiSubscription(true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NutriscientAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            animationController.reverse().then<dynamic>((data) {
              if (!mounted) return;
              setState(() {
                tabBody =
                    RegisterScreen(animationController: animationController);
              });
            });
          },
          changeIndex: (int index) {
            animationController.reverse().then<dynamic>((data) {
              if (!mounted) {
                return;
              }
              setState(() {
                switch (index) {
                  case 0:
                    tabBody =
                        FeedScreen(animationController: animationController);
                    break;

                  case 1:
                    tabBody = IngredientsListScreen(
                        animationController: animationController);
                    break;

                  case 2:
                    tabBody = VisualizeScreen(
                        animationController: animationController);
                    break;

                  case 3:
                    tabBody = SettingScreen(
                        animationController: animationController);
                    break;

                  default:
                    debugPrint("Index error");
                    break;
                }
              });
            });
          },
        ),
      ],
    );
  }
}
