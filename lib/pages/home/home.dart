import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/categories/categoriesList.dart';
import 'package:fund_tracker/pages/statistics/statistics.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:fund_tracker/services/recurringTransactions.dart';
import 'package:fund_tracker/services/search.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final FirebaseUser user;

  Home(this.user);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Transaction> _transactions;
  List<Category> _categories;
  Period _currentPeriod;
  Preferences _prefs;

  int _selectedIndex = 0;
  List<String> categoriesFiltered = [];
  bool anyCategoryFiltered = false;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    if (_categories != null) {
      categoriesFiltered = _categories
          .where((cat) => !cat.unfiltered)
          .map((cat) => cat.name)
          .toList();
      anyCategoryFiltered = categoriesFiltered.length > 0;
      _transactions = _transactions
          .where((tx) => !categoriesFiltered.contains(tx.category))
          .toList();
    }

    final List<Map<String, dynamic>> _pages = [
      {
        'name': 'Records',
        'actions': <Widget>[
          searchButton(),
          filterCategoriesButton(),
        ],
        'widget': TransactionsList(
          _transactions,
          _currentPeriod,
          _prefs,
          () => retrieveNewData(widget.user.uid),
        ),
        'addButton': addFloatingButton(
          context,
          MultiProvider(
            providers: [
              StreamProvider<List<Transaction>>.value(
                  value: DatabaseWrapper(widget.user.uid).getTransactions()),
              StreamProvider<List<Category>>.value(
                  value: DatabaseWrapper(widget.user.uid).getCategories()),
            ],
            child: TransactionForm(Transaction.empty()),
          ),
          () => retrieveNewData(widget.user.uid),
        ),
      },
      {
        'name': 'Statistics',
        'actions': <Widget>[
          filterCategoriesButton(),
        ],
        'widget': Statistics(_transactions, _currentPeriod, _prefs),
      }
    ];

    return Scaffold(
      drawer: MainDrawer(widget.user, openPage),
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]['name']),
        actions: _pages[_selectedIndex]['actions'],
      ),
      body: _pages[_selectedIndex]['widget'],
      floatingActionButton: _pages[_selectedIndex]['addButton'],
      bottomNavigationBar: transactionsAndStatistics(),
    );
  }

  Widget searchButton() {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () => showSearch(
        context: context,
        delegate: SearchService(
          _transactions,
          _currentPeriod,
          _prefs,
          retrieveNewData,
        ),
      ),
    );
  }

  Widget filterCategoriesButton() {
    return IconButton(
      icon: Icon(anyCategoryFiltered
          ? CommunityMaterialIcons.filter
          : CommunityMaterialIcons.filter_outline),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return CategoriesList(widget.user, openPage, filterMode: true);
          },
        );
        retrieveNewData(widget.user.uid);
      },
    );
  }

  Widget transactionsAndStatistics() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          title: Text('Records'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.equalizer),
          title: Text('Statistics'),
        )
      ],
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
    );
  }

  void retrieveNewData(String uid) {
    RecurringTransactionsService.checkRecurringTransactions(widget.user.uid);

    DatabaseWrapper(uid)
        .getTransactions()
        .first
        .then((transactions) => setState(() => _transactions = transactions));

    DatabaseWrapper(uid)
        .getCategories()
        .first
        .then((categories) => setState(() => _categories = categories));

    DatabaseWrapper(uid)
        .getDefaultPeriod()
        .first
        .then((period) => setState(() => _currentPeriod = period));

    DatabaseWrapper(uid)
        .getPreferences()
        .first
        .then((prefs) => setState(() => _prefs = prefs));
  }

  void openPage(Widget page) async {
    goHome(context);
    await showDialog(
      context: context,
      builder: (context) {
        return page;
      },
    );
    retrieveNewData(widget.user.uid);
  }
}
