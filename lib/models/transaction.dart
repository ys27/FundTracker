class Transaction {
  String tid;
  DateTime date;
  bool isExpense;
  String payee;
  double amount;
  String cid;
  String uid;

  Transaction({
    this.tid,
    this.date,
    this.isExpense,
    this.payee,
    this.amount,
    this.cid,
    this.uid,
  });

  Transaction.empty() {
    tid = null;
    date = DateTime.now();
    isExpense = true;
    payee = null;
    amount = null;
    cid = null;
    uid = null;
  }

  Transaction.example() {
    tid = '';
    date = DateTime.now();
    isExpense = true;
    payee = '';
    amount = 0.0;
    cid = '';
    uid = '';
  }

  Transaction.fromMap(Map<String, dynamic> map) {
    this.tid = map['tid'];
    this.date = DateTime.parse(map['date']);
    this.isExpense = map['isExpense'] == 1;
    this.payee = map['payee'];
    this.amount = map['amount'];
    this.cid = map['cid'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'tid': tid,
      'date': date.toString(),
      'isExpense': isExpense ? 1 : 0,
      'payee': payee,
      'amount': amount,
      'cid': cid,
      'uid': uid,
    };
  }

  bool equalTo(Transaction tx) {
    return (this.tid == tx.tid &&
        this.date == tx.date &&
        this.isExpense == tx.isExpense &&
        this.payee == tx.payee &&
        this.amount == tx.amount &&
        this.cid == tx.cid &&
        this.uid == tx.uid);
  }

  Transaction clone() {
    return Transaction(
      tid: this.tid,
      date: this.date,
      isExpense: this.isExpense,
      payee: this.payee,
      amount: this.amount,
      cid: this.cid,
      uid: this.uid,
    );
  }
}
