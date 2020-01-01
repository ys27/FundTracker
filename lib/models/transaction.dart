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
}
