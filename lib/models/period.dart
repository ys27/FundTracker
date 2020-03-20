import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';

class Period {
  String pid;
  String name;
  DateTime startDate;
  int durationValue;
  DateUnit durationUnit;
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
    DateTime now = DateTime.now();
    pid = null;
    name = null;
    startDate = getDateNotTime(now);
    durationValue = null;
    durationUnit = DateUnit.Weeks;
    isDefault = false;
    uid = null;
  }

  Period.monthly() {
    DateTime now = DateTime.now();

    pid = '';
    name = 'Default Monthly';
    startDate = DateTime(now.year, now.month, 1);
    durationValue = 1;
    durationUnit = DateUnit.Months;
    isDefault = false;
    uid = '';
  }

  Period.example() {
    pid = '';
    name = '';
    startDate = DateTime.now();
    durationValue = 0;
    durationUnit = DateUnit.Weeks;
    isDefault = false;
    uid = '';
  }

  Period.fromMap(Map<String, dynamic> map) {
    this.pid = map['pid'];
    this.name = map['name'];
    this.startDate = DateTime.parse(map['startDate']);
    this.durationValue = map['durationValue'];
    this.durationUnit = DateUnit.values[map['durationUnit']];
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
    Period copy = this.clone();
    copy.startDate = startDate;
    return copy;
  }

  bool equalTo(Period period) {
    return (this.pid == period.pid &&
        this.name == period.name &&
        this.startDate == period.startDate &&
        this.durationValue == period.durationValue &&
        this.durationUnit == period.durationUnit &&
        this.isDefault == period.isDefault &&
        this.uid == period.uid);
  }

  Period clone() {
    return Period(
      pid: this.pid,
      name: this.name,
      startDate: this.startDate,
      durationValue: this.durationValue,
      durationUnit: this.durationUnit,
      isDefault: this.isDefault,
      uid: this.uid,
    );
  }
}
