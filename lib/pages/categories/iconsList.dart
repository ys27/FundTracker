import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/categories/iconsRegistry.dart';

class IconsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Picker'),
      ),
      body: GridView.count(
        crossAxisCount: 8,
        children: iconsRegistry
            .map(
              (icon) => IconButton(
                icon: Icon(icon),
                onPressed: () => Navigator.of(context).pop(icon.codePoint),
              ),
            )
            .toList(),
      ),
    );
  }
}
