import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication
    show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionTile.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TransactionsList extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final Period currentPeriod;
  final List<Suggestion> hiddenSuggestions;
  final Function refreshList;

  TransactionsList({
    this.transactions,
    this.categories,
    this.currentPeriod,
    this.hiddenSuggestions,
    this.refreshList,
  });

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  Map<int, bool> _collapsedPeriods = {};

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseAuthentication.User>(context);

    if (widget.transactions == null ||
        widget.currentPeriod == null ||
        widget.categories == null) {
      return Loader();
    }
    if (widget.transactions.length == 0) {
      return Center(
        child: Text('Add a transaction using the button below.'),
      );
    } else {
      List<Map<String, dynamic>> _dividedTransactions =
          divideTransactionsIntoPeriods(
              widget.transactions, widget.currentPeriod);

      updateLatestPeriodStartDate(_dividedTransactions, _user);

      return ListView.builder(
        itemBuilder: (context, index) {
          Map<String, dynamic> period = _dividedTransactions[index];
          if (period['transactions'].length > 0) {
            return Column(children: <Widget>[
              StickyHeader(
                header: transactionsPeriodHeader(
                    widget.currentPeriod.name == 'Default Monthly',
                    period['startDate'],
                    period['endDate'],
                    period['transactions'], onTap: () {
                  print(_collapsedPeriods);
                  if (!(_collapsedPeriods[index] ?? false)) {
                    _collapsedPeriods[index] = true;
                  } else {
                    _collapsedPeriods.remove(index);
                  }
                  setState(() => _collapsedPeriods = _collapsedPeriods);
                }),
                content: !(_collapsedPeriods[index] ?? false)
                    ? Column(
                        children: period['transactions'].map<Widget>((tx) {
                          Category category =
                              getCategory(widget.categories, tx.cid);
                          return TransactionTile(
                            transaction: tx,
                            category: category,
                            hiddenSuggestions: widget.hiddenSuggestions,
                            refreshList: widget.refreshList,
                          );
                        }).toList(),
                      )
                    : Container(),
              ),
              SizedBox(height: 1.0),
            ]);
          } else {
            return Container();
          }
        },
        itemCount: _dividedTransactions.length,
        // physics: const AlwaysScrollableScrollPhysics(),
      );
    }
  }

  Widget transactionsPeriodHeader(
    bool isDefault,
    DateTime startDate,
    DateTime endDate,
    List<Transaction> transactions, {
    VoidCallback onTap,
  }) {
    return InkWell(
      child: Container(
        height: 50.0,
        color: Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              isDefault
                  ? '${Months[startDate.month.toString()]} ${startDate.year}'
                  : '${getDateStr(startDate)} - ${getDateStr(endDate)}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              getTransactionsSumStr(transactions),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  String getTransactionsSumStr(List<Transaction> transactions) {
    final double sum = transactions.fold(0.0, (a, b) {
      final double nextAmount = b.isExpense ? -1 * b.amount : b.amount;
      return a + nextAmount;
    });
    return '${sum < 0 ? '-' : ''}\$${formatAmount(abs(sum))}';
  }

  void updateLatestPeriodStartDate(
      List<Map<String, dynamic>> dividedTransactions,
      FirebaseAuthentication.User user) {
    dividedTransactions.forEach((period) {
      DateTime now = DateTime.now();
      if (now.isAfter(period['startDate'].subtract(
            Duration(microseconds: 1),
          )) &&
          now.isBefore(period['endDate'])) {
        DatabaseWrapper(user.uid).updatePeriods(
            [widget.currentPeriod.setStartDate(period['startDate'])]);
      }
    });
  }
}
