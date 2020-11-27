import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/shared/constants.dart';
import 'package:fund_tracker/shared/library.dart';
import 'package:uuid/uuid.dart';

class PlannedTransaction {
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

  PlannedTransaction({
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

  PlannedTransaction.empty() {
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

  PlannedTransaction.example() {
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

  PlannedTransaction.fromMap(Map<String, dynamic> map) {
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

  bool equalTo(PlannedTransaction plannedTx) {
    return (this.rid == plannedTx.rid &&
        this.nextDate == plannedTx.nextDate &&
        this.endDate == plannedTx.endDate &&
        this.occurrenceValue == plannedTx.occurrenceValue &&
        this.frequencyValue == plannedTx.frequencyValue &&
        this.frequencyUnit == plannedTx.frequencyUnit &&
        this.isExpense == plannedTx.isExpense &&
        this.payee == plannedTx.payee &&
        this.amount == plannedTx.amount &&
        this.cid == plannedTx.cid &&
        this.uid == plannedTx.uid);
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

  PlannedTransaction incrementNextDate() {
    PlannedTransaction copy = this.clone();
    int numDaysUntilNextDate = findNumDaysInPeriod(
      this.nextDate,
      this.frequencyValue,
      this.frequencyUnit,
    );
    copy.nextDate = getClosestDayStart(nextDate.add(Duration(days: numDaysUntilNextDate)));
    if (occurrenceValue != null && occurrenceValue > 0) {
      copy.occurrenceValue--;
    }
    return copy;
  }

  PlannedTransaction withNewId() {
    PlannedTransaction copy = this.clone();
    copy.rid = Uuid().v1();
    return copy;
  }

  PlannedTransaction clone() {
    return PlannedTransaction(
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
