import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ContentBox extends StatelessWidget {
  final Widget child;

  const ContentBox({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: kMainBlackColor.withOpacity(0.96),
      ),
      child: child,
    );
  }
}
