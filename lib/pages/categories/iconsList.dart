import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/categories/iconsRegistry.dart';
import 'package:fund_tracker/shared/styles.dart';

class IconsList extends StatefulWidget {
  @override
  _IconsListState createState() => _IconsListState();
}

class _IconsListState extends State<IconsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Picker'),
      ),
      body: ListView(
        padding: bodyPadding,
        children: <Widget>[
          Wrap(
            children: iconsRegistry
                .map((icon) => IconButton(
                      icon: Icon(icon),
                      onPressed: () {},
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
