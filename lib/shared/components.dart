import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StatTitle extends StatelessWidget {
  final String title;

  StatTitle({this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 30.0),
        ),
      ],
    );
  }
}

class Alert extends StatelessWidget {
  final String content;

  Alert(this.content);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Are you sure?"),
      content: Text(content),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: Text("Confirm"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).primaryColor,
      child: Center(
        child: SpinKitPulse(
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}

class DeleteIcon extends StatelessWidget {
  final BuildContext context;
  final String itemDesc;
  final Function deleteFunction;
  final Function syncFunction;

  DeleteIcon(
    this.context, {
    this.itemDesc,
    this.deleteFunction,
    this.syncFunction,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(CommunityMaterialIcons.delete),
      onPressed: () async {
        bool hasBeenConfirmed = await showDialog(
              context: context,
              builder: (BuildContext context) =>
                  Alert('This $itemDesc will be deleted.'),
            ) ??
            false;
        if (hasBeenConfirmed) {
          deleteFunction();
          syncFunction();
          Navigator.pop(context);
        }
      },
    );
  }
}

Future<DateTime> openDatePicker(
  BuildContext context, {
  DateTime openDate,
  DateTime firstDate,
  DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: openDate ?? DateTime.now(),
    firstDate: firstDate ??
        DateTime.now().subtract(
          Duration(days: 365),
        ),
    lastDate: lastDate ??
        DateTime.now().add(
          Duration(days: 365),
        ),
  );
}

class DatePicker extends StatelessWidget {
  final BuildContext context;
  final String leading;
  final String trailing;
  final Function updateDateState;
  final DateTime openDate;
  final DateTime firstDate;
  final DateTime lastDate;

  DatePicker(
    this.context, {
    this.leading = '',
    this.trailing = '',
    this.updateDateState,
    this.openDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(leading),
          Text(trailing),
          Icon(CommunityMaterialIcons.calendar_range),
        ],
      ),
      onPressed: () async {
        DateTime date = await openDatePicker(
          context,
          openDate: openDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );

        if (date != null) {
          DateTime now = DateTime.now();
          DateTime dateWithCurrentTime = DateTime(
            date.year,
            date.month,
            date.day,
            now.hour,
            now.minute,
            now.second,
          );
          updateDateState(dateWithCurrentTime);
        }
      },
    );
  }
}

class TimePicker extends StatelessWidget {
  final BuildContext context;
  final String leading;
  final String trailing;
  final Function updateTimeState;

  TimePicker(
    this.context, {
    this.leading = '',
    this.trailing = '',
    this.updateTimeState,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(leading),
          Text(trailing),
          Icon(CommunityMaterialIcons.clock_outline),
        ],
      ),
      onPressed: () async {
        TimeOfDay time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());

        if (time != null) {
          updateTimeState(time);
        }
      },
    );
  }
}

class FloatingButton extends StatelessWidget {
  final BuildContext context;
  final Widget page;
  final Function callback;

  FloatingButton(
    this.context, {
    this.page,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => page,
        );
        callback();
      },
      child: Icon(CommunityMaterialIcons.plus),
    );
  }
}

class TabSelector extends StatelessWidget {
  final BuildContext context;
  final List<Map<String, dynamic>> tabs;

  TabSelector(
    this.context, {
    this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((tab) {
          return Expanded(
            child: FlatButton(
              padding: EdgeInsets.all(15.0),
              color: tab['enabled']
                  ? Theme.of(context).primaryColor
                  : Colors.grey[100],
              child: Text(
                tab['title'],
                style: TextStyle(
                    fontWeight:
                        tab['enabled'] ? FontWeight.bold : FontWeight.normal,
                    color: tab['enabled'] ? Colors.white : Colors.black),
              ),
              onPressed: tab['onPressed'],
            ),
          );
        }).toList());
  }
}

InputDecoration clearInput({
  String labelText,
  bool enabled = true,
  Function onPressed,
  bool passwordToggle = false,
  Function onPasswordTogglePressed,
  bool passwordToggleVisible = false,
}) {
  return InputDecoration(
    labelText: labelText,
    suffixIcon: enabled
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (passwordToggle) ...[
                ButtonTheme(
                  child: IconButton(
                    icon: passwordToggleVisible
                        ? Icon(CommunityMaterialIcons.eye_off)
                        : Icon(CommunityMaterialIcons.eye),
                    onPressed: onPasswordTogglePressed,
                  ),
                ),
              ],
              IconButton(
                icon: Icon(CommunityMaterialIcons.close),
                onPressed: onPressed,
              ),
            ],
          )
        : null,
  );
}
