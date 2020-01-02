import 'package:flutter/material.dart';

void openPage(BuildContext context, Widget page) {
    showDialog(
      context: context,
      builder: (context) {
        return page;
      },
    );
  }