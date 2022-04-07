import 'package:flutter/material.dart';

class DrawerHolder extends StatelessWidget {
  final double width;
  final Widget? child;
  final double? hederHeight;
  const DrawerHolder(
      {Key? key, required this.width, this.child, this.hederHeight})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: double.infinity,
      child: Material(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.only(top: hederHeight ?? 0),
          child: Theme(
            data: ThemeData(brightness: Brightness.dark),
            child: child ?? Container(),
          ),
        ),
      ),
    );
  }
}
