import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/pages/periods/periodForm.dart';
import 'package:fund_tracker/services/databaseWrapper.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:fund_tracker/shared/styles.dart';
import 'package:fund_tracker/shared/components.dart';
import 'package:fund_tracker/pages/home/mainDrawer.dart';

class PeriodsList extends StatefulWidget {
  final FirebaseAuthentication.User user;
  final Function openPage;

  PeriodsList({this.user, this.openPage});

  @override
  _PeriodsListState createState() => _PeriodsListState();
}

class _PeriodsListState extends State<PeriodsList> {
  List<Period> _periods;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
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
            itemBuilder: (context, index) => periodCard(
              context,
              _periods[index],
              () => retrieveNewData(widget.user.uid),
            ),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(user: widget.user, openPage: widget.openPage),
      appBar: AppBar(title: Text('Periods')),
      body: _body,
      floatingActionButton: FloatingButton(
        context,
        page: PeriodForm(period: Period.empty()),
        callback: () => retrieveNewData(widget.user.uid),
      ),
    );
  }

  Widget periodCard(BuildContext context, Period period, Function refreshList) {
    return Card(
      color: period.isDefault ? Colors.blue[50] : null,
      child: ListTile(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => PeriodForm(period: period),
          );
          refreshList();
        },
        title: Text(period.name),
        subtitle: Text(
          'Every ${period.durationValue} ${period.durationUnit.toString().split('.')[1]}',
        ),
        trailing: Text('Start Date: ${getDateStr(period.startDate)}'),
      ),
    );
  }

  void retrieveNewData(String uid) async {
    List<Period> periods = await DatabaseWrapper(uid).getPeriods();
    setState(() => _periods = periods);
  }
}
