import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/iconsList.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoryForm extends StatefulWidget {
  final Category category;
  final int numExistingCategories;
  final String uid;

  CategoryForm(this.category, this.numExistingCategories, {this.uid});

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  int _icon;
  Color _iconColor;
  bool _isCategoryInUse;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      DatabaseWrapper(widget.uid).getTransactions().then((transactions) {
        setState(() => _isCategoryInUse =
            transactions.any((tx) => tx.cid == widget.category.cid));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);
    final isEditMode =
        !widget.category.equalTo(Category.empty(widget.numExistingCategories));

    return _isCategoryInUse != null
        ? Scaffold(
            appBar: AppBar(
              title: title(isEditMode),
              actions: isEditMode && !_isCategoryInUse
                  ? <Widget>[
                      deleteIcon(
                        context,
                        'category',
                        () => DatabaseWrapper(_user.uid)
                            .deleteCategories([widget.category]),
                        () => SyncService(_user.uid).syncCategories(),
                      )
                    ]
                  : null, // add reset category here for defaults
            ),
            body: isLoading
                ? Loader()
                : Container(
                    padding: formPadding,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(height: 10.0),
                          TextFormField(
                            initialValue: widget.category.name,
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter a name for this category.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Name',
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (val) {
                              setState(() => _name = val);
                            },
                          ),
                          SizedBox(height: 10.0),
                          FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Icon'),
                                Icon(
                                  IconData(
                                    _icon ?? widget.category.icon,
                                    fontFamily: 'MaterialDesignIconFont',
                                    fontPackage: 'community_material_icon',
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              int icon = await showDialog(
                                context: context,
                                builder: (context) {
                                  return IconsList();
                                },
                              );
                              setState(() => _icon = icon);
                            },
                          ),
                          SizedBox(height: 10.0),
                          FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Icon Color'),
                                Icon(
                                  CommunityMaterialIcons.circle,
                                  color:
                                      _iconColor ?? widget.category.iconColor,
                                ),
                              ],
                            ),
                            onPressed: () async {
                              Color color = await showDialog(
                                context: context,
                                builder: (context) {
                                  return categoryColorPicker(
                                    context,
                                    _iconColor ?? widget.category.iconColor,
                                  );
                                },
                              );
                              setState(() => _iconColor = color);
                            },
                          ),
                          SizedBox(height: 10.0),
                          Icon(
                            IconData(
                              _icon ?? widget.category.icon,
                              fontFamily: 'MaterialDesignIconFont',
                              fontPackage: 'community_material_icon',
                            ),
                            color: _iconColor ?? widget.category.iconColor,
                          ),
                          SizedBox(height: 10.0),
                          RaisedButton(
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              isEditMode ? 'Save' : 'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                Category category = Category(
                                  cid: widget.category.cid ?? Uuid().v1(),
                                  name: _name ?? widget.category.name,
                                  icon: _icon ?? widget.category.icon,
                                  iconColor:
                                      _iconColor ?? widget.category.iconColor,
                                  enabled: widget.category.enabled ?? true,
                                  unfiltered:
                                      widget.category.unfiltered ?? true,
                                  orderIndex: widget.category.orderIndex ??
                                      widget.numExistingCategories,
                                  uid: _user.uid,
                                );
                                setState(() => isLoading = true);
                                isEditMode
                                    ? await DatabaseWrapper(_user.uid)
                                        .updateCategories([category])
                                    : await DatabaseWrapper(_user.uid)
                                        .addCategories([category]);
                                SyncService(_user.uid).syncPeriods();
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          )
        : Container();
  }

  Widget title(bool isEditMode) {
    return Text(isEditMode ? 'Edit Category' : 'Add Category');
  }
}

Widget categoryColorPicker(BuildContext context, Color currentColor) {
  Color pickerColor;

  return Scaffold(
    appBar: AppBar(
      title: Text('Icon Color Picker'),
    ),
    body: Container(
      padding: formPadding,
      child: Column(
        children: <Widget>[
          ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (val) => pickerColor = val,
            showLabel: true,
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              'Select',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(pickerColor),
          )
        ],
      ),
    ),
  );
}
