import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/pages/categories/iconsRegistry.dart';
import 'package:fund_tracker/shared/library.dart';

int numIconsPerPage = 60;

class IconsList extends StatefulWidget {
  @override
  _IconsListState createState() => _IconsListState();
}

class _IconsListState extends State<IconsList> {
  int indexStart = 0;
  int indexEnd = numIconsPerPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Picker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Wrap(
            children: iconsRegistry
                .sublist(indexStart, min(indexEnd, iconsRegistry.length))
                .map(
                  (icon) => IconButton(
                    icon: Icon(icon),
                    onPressed: () => Navigator.of(context).pop(icon.codePoint),
                  ),
                )
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(CommunityMaterialIcons.arrow_left),
                        onPressed: () {
                          setState(() {
                            indexStart = indexStart - numIconsPerPage;
                            indexEnd = indexEnd - numIconsPerPage;
                          });
                        }),
                    IconButton(
                        icon: Icon(CommunityMaterialIcons.arrow_right),
                        onPressed: () {
                          setState(() {
                            indexStart = indexStart + numIconsPerPage;
                            indexEnd = indexEnd + numIconsPerPage;
                          });
                        }),
                  ],
                ),
                Text(
                  'Page ${(indexStart / numIconsPerPage + 1).toInt()}/${(iconsRegistry.length / numIconsPerPage + 1).toInt()}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
