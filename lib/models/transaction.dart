class Transaction {
  String tid;
  DateTime date;
  bool isExpense;
  String payee;
  double amount;
  String category;

  Transaction({
    this.tid,
    this.date,
    this.isExpense,
    this.payee,
    this.amount,
    this.category,
  });

  Transaction.empty() {
    tid = null;
    date = DateTime.now();
    isExpense = true;
    payee = '';
    amount = null;
    category = null;
  }

  Transaction.fromMap(Map<String, dynamic> map) {
    this.tid = map['tid'];
    this.date = map['date'];
    this.isExpense = map['isExpense'];
    this.payee = map['payee'];
    this.amount = map['amount'];
    this.category = map['category'];
  }

  Map<String, dynamic> toMap() {
    return {
      'tid': tid,
      'date': date,
      'isExpense': isExpense,
      'payee': payee,
      'amount': amount,
      'category': category,
    };
  }
}
