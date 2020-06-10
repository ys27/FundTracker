import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';

class FilterTile extends StatefulWidget {
  final Category category;
  final Map<String, dynamic> otherMap;
  final int numCategories;
  final Function setModified;

  FilterTile(
      {this.category, this.otherMap, this.numCategories, this.setModified});

  @override
  _FilterTileState createState() => _FilterTileState();
}

class _FilterTileState extends State<FilterTile> {
  @override
  Widget build(BuildContext context) {
    bool isCategory = widget.category != null;
    return CheckboxListTile(
      key: Key(isCategory
          ? widget.category.orderIndex.toString()
          : widget.otherMap['name'].toString().toLowerCase()),
      title: Row(
        children: <Widget>[
          isCategory
              ? Icon(
                  IconData(
                    widget.category.icon,
                    fontFamily: 'MaterialDesignIconFont',
                    fontPackage: 'community_material_icon',
                  ),
                  color: widget.category.iconColor,
                )
              : Icon(
                  widget.otherMap['icon'],
                  color: widget.otherMap['iconColor'],
                ),
          SizedBox(width: 25.0),
          Text(isCategory ? widget.category.name : widget.otherMap['name']),
        ],
      ),
      value: isCategory
          ? widget.category.unfiltered
          : widget.otherMap['unfiltered'],
      activeColor: Theme.of(context).primaryColor,
      onChanged: (val) async {
        setState(() => isCategory
            ? widget.category.unfiltered = val
            : widget.otherMap['unfiltered'] = val);
        if (!isCategory) {
          widget.otherMap['setUnfilteredState'](val);
        }
        widget.setModified();
      },
    );
  }
}
