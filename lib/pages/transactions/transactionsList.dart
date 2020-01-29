import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionTile.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/loader.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TransactionsList extends StatefulWidget {
  final List<Map<String, dynamic>> dividedTransactions;

  TransactionsList(this.dividedTransactions);

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    final Period _currentPeriod = Provider.of<Period>(context);

    if (widget.dividedTransactions == null) {
      return Loader();
    } else if (widget.dividedTransactions.length == 0) {
      return Center(
        child:
            Text('No transactions available. Add one using the button below.'),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          Map<String, dynamic> periodMap = widget.dividedTransactions[index];
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Colors.grey,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                _currentPeriod.name == 'Default Monthly'
                    ? '${Months[periodMap['startDate'].month.toString()]} ${periodMap['startDate'].year}'
                    : '${getDate(periodMap['startDate'])} - ${getDate(periodMap['endDate'])}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            content: Column(
              children: periodMap['transactions']
                  .map<Widget>(
                    (tx) => TransactionTile(transaction: tx),
                  )
                  .toList(),
            ),
          );
        },
        itemCount: widget.dividedTransactions.length,
      );
    }
  }
}
