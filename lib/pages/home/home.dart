import 'package:flutter/material.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/transactions/addTransaction.dart';
import 'package:fund_tracker/pages/transactions/transactionsList.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/database.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamProvider<List<Transaction>>.value(
      value: DatabaseService(uid: user.uid).transactions,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Records'),
          actions: <Widget>[
            FlatButton.icon(
              onPressed: () async {
                await _auth.logOut();
              },
              label: Text('Log out'),
              icon: Icon(Icons.person),
            ),
          ],
        ),
        body: TransactionsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return AddTransaction();
            },
          ),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
