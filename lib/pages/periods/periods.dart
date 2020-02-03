import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/pages/periods/periodForm.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
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
    Widget _bodyWidget = Loader();

    if (_periods != null) {
      if (_periods.length == 0) {
        _bodyWidget = Center(
          child: Text(
            'You haven\'t set any periods. Add one using the button below.',
          ),
        );
      } else {
        _bodyWidget = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: _periods.length,
            itemBuilder: (context, index) => periodCard(_periods[index]),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(widget.user),
      appBar: AppBar(title: Text('Periods')),
      body: _bodyWidget,
      floatingActionButton: addFloatingButton(
        context,
        PeriodForm(Period.empty()),
      ),
    );
  }

  Widget periodCard(Period period) {
    return Card(
      color: period.isDefault ? Colors.blue[50] : null,
      child: ListTile(
        onTap: () => showDialog(
          context: context,
          builder: (context) => PeriodForm(period),
        ),
        title: Text(period.name),
        subtitle: Text(
          'Every ${period.durationValue} ${period.durationUnit.toString().split('.')[1]}',
        ),
        trailing: Text('Start Date: ${getDate(period.startDate)}'),
      ),
    );
  }
}
