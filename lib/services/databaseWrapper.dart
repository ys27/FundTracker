import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/services/fireDB.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:fund_tracker/shared/constants.dart';

class DatabaseWrapper {
  final String uid;
  final DatabaseType dbType;

  DatabaseWrapper(this.uid, this.dbType);

  // Transactions
  Stream<List<Transaction>> getTransactions() {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).getTransactions()
        : LocalDBService().getTransactions(uid);
  }

  Future addTransaction(Transaction tx) async {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).addTransaction(tx)
        : LocalDBService().addTransaction(tx);
  }

  Future updateTransaction(Transaction tx) async {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).updateTransaction(tx)
        : LocalDBService().updateTransaction(tx);
  }

  Future deleteTransaction(Transaction tx) async {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).deleteTransaction(tx)
        : LocalDBService().deleteTransaction(tx);
  }

  // Categories
  Stream<List<Category>> getCategories() {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).getCategories()
        : LocalDBService().getCategories(uid);
  }

  void addDefaultCategories() {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).addDefaultCategories()
        : LocalDBService().addDefaultCategories(uid);
  }

  void setCategory(Category category) async {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).setCategory(category)
        : LocalDBService().setCategory(category);
  }

  void removeAllCategories() async {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).removeAllCategories()
        : LocalDBService().removeAllCategories(uid);
  }

  // User Info
  Stream<User> findUser() {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).findUser()
        : LocalDBService().findUser(uid);
  }

  Future addUser(User user) async {
    return dbType == DatabaseType.Firebase
        ? FireDBService(uid).addUser(user)
        : LocalDBService().addUser(user);
  }
}
