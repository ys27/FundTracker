import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/pages/categories/iconsList.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/services/sync.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoryForm extends StatefulWidget {
  final Category category;
  final int numExistingCategories;
  final bool isUsed;
  final String uid;

  CategoryForm({
    this.category,
    this.numExistingCategories,
    this.isUsed = false,
    this.uid,
  });

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final FocusNode _nameFocus = new FocusNode();

  bool _isNameInFocus = false;

  String _name;
  int _icon;
  Color _iconColor;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.category.name ?? '';
    _icon = widget.category.icon;
    _iconColor = widget.category.iconColor;

    _nameController.text = widget.category.name;

    _nameFocus.addListener(_checkFocus);
  }

  void _checkFocus() {
    setState(() {
      _isNameInFocus = _nameFocus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseAuthentication.User>(context);
    final isEditMode =
        !widget.category.equalTo(Category.empty(widget.numExistingCategories));
    return widget.isUsed != null
        ? Scaffold(
            appBar: AppBar(
              title: title(isEditMode),
              actions: isEditMode && !widget.isUsed
                  ? <Widget>[
                      DeleteIcon(
                        context,
                        itemDesc: 'category',
                        deleteFunction: () => DatabaseWrapper(_user.uid)
                            .deleteCategories([widget.category]),
                        syncFunction: SyncService(_user.uid).syncCategories,
                      )
                    ]
                  : null, // add reset category here for defaults
            ),
            body: isLoading
                ? Loader()
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: formPadding,
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Enter a name for this category.';
                            }
                            return null;
                          },
                          decoration: clearInput(
                            labelText: 'Name',
                            enabled: _name.isNotEmpty && _isNameInFocus,
                            onPressed: () {
                              setState(() => _name = '');
                              _nameController.safeClear();
                            },
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
                                  _icon,
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
                            if (icon != null) {
                              setState(() => _icon = icon);
                            }
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
                                color: _iconColor,
                              ),
                            ],
                          ),
                          onPressed: () async {
                            Color color = await showDialog(
                              context: context,
                              builder: (context) {
                                return categoryColorPicker(
                                  context,
                                  _iconColor,
                                );
                              },
                            );
                            if (color != null) {
                              setState(() => _iconColor = color);
                            }
                          },
                        ),
                        SizedBox(height: 10.0),
                        Icon(
                          IconData(
                            _icon,
                            fontFamily: 'MaterialDesignIconFont',
                            fontPackage: 'community_material_icon',
                          ),
                          color: _iconColor,
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
                                name: _name,
                                icon: _icon,
                                iconColor: _iconColor,
                                enabled: widget.category.enabled ?? true,
                                unfiltered: widget.category.unfiltered ?? true,
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

extension on TextEditingController {
  void safeClear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.clear();
    });
  }
}
