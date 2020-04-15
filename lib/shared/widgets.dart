import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget statTitle(title) {
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

Widget deleteIcon(
  BuildContext context,
  String itemDesc,
  Function deleteFunction,
  Function syncFunction,
) {
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

Widget datePicker(
  BuildContext context, {
  String leading = '',
  String trailing = '',
  Function updateDateState,
  DateTime openDate,
  DateTime firstDate,
  DateTime lastDate,
}) {
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

Widget timePicker(
  BuildContext context,
  String leading,
  String trailing,
  Function updateTimeState,
) {
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
      TimeOfDay time =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (time != null) {
        updateTimeState(time);
      }
    },
  );
}

Widget addFloatingButton(BuildContext context, Widget page, Function callback) {
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

Widget tabSelector(BuildContext context, List<Map<String, dynamic>> tabs) {
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
            children: (passwordToggle
                    ? <Widget>[
                        ButtonTheme(
                          child: IconButton(
                            icon: passwordToggleVisible
                                ? Icon(CommunityMaterialIcons.eye_off)
                                : Icon(CommunityMaterialIcons.eye),
                            onPressed: onPasswordTogglePressed,
                          ),
                        )
                      ]
                    : <Widget>[]) +
                <Widget>[
                  IconButton(
                    icon: Icon(CommunityMaterialIcons.close),
                    onPressed: onPressed,
                  ),
                ],
          )
        : null,
  );
}
