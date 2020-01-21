import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/pages/periods/periodForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/mainDrawer.dart';

class Periods extends StatefulWidget {
  final FirebaseUser user;

  Periods(this.user);

  @override
  _PeriodsState createState() => _PeriodsState();
}

class _PeriodsState extends State<Periods> {
  List<Period> _periods;

  @override
  void initState() {
    super.initState();
    DatabaseWrapper(widget.user.uid).getPeriods().first.then((periods) {
      setState(() {
        _periods = List<Period>.from(periods);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(widget.user),
      appBar: AppBar(
        title: Text('Periods'),
      ),
      body: (_periods == null || _periods.length == 0)
          ? Center(
              child: Text(
                'You haven\'t set any periods. Add one using the button below.',
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 10.0,
              ),
              child: Container(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => showDialog(
          context: context,
          builder: (context) {
            return PeriodForm(Period.empty());
          },
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
