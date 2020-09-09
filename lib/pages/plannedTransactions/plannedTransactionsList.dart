import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication
    show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/plannedTransaction.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/pages/transactions/transactionForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:provider/provider.dart';

class PlannedTransactionsList extends StatefulWidget {
  final FirebaseAuthentication.User user;
  final Function openPage;

  PlannedTransactionsList({this.user, this.openPage});

  @override
  _PlannedTransactionsListState createState() =>
      _PlannedTransactionsListState();
}

class _PlannedTransactionsListState extends State<PlannedTransactionsList> {
  List<PlannedTransaction> _plannedTxs;
  List<Suggestion> _hiddenSuggestions;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();

    if (_plannedTxs != null) {
      if (_plannedTxs.length == 0) {
        _body = Center(
          child: Text('Add a planned transaction using the button below.'),
        );
      } else {
        _body = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: _plannedTxs.length,
            itemBuilder: (context, index) => plannedTransactionCard(
              context,
              _plannedTxs[index],
              () => retrieveNewData(widget.user.uid),
            ),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(user: widget.user, openPage: widget.openPage),
      appBar: AppBar(title: Text('Planned Transactions')),
      body: _body,
      floatingActionButton: FloatingButton(
        context,
        page: MultiProvider(
          providers: [
            FutureProvider<List<Transaction>>.value(
                value: DatabaseWrapper(widget.user.uid).getTransactions()),
            FutureProvider<List<Category>>.value(
                value: DatabaseWrapper(widget.user.uid).getCategories()),
          ],
          child: TransactionForm(
            hiddenSuggestions: _hiddenSuggestions,
            getTxOrRecTx: () => PlannedTransaction.empty(),
          ),
        ),
        callback: () => retrieveNewData(widget.user.uid),
      ),
    );
  }

  Widget plannedTransactionCard(
    BuildContext context,
    PlannedTransaction plannedTx,
    Function refreshList,
  ) {
    return Card(
      color: plannedTx.isExpense ? Colors.red[50] : Colors.green[50],
      child: ListTile(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => MultiProvider(
              providers: [
                FutureProvider<List<Transaction>>.value(
                    value: DatabaseWrapper(widget.user.uid).getTransactions()),
                FutureProvider<List<Category>>.value(
                    value: DatabaseWrapper(widget.user.uid).getCategories()),
              ],
              child: TransactionForm(
                hiddenSuggestions: _hiddenSuggestions,
                getTxOrRecTx: () => plannedTx,
              ),
            ),
          );
          refreshList();
        },
        title: Wrap(children: <Widget>[
          Text('${plannedTx.payee}: '),
          Text(
            '${plannedTx.isExpense ? '-' : '+'}\$${plannedTx.amount.toStringAsFixed(2)}',
          ),
        ]),
        subtitle: Text(
          'Every ${plannedTx.frequencyValue} ${getFrequencyUnitStr(plannedTx.frequencyUnit)}' +
              getEndCondition(plannedTx),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(CommunityMaterialIcons.chevron_right),
            Text('${getDateStr(plannedTx.nextDate)}'),
          ],
        ),
      ),
    );
  }

  String getFrequencyUnitStr(DateUnit freqUnit) {
    String unitPlural = freqUnit.toString().split('.')[1];
    String unitSingular = unitPlural.substring(0, unitPlural.length - 1);
    return '$unitSingular(s)';
  }

  String getEndCondition(PlannedTransaction plannedTx) {
    if (plannedTx.endDate != null && plannedTx.endDate.toString().isNotEmpty) {
      return ', ~${getDateStr(plannedTx.endDate)}';
    } else if (plannedTx.occurrenceValue != null &&
        plannedTx.occurrenceValue > 0) {
      return ', ${plannedTx.occurrenceValue} time(s) left';
    } else {
      return '';
    }
  }

  void retrieveNewData(String uid) async {
    List<dynamic> data = await Future.wait([
      DatabaseWrapper(uid).getPlannedTransactions(),
      DatabaseWrapper(uid).getHiddenSuggestions(),
    ]);

    setState(() {
      _plannedTxs = data[0];
      _hiddenSuggestions = data[1];
    });
  }
}
