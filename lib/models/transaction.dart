class Transaction {
  String tid;
  DateTime date;
  bool isExpense;
  String payee;
  double amount;
  String category;
  String uid;

  Transaction({
    this.tid,
    this.date,
    this.isExpense,
    this.payee,
    this.amount,
    this.category,
    this.uid,
  });

  Transaction.empty() {
    tid = null;
    date = DateTime.now();
    isExpense = true;
    payee = '';
    amount = null;
    category = null;
    uid = null;
  }

  Transaction.example() {
    tid = 'null';
    date = DateTime.now();
    isExpense = true;
    payee = '';
    amount = 0.0;
    category = '';
    uid = '';
  }

  Transaction.fromMap(Map<String, dynamic> map) {
    this.tid = map['tid'];
    this.date = DateTime.parse(map['date']);
    this.isExpense = map['isExpense'] == 1;
    this.payee = map['payee'];
    this.amount = map['amount'];
    this.category = map['category'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'tid': tid,
      'date': date.toString(),
      'isExpense': isExpense ? 1 : 0,
      'payee': payee,
      'amount': amount,
      'category': category,
      'uid': uid,
    };
  }
}
