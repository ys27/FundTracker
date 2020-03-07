import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:uuid/uuid.dart';

class RecurringTransaction {
  String rid;
  DateTime nextDate;
  int frequencyValue;
  DateUnit frequencyUnit;
  bool isExpense;
  String payee;
  double amount;
  String cid;
  String uid;

  RecurringTransaction({
    this.rid,
    this.nextDate,
    this.frequencyValue,
    this.frequencyUnit,
    this.isExpense,
    this.payee,
    this.amount,
    this.cid,
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
    cid = null;
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
    cid = '';
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
    this.cid = map['cid'];
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
      'cid': cid,
      'uid': uid,
    };
  }

  bool equalTo(RecurringTransaction recTx) {
    return (this.rid == recTx.rid &&
        this.nextDate == recTx.nextDate &&
        this.frequencyValue == recTx.frequencyValue &&
        this.frequencyUnit == recTx.frequencyUnit &&
        this.isExpense == recTx.isExpense &&
        this.payee == recTx.payee &&
        this.amount == recTx.amount &&
        this.cid == recTx.cid &&
        this.uid == recTx.uid);
  }

  Transaction toTransaction() {
    return Transaction(
      tid: Uuid().v1(),
      date: nextDate,
      isExpense: isExpense,
      payee: payee,
      amount: amount,
      cid: cid,
      uid: uid,
    );
  }

  RecurringTransaction incrementNextDate() {
    int numDaysUntilNextDate = findNumDaysInPeriod(
      this.nextDate,
      this.frequencyValue,
      this.frequencyUnit,
    );
    this.nextDate = nextDate.add(Duration(days: numDaysUntilNextDate));
    return this;
  }

  RecurringTransaction withNewId() {
    this.rid = Uuid().v1();
    return this;
  }
}
