import 'package:flutter/material.dart';
import '../constants/constants.dart';

Widget addVerticalSpace(double height) {
  return SizedBox(
    height: height,
  );
}


Widget addHorizontalSpace(double width) {
  return SizedBox(
    width: width,
  );
}

Future<dynamic> customDialog(
    {required BuildContext context,
      required Widget widget,
      insetPadding = appPadding}) {
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          insetPadding: EdgeInsets.all(insetPadding),
          child: Container(child: widget),
        );
      });
}

Widget loadingWidget() {
  return const Center(
    child: RefreshProgressIndicator(),
  );
}