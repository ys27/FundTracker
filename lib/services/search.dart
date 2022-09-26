import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';

class SearchService extends SearchDelegate {
  final List<Transaction> transactions;
  final List<Category> categories;
  final Period currentPeriod;
  final Preferences prefs;
  final List<Suggestion> hiddenSuggestions;
  final Function refreshList;

  SearchService({
    this.transactions,
    this.categories,
    this.currentPeriod,
    this.prefs,
    this.hiddenSuggestions,
    this.refreshList,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(CommunityMaterialIcons.close),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('No query specified.'));
    } else {
      final List<Transaction> searchedTransactions = transactions
          .where((tx) => tx.payee.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return TransactionsList(
        transactions: searchedTransactions,
        categories: categories,
        currentPeriod: currentPeriod,
        hiddenSuggestions: hiddenSuggestions,
        refreshList: null,
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
        child: Text(query.isEmpty
            ? 'Try searching for something better than \'\'!'
            : 'Press enter to search for \'$query\'.'));
  }
}
