import 'package:intl/intl.dart';
import 'package:nutriscient/ui/common_widgets.dart';
import 'package:nutriscient/ui/nutriscient_app_theme.dart';
import 'package:nutriscient/ui/ui_view/search_box_view.dart';
import 'package:nutriscient/ui/ui_view/title_view.dart';
import 'package:nutriscient/ui/ui_view/search_result_view.dart';
import 'package:nutriscient/util/backend.dart';
import 'package:nutriscient/util/constants.dart';
import 'package:nutriscient/util/spoonacular_api.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key key, this.animationController}) : super(key: key);

  final AnimationController animationController;

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  Animation<double> topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  List<String> imageUrls, imageCaptions;
  List<int> itemIds;
  Widget searchResultViewWidget;

  String rfidToRegister = '';
  String titleText = 'Adding a new ingredient';

  Future<void> checkUnregistered() async {
    if (listViews.length == 3) {
      setState(() {
        Navigator.pushNamed(context, '/');
      });
    }
    getUnregistered().then((result) {
      print("$result");
      if (result['exist']) {
        setState(() {
          String placedTime = readTimestamp(result['time'].toInt());
          titleText = 'Register an ingredient placed on the scale';
          rfidToRegister = result['rfid'];
        });
      }
    });
  }

  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('HH:mm a');
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + 'DAY AGO';
      } else {
        time = diff.inDays.toString() + 'DAYS AGO';
      }
    }

    return time;
  }

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

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
    checkUnregistered().then((value) {
      addAllListData();
    });
  }

  // void addTitle() {
  //   int count = 3;
  //   listViews.insert(0,
  //   );
  // }
  Future<String> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'error: Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return 'error: Widget removed';
    return barcodeScanRes;
  }

  void addAllListData() {
    const int count = 3;

    if (listViews.length != 0) {
      listViews[0] = TitleView(
        // titleTxt: 'Adding a new ingredient',
        titleTxt: titleText,
        subTxt: 'Scan',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
        icon: Icons.qr_code_scanner,
        callback: () {
          scanBarcodeNormal().then((value) {
            if (value.startsWith('error:')) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content:
                      Text("Barcode scan\b$value"),
                    );
                  });
            } else if (value == '-1') {
              print("Barcode scan cancelled");
            } else {
              barcodeProductSearch(value).then((value) {
                String message = 'Result: Not found';
                if (value.length != 0)
                  message = "Result: $value";
                  showMessage(context, message);
              });
            }
          });
        },
      );
      return;
    }

    //
    // if (listViews.length == 1)
    //   listViews.removeAt(0);

    listViews.add(TitleView(
      // titleTxt: 'Adding a new ingredient',
      titleTxt: titleText,
      subTxt: 'Help',
      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
      animationController: widget.animationController,
      callback: () {
        debugPrint("Show help");
      },
    ));

    listViews.add(
      SearchBoxView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
        callback: (String searchTxt) {
          search(searchTxt);
        },
      ),
    );
  }

  void search(String searchText) async {
    print("Search");
    var results = await searchIngredient(searchText);
    if (results.length != 0)
      buildSearchResults(results);
    else
      showMessage(context, "Cannot find $searchText\n\nPress anywhere to continue");
  }

  void resultSelected(int index) async {
    debugPrint("[$kScaleId]: RFID [$rfidToRegister] --> $index");
    registerRfid(rfidToRegister, index).then((value) => checkUnregistered());
  }

  void buildSearchResults(List results) {
    imageUrls = List<String>.generate(
      results.length,
      (int index) {
        return 'https://spoonacular.com/cdn/ingredients_100x100/${results[index]['image']}';
      },
    );

    imageCaptions = List<String>.generate(results.length, (int index) {
      return results[index]['name'];
    });

    itemIds = List<int>.generate(results.length, (int index) {
      return results[index]['id'];
    });

    const int count = 3;
    setState(() {
      if (listViews.length == 3) {
        listViews.removeAt(2);
      }
      listViews.add(
        SearchResultView(
          mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 2, 1.0,
                      curve: Curves.fastOutSlowIn))),
          mainScreenAnimationController: widget.animationController,
          callback: resultSelected,
          imageUrls: imageUrls,
          imageCaptions: imageCaptions,
          itemIds: itemIds,
        ),
      );
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    addAllListData();

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
                                  'Register Ingredient',
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
