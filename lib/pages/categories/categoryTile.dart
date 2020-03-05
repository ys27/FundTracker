import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/categoryForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:provider/provider.dart';

class CategoryTile extends StatefulWidget {
  final Category category;
  final int numCategories;

  CategoryTile(
    this.category, {
    this.numCategories,
  });

  @override
  _CategoryTileState createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return CheckboxListTile(
      title: GestureDetector(
        child: Row(
          children: <Widget>[
            Icon(
              IconData(
                widget.category.icon,
                fontFamily: 'MaterialIcons',
              ),
              color: widget.category.iconColor,
            ),
            SizedBox(width: 25.0),
            Text(widget.category.name),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return CategoryForm(widget.category, widget.numCategories);
            },
          );
        },
      ),
      value: widget.category.enabled,
      activeColor: (widget.category.name == 'Others'
          ? Colors.grey
          : Theme.of(context).primaryColor),
      onChanged: (val) async {
        if (widget.category.name != 'Others') {
          setState(() => widget.category.enabled = val);
          await DatabaseWrapper(_user.uid)
              .updateCategories([widget.category.setEnabled(val)]);
        }
      },
    );
  }
}
