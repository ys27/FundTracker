import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/pages/periods/periodForm.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/widgets.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';
import 'package:provider/provider.dart';

class Periods extends StatelessWidget {
  final FirebaseUser user;

  Periods(this.user);

  @override
  Widget build(BuildContext context) {
    final List<Period> _periods = Provider.of<List<Period>>(context);
    Widget _body = Loader();

    if (_periods != null) {
      if (_periods.length == 0) {
        _body = Center(
          child: Text('Add a period using the button below.'),
        );
      } else {
        _body = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: _periods.length,
            itemBuilder: (context, index) =>
                periodCard(context, _periods[index]),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(user),
      appBar: AppBar(title: Text('Periods')),
      body: _body,
      floatingActionButton: addFloatingButton(
        context,
        PeriodForm(Period.empty()),
        () {},
      ),
    );
  }

  Widget periodCard(BuildContext context, Period period) {
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
        trailing: Text('Start Date: ${getDateStr(period.startDate)}'),
      ),
    );
  }
}
