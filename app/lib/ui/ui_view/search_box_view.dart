import 'package:nutriscient/main.dart';
import 'package:nutriscient/ui/nutriscient_app_theme.dart';
import 'package:flutter/material.dart';

class SearchBoxView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;
  final Function callback;
  final TextEditingController searchTextController = TextEditingController();

  SearchBoxView(
      {Key key,
        this.animationController,
        this.animation,
        this.callback})
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
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildComposer(searchTextController)
                    ),
                    Container(
                      // alignment: Alignment.center,s
                      decoration: BoxDecoration(
                        color: NutriscientAppTheme.nearlyDarkBlue,
                        gradient: LinearGradient(
                            colors: [
                              NutriscientAppTheme.nearlyDarkBlue,
                              HexColor('#6A88E5'),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: NutriscientAppTheme.nearlyDarkBlue
                                  .withOpacity(0.4),
                              offset: const Offset(8.0, 16.0),
                              blurRadius: 16.0),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.1),
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onTap: () {
                            if (searchTextController.text != "")
                              this.callback(searchTextController.text);
                          },
                          child: Icon(
                            Icons.search,
                            color: NutriscientAppTheme.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

Widget _buildComposer(TextEditingController searchTextController) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
    child: Container(
      decoration: BoxDecoration(
        color: NutriscientAppTheme.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.8),
              offset: const Offset(4, 4),
              blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(4.0),
          constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
          color: NutriscientAppTheme.white,
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
            child: TextField(
              maxLines: null,
              onChanged: (String txt) {},
              style: TextStyle(
                fontFamily: NutriscientAppTheme.fontName,
                fontSize: 16,
                color: NutriscientAppTheme.dark_grey,
              ),
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter an ingredient name...'),
              controller: searchTextController,
            ),
          ),
        ),
      ),
    ),
  );
}
