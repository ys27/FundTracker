class Transaction {
  final DateTime date;
  final bool isExpense;
  final String payee;
  final double amount;
  final String category;

  Transaction({ this.date, this.isExpense, this.payee, this.amount, this.category });
}
