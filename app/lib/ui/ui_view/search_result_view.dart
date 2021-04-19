import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../nutriscient_app_theme.dart';

class SearchResultView extends StatefulWidget {
  SearchResultView(
      {Key key, this.mainScreenAnimationController, this.mainScreenAnimation,
      this.callback})
      : super(key: key);

  final AnimationController mainScreenAnimationController;
  final Animation<dynamic> mainScreenAnimation;
  final Function callback;
  final List<String> imageUrls = <String>[
    'https://spoonacular.com/cdn/ingredients_100x100/apple.jpg',
    'https://spoonacular.com/cdn/ingredients_100x100/beef-cubes-raw.png',
    'https://spoonacular.com/cdn/ingredients_100x100/beef-broth.png',
    'https://spoonacular.com/cdn/ingredients_100x100/ribeye-raw.jpg',
  ];

  final List<String> imageCaptions = <String>[
    'apple', 'beef', 'beef broth', 'beef steak'
  ];

  @override
  _SearchResultViewState createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<String> imageUrls;
  List<String> imageCaptions;
  Function callback;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    callback = widget.callback;
    imageUrls = widget.imageUrls;
    imageCaptions = widget.imageCaptions;
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: GridView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: List<Widget>.generate(
                    imageUrls.length,
                    (int index) {
                      final int count = imageUrls.length;
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
                        imageUrl: imageUrls[index],
                        imageCaption: imageCaptions[index],
                        animation: animation,
                        animationController: animationController,
                        callback: () {callback(index);},
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
                        // padding:
                        //     const EdgeInsets.only(top: 16, left: 16, right: 16),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => CircularProgressIndicator(),
                          imageUrl: imageUrl,
                        ),
                      ),
                      Text(
                        imageCaption,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: NutriscientAppTheme.fontName,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: NutriscientAppTheme.darkText,
                        ),
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
