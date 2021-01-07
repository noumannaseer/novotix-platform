import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomDialogBox extends StatelessWidget {
  final Widget content;

  const CustomDialogBox({Key key, @required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: kMainBlackColor.withOpacity(0.9),
      content: content,
    );
  }
}

class CustomDialogBoxText extends StatelessWidget {
  final String text;
  const CustomDialogBoxText(
    this.text,
  );

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: kMainTextStyle.copyWith(fontSize: 11.0),
    );
  }
}
