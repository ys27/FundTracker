import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/pages/periods/periodForm.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:fund_tracker/shared/mainDrawer.dart';
import 'package:provider/provider.dart';

class Periods extends StatefulWidget {
  final FirebaseUser user;

  Periods(this.user);

  @override
  _PeriodsState createState() => _PeriodsState();
}

class _PeriodsState extends State<Periods> {
  @override
  Widget build(BuildContext context) {
    final List<Period> _periods = Provider.of<List<Period>>(context);
    Widget bodyWidget;

    if (_periods == null) {
      bodyWidget = Loader();
    } else if (_periods.length == 0) {
      bodyWidget = Center(
        child: Text(
          'You haven\'t set any periods. Add one using the button below.',
        ),
      );
    } else {
      bodyWidget = Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        child: ListView.builder(
          itemCount: _periods.length,
          itemBuilder: (context, index) {
            Period period = _periods[index];
            return Card(
              color: period.isDefault ? Colors.blue[50] : null,
              child: ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return PeriodForm(period);
                  },
                ),
                title: Text(period.name),
                subtitle: Text(
                    'Every ${period.durationValue} ${period.durationUnit.toString().split('.')[1]}'),
                trailing: Text('Start Date: ${getDate(period.startDate)}'),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      drawer: MainDrawer(widget.user),
      appBar: AppBar(
        title: Text('Periods'),
      ),
      body: bodyWidget,
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
