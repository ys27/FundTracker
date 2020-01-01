import 'package:flutter/material.dart';

Function openPage(BuildContext context, Widget page) {
    showDialog(
      context: context,
      builder: (context) {
        return page;
      },
    );
  }