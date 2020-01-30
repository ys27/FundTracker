import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';

class Balance extends StatefulWidget {
  final List<Transaction> transactions;

  Balance(this.transactions);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  @override
  Widget build(BuildContext context) {
    final double expenseAmount = widget.transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (a, b) => a + b.amount);
    final double incomeAmount = widget.transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (a, b) => a + b.amount);
    final double balance = incomeAmount - expenseAmount;

    return
  }
}
