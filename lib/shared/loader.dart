import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).primaryColor,
      child: Center(
        child: SpinKitPulse(
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
