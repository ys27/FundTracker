import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';

class SuggestionsList extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  SuggestionsList({this.user, this.openPage});

  @override
  _SuggestionsListState createState() => _SuggestionsListState();
}

class _SuggestionsListState extends State<SuggestionsList> {
  List<Transaction> _transactions;
  List<Category> _categories;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();

    if (_transactions != null && _categories != null) {
      if (_transactions.length == 0) {
        _body = Center(
          child: Text('There are no suggestions.'),
        );
      } else {
        List<Map<String, dynamic>> suggestionsWithCount =
            getSuggestionsWithCount(_transactions);
        suggestionsWithCount.sort((a, b) => b['count'].compareTo(a['count']));
        _body = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: suggestionsWithCount.length,
            itemBuilder: (context, index) => suggestionCard(
              context,
              suggestionsWithCount[index],
              () => retrieveNewData(widget.user.uid),
            ),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(user: widget.user, openPage: widget.openPage),
      appBar: AppBar(title: Text('Suggestions')),
      body: _body,
    );
  }

  Widget suggestionCard(BuildContext context, Map<String, dynamic> suggestion,
      Function refreshList) {
    Category category =
        _categories.singleWhere((cat) => cat.cid == suggestion['cid']);
    return Card(
      child: CheckboxListTile(
        secondary: CircleAvatar(
          radius: 25.0,
          backgroundColor: Theme.of(context).backgroundColor,
          child: Icon(
            IconData(
              category.icon,
              fontFamily: 'MaterialDesignIconFont',
              fontPackage: 'community_material_icon',
            ),
            color: category.iconColor,
          ),
        ),
        title: Text(suggestion['payee']),
        subtitle: Text(category.name),
        value: true,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (val) async {
          // setState(() => category.unfiltered = val);
        },
      ),
    );
  }

  void retrieveNewData(String uid) async {
    List<Transaction> transactions =
        await DatabaseWrapper(uid).getTransactions();
    List<Category> categories = await DatabaseWrapper(uid).getCategories();
    setState(() {
      _transactions = transactions;
      _categories = categories;
    });
  }
}
