import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutriscient/ui/common_widgets.dart';

import '../nutriscient_app_theme.dart';

class SelectNutrientView extends StatefulWidget {
  SelectNutrientView(
      {Key key, this.animationController, this.animation,
        this.callback, this.values, this.value})
      : super(key: key);

  final AnimationController animationController;
  final Animation<dynamic> animation;
  final Function callback;
  final List<String> values;
  final String value;

  @override
  _SelectNutrientViewState createState() => _SelectNutrientViewState();
}

class _SelectNutrientViewState extends State<SelectNutrientView>
    with TickerProviderStateMixin {
  AnimationController animationController;

  Function callback;
  List<String> values;
  String value;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    callback = widget.callback;
    values = widget.values;
    value = widget.value;
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
      animation: widget.animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: buildDropdown(
                values: values,
                dropdownValue: value,
                callback: (String newValue) {
                  setState(() {
                    value = newValue;
                  });
                  if (callback != null)
                    callback(newValue);
                }
              ),
            )
          ),
        );
      },
    );
  }
}