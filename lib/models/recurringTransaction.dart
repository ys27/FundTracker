import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';

class RecurringTransaction {
  String rid;
  DateTime nextDate;
  int frequencyValue;
  DateUnit frequencyUnit;
  bool isExpense;
  String payee;
  double amount;
  String category;
  String uid;

  RecurringTransaction({
    this.rid,
    this.nextDate,
    this.frequencyValue,
    this.frequencyUnit,
    this.isExpense,
    this.payee,
    this.amount,
    this.category,
    this.uid,
  });

  RecurringTransaction.empty() {
    DateTime now = DateTime.now();
    rid = null;
    nextDate = getDateNotTime(now);
    frequencyValue = null;
    frequencyUnit = DateUnit.Weeks;
    isExpense = true;
    payee = '';
    amount = null;
    category = null;
    uid = null;
  }

  RecurringTransaction.example() {
    rid = '';
    nextDate = DateTime.now();
    frequencyValue = 0;
    frequencyUnit = DateUnit.Weeks;
    isExpense = true;
    payee = '';
    amount = 0.0;
    category = '';
    uid = '';
  }

  RecurringTransaction.fromMap(Map<String, dynamic> map) {
    this.rid = map['rid'];
    this.nextDate = DateTime.parse(map['nextDate']);
    this.frequencyValue = map['frequencyValue'];
    this.frequencyUnit = DateUnit.values[map['frequencyUnit']];
    this.isExpense = map['isExpense'] == 1;
    this.payee = map['payee'];
    this.amount = map['amount'];
    this.category = map['category'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'rid': rid,
      'nextDate': nextDate.toString(),
      'frequencyValue': frequencyValue,
      'frequencyUnit': frequencyUnit.index,
      'isExpense': isExpense ? 1 : 0,
      'payee': payee,
      'amount': amount,
      'category': category,
      'uid': uid,
    };
  }

  bool equalTo(RecurringTransaction recurringTransaction) {
    return (this.rid == recurringTransaction.rid &&
        this.nextDate == recurringTransaction.nextDate &&
        this.frequencyValue == recurringTransaction.frequencyValue &&
        this.frequencyUnit == recurringTransaction.frequencyUnit &&
        this.isExpense == recurringTransaction.isExpense &&
        this.payee == recurringTransaction.payee &&
        this.amount == recurringTransaction.amount &&
        this.category == recurringTransaction.category &&
        this.uid == recurringTransaction.uid);
  }
}
