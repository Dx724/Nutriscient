import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../nutriscient_app_theme.dart';

class TemplateView extends StatefulWidget {
  TemplateView(
      {Key key, this.mainScreenAnimationController, this.mainScreenAnimation,
      this.replaceMeCallBack, this.replaceMeParam, this.replaceMeParam2, this.replaceMeParam3})
      : super(key: key);

  final AnimationController mainScreenAnimationController;
  final Animation<dynamic> mainScreenAnimation;
  final Function replaceMeCallBack;
  final List<String> replaceMeParam;
  final List<String> replaceMeParam2;
  final List<int> replaceMeParam3;

  @override
  _TemplateViewState createState() => _TemplateViewState();
}

class _TemplateViewState extends State<TemplateView>
    with TickerProviderStateMixin {
  AnimationController animationController;

  Function replaceMeCallback;
  List<String> replaceMeParam1;
  List<String> replaceMeParam2;
  List<int> replaceMeParam3;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    replaceMeCallback = widget.replaceMeCallBack;
    replaceMeParam1 = widget.replaceMeParam;
    replaceMeParam2 = widget.replaceMeParam2;
    replaceMeParam3 = widget.replaceMeParam3;
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = 2 / ((replaceMeParam1.length / 2).ceil()); // 2 column, len/2 rows
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation.value), 0.0),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: GridView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 24, bottom: 24),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: List<Widget>.generate(
                    replaceMeParam1.length,
                    (int index) {
                      final int count = replaceMeParam1.length;
                      final Animation<double> animation =
                          Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animationController,
                          curve: Interval((1 / count) * index, 1.0,
                              curve: Curves.fastOutSlowIn),
                        ),
                      );
                      animationController.forward();
                      return AreaView(
                        imageUrl: replaceMeParam1[index],
                        imageCaption: replaceMeParam2[index],
                        animation: animation,
                        animationController: animationController,
                        callback: () {replaceMeCallback(replaceMeParam3[index]);},
                      );
                    },
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24.0,
                    crossAxisSpacing: 24.0,
                    childAspectRatio: 1.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AreaView extends StatelessWidget {
  const AreaView({
    Key key,
    this.imageUrl,
    this.imageCaption,
    this.animationController,
    this.animation,
    this.callback,
  }) : super(key: key);

  final String imageUrl;
  final String imageCaption;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: NutriscientAppTheme.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: NutriscientAppTheme.grey.withOpacity(0.4),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  splashColor: NutriscientAppTheme.nearlyDarkBlue.withOpacity(0.2),
                  onTap: () {callback();},
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: CachedNetworkImage(
                          // placeholder: (context, url) => CircularProgressIndicator(),
                          imageUrl: imageUrl,
                        ),
                      ),
                      Text(
                        imageCaption,
                        textAlign: TextAlign.center,
                        style: NutriscientAppTheme.captionBig,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
