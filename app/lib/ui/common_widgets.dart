import 'package:flutter/material.dart';
import 'package:nutriscient/ui/nutriscient_app_theme.dart';

Container buildDivider() {
  return Container(
    margin: const EdgeInsets.symmetric(
      horizontal: 8.0,
    ),
    width: double.infinity,
    height: 1.0,
    color: Colors.grey.shade400,
  );
}

Widget buildTextField(
    {TextEditingController controller,
    String labelText,
    String defaultText,
    bool obscureText,
    Function callback}) {
  Widget field = Padding(
    padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
    child: TextField(
      controller: controller,
      onChanged: (String value) {
        if (callback != null) callback(value);
      },
      obscureText: obscureText,
      decoration: InputDecoration(
          suffixIcon: null,
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          // hintText: placeholder,
          hintStyle: NutriscientAppTheme.caption),
    ),
  );

  if (defaultText != null) controller.text = defaultText;
  return field;
}

Widget buildEditShadowBox(TextEditingController editorTextController) {
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
              controller: editorTextController,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildTitle(String titleText) {
  return Text(
    titleText,
    textAlign: TextAlign.left,
    style: TextStyle(
      fontFamily: NutriscientAppTheme.fontName,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      letterSpacing: 0.5,
      color: NutriscientAppTheme.lightText,
    ),
  );
}

Widget buildButton(String buttonText, Function callback) {
  return InkWell(
    highlightColor: Colors.transparent,
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
    onTap: () {
      callback();
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: <Widget>[
          Text(
            buttonText,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: NutriscientAppTheme.fontName,
              fontWeight: FontWeight.normal,
              fontSize: 16,
              letterSpacing: 0.5,
              color: NutriscientAppTheme.nearlyDarkBlue,
            ),
          ),
          SizedBox(
            height: 38,
            width: 26,
            child: Icon(
              Icons.arrow_forward,
              color: NutriscientAppTheme.darkText,
              size: 18,
            ),
          ),
        ],
      ),
    ),
  );
}
