import 'package:nutriscient/main.dart';
import 'package:nutriscient/ui/nutriscient_app_theme.dart';
import 'package:nutriscient/ui/common_widgets.dart';
import 'package:flutter/material.dart';

class EditBoxView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;
  final Function callback;
  final String title;
  final String defaultValue;
  final String hintText;
  final TextEditingController searchTextController = TextEditingController();

  final TextEditingController controllerKBackend = TextEditingController();
  final TextEditingController controllerKScaleId = TextEditingController();

  EditBoxView(
      {Key key,
      this.animationController,
      this.animation,
      this.callback,
      this.title,
      this.defaultValue,
      this.hintText})
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    buildTextField(
                        controller: controllerKBackend,
                        labelText: "Server",
                        defaultText: "127.0.0.1",
                        obscureText: false),
                    buildTextField(
                        controller: controllerKScaleId,
                        labelText: "Scale ID",
                        defaultText: "abcd1234",
                        obscureText: false),
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
