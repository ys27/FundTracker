class Transaction {
  final String tid;
  final DateTime date;
  final bool isExpense;
  final String payee;
  final double amount;
  final String category;

  Transaction({ this.tid, this.date, this.isExpense, this.payee, this.amount, this.category });
}
