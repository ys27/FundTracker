import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoryForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:provider/provider.dart';

class CategoryTile extends StatefulWidget {
  final Category category;
  final int numCategories;
  final Function refreshList;

  CategoryTile({this.category, this.numCategories, this.refreshList});

  @override
  _CategoryTileState createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseAuthentication.User>(context);

    return ListTile(
      title: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              IconData(
                widget.category.icon,
                fontFamily: 'MaterialDesignIconFont',
                fontPackage: 'community_material_icon',
              ),
              color: widget.category.iconColor,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 25.0),
                  Text(widget.category.name),
                ],
              ),
            ),
            Checkbox(
              value: widget.category.enabled,
              activeColor: (widget.category.isNamedOthers()
                  ? Colors.grey
                  : Theme.of(context).primaryColor),
              onChanged: (val) async {
                if (!widget.category.isNamedOthers()) {
                  setState(() => widget.category.enabled = val);
                  await DatabaseWrapper(_user.uid)
                      .updateCategories([widget.category]);
                }
              },
            ),
          ],
        ),
        onTap: () async {
          if (!widget.category.isNamedOthers()) {
            List<Transaction> transactions =
                await DatabaseWrapper(_user.uid).getTransactions();
            bool _isCategoryInUse =
                transactions.any((tx) => tx.cid == widget.category.cid);
            await showDialog(
              context: context,
              builder: (context) {
                return CategoryForm(
                  category: widget.category,
                  numExistingCategories: widget.numCategories,
                  uid: _user.uid,
                  isUsed: _isCategoryInUse,
                );
              },
            );
            widget.refreshList();
          }
        },
      ),
    );
  }
}
