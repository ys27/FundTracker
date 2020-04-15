import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:uuid/uuid.dart';

class RecurringTransaction {
  String rid;
  DateTime nextDate;
  DateTime endDate;
  int occurrenceValue;
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
    this.endDate,
    this.occurrenceValue,
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
    endDate = null;
    occurrenceValue = null;
    frequencyValue = null;
    frequencyUnit = DateUnit.Weeks;
    isExpense = true;
    payee = '';
    amount = null;
    cid = null;
    uid = null;
  }

  RecurringTransaction.example() {
    DateTime now = DateTime.now();
    rid = '';
    nextDate = getDateNotTime(now);
    endDate = getDateNotTime(now);
    occurrenceValue = -1;
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
    this.endDate =
        map['endDate'].isNotEmpty ? DateTime.parse(map['endDate']) : null;
    this.occurrenceValue =
        map['occurrenceValue'] == -1 ? null : map['occurrenceValue'];
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
      'endDate': endDate != null ? endDate.toString() : '',
      'occurrenceValue': occurrenceValue != null ? occurrenceValue : -1,
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
        this.endDate == recTx.endDate &&
        this.occurrenceValue == recTx.occurrenceValue &&
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
    RecurringTransaction copy = this.clone();
    int numDaysUntilNextDate = findNumDaysInPeriod(
      this.nextDate,
      this.frequencyValue,
      this.frequencyUnit,
    );
    copy.nextDate = nextDate.add(Duration(days: numDaysUntilNextDate));
    if (occurrenceValue != null && occurrenceValue > 0) {
      copy.occurrenceValue--;
    }
    return copy;
  }

  RecurringTransaction withNewId() {
    RecurringTransaction copy = this.clone();
    copy.rid = Uuid().v1();
    return copy;
  }

  RecurringTransaction clone() {
    return RecurringTransaction(
      rid: this.rid,
      nextDate: this.nextDate,
      endDate: this.endDate,
      occurrenceValue: this.occurrenceValue,
      frequencyValue: this.frequencyValue,
      frequencyUnit: this.frequencyUnit,
      isExpense: this.isExpense,
      payee: this.payee,
      amount: this.amount,
      cid: this.cid,
      uid: this.uid,
    );
  }
}
