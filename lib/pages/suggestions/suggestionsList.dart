import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';

class SuggestionsList extends StatefulWidget {
  final FirebaseAuthentication.User user;
  final Function openPage;

  SuggestionsList({this.user, this.openPage});

  @override
  _SuggestionsListState createState() => _SuggestionsListState();
}

class _SuggestionsListState extends State<SuggestionsList> {
  List<Transaction> _transactions;
  List<Category> _categories;
  List<Suggestion> _hiddenSuggestions;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();

    if (_transactions != null &&
        _categories != null &&
        _hiddenSuggestions != null) {
      if (_transactions.length == 0) {
        _body = Center(
          child: Text('There are no suggestions.'),
        );
      } else {
        List<Map<String, dynamic>> suggestions =
            getSuggestions(_transactions, widget.user.uid);
        suggestions.sort((a, b) => b['latestDate'].compareTo(a['latestDate']));
        _body = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) => suggestionCard(
              context,
              suggestions[index]['suggestion'],
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

  Widget suggestionCard(
      BuildContext context, Suggestion suggestion, Function refreshList) {
    Category category =
        _categories.singleWhere((cat) => cat.cid == suggestion.cid);
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
        title: Text(suggestion.payee),
        subtitle: Text(category.name),
        value: _hiddenSuggestions.singleWhere(
                (hiddenSuggestion) => hiddenSuggestion.equalTo(suggestion),
                orElse: () => null) ==
            null,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (val) async {
          if (val) {
            await DatabaseWrapper(widget.user.uid)
                .deleteHiddenSuggestions([suggestion]);
          } else {
            await DatabaseWrapper(widget.user.uid)
                .addHiddenSuggestions([suggestion]);
          }
          retrieveNewData(widget.user.uid);
        },
      ),
    );
  }

  void retrieveNewData(String uid) async {
    List<Transaction> transactions =
        await DatabaseWrapper(uid).getTransactions();
    List<Category> categories = await DatabaseWrapper(uid).getCategories();
    List<Suggestion> hiddenSuggestions =
        await DatabaseWrapper(uid).getHiddenSuggestions();
    setState(() {
      _transactions = transactions;
      _categories = categories;
      _hiddenSuggestions = hiddenSuggestions;
    });
  }
}
