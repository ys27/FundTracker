import 'package:flutter/material.dart';

void openPage(BuildContext context, Widget page) {
  goHome(context);
  showDialog(
    context: context,
    builder: (context) {
      return page;
    },
  );
}

void goHome(BuildContext context) {
  Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
  Navigator.popAndPushNamed(context, Navigator.defaultRouteName);
}