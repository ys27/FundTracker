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
      body: Container(
        padding: formPadding,
        child: ListView.builder(
          itemBuilder: (context, index) => IconButton(
            icon: Icon(iconsRegistry[index]),
            onPressed: () {},
          ),
          itemCount: iconsRegistry.length,
        ),
      ),
    );
  }
}
