import 'package:fund_tracker/shared/constants.dart';

class Period {
  String pid;
  String name;
  DateTime startDate;
  int durationValue;
  DurationUnit durationUnit;
  bool isDefault;
  String uid;

  Period({
    this.pid,
    this.name,
    this.startDate,
    this.durationValue,
    this.durationUnit,
    this.isDefault,
    this.uid,
  });

  Period.empty() {
    pid = null;
    name = null;
    startDate = DateTime.now();
    durationValue = null;
    durationUnit = DurationUnit.Weeks;
    isDefault = false;
    uid = null;
  }

  Period.monthly() {
    DateTime now = DateTime.now();

    pid = '';
    name = 'Default Monthly';
    startDate = DateTime.utc(now.year, now.month, 1);
    durationValue = 1;
    durationUnit = DurationUnit.Months;
    isDefault = false;
    uid = '';
  }

  Period.example() {
    pid = '';
    name = '';
    startDate = DateTime.now();
    durationValue = 0;
    durationUnit = DurationUnit.Weeks;
    isDefault = false;
    uid = '';
  }

  Period.fromMap(Map<String, dynamic> map) {
    this.pid = map['pid'];
    this.name = map['name'];
    this.startDate = DateTime.parse(map['startDate']);
    this.durationValue = map['durationValue'];
    this.durationUnit = DurationUnit.values[map['durationUnit']];
    this.isDefault = map['isDefault'] == 1;
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'name': name,
      'startDate': startDate.toString(),
      'durationValue': durationValue,
      'durationUnit': durationUnit.index,
      'isDefault': isDefault ? 1 : 0,
      'uid': uid,
    };
  }

  Period setStartDate(DateTime startDate) {
    this.startDate = startDate;
    return this;
  }
}
