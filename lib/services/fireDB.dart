import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/preferences/categoriesRegistry.dart';
import 'package:uuid/uuid.dart';

class FireDBService {
  final String uid;

  FireDBService(this.uid);

  final CollectionReference usersCollection =
      Firestore.instance.collection('users');

  // Transactions
  Stream<List<Transaction>> getTransactions() {
    return usersCollection
        .document(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.documents
            .map((map) => Transaction.fromMap(map.data))
            .toList());
  }

  Future addTransaction(Transaction tx) async {
    return await usersCollection
        .document(uid)
        .collection('transactions')
        .add(tx.toMap());
  }

  Future updateTransaction(Transaction tx) async {
    return await usersCollection
        .document(uid)
        .collection('transactions')
        .document(tx.tid)
        .setData(tx.toMap());
  }

  Future deleteTransaction(Transaction tx) async {
    return await usersCollection
        .document(uid)
        .collection('transactions')
        .document(tx.tid)
        .delete();
  }

  // Categories
  Stream<List<Category>> getCategories() {
    return usersCollection
        .document(uid)
        .collection('categories')
        .orderBy('orderIndex')
        .snapshots()
        .map((snapshot) => snapshot.documents
            .map((map) => Category.fromMap(map.data))
            .toList());
  }

  void addDefaultCategories() {
    CATEGORIES.asMap().forEach((index, category) async {
      return await usersCollection.document(uid).collection('categories').add({
        'cid': new Uuid().v1(),
        'name': category['name'],
        'icon': category['icon'],
        'enabled': true,
        'orderIndex': index,
        'uid': uid,
      });
    });
  }

  void setCategory(Category category) async {
    return await usersCollection
        .document(uid)
        .collection('categories')
        .document(category.cid)
        .setData(category.toMap());
  }

  void removeAllCategories() async {
    return await usersCollection
        .document(uid)
        .collection('categories')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  // User Info
  Stream<User> findUser() {
    return usersCollection
        .document(uid)
        .collection('user')
        .document(uid)
        .snapshots()
        .map((snapshot) => User.fromMap(snapshot.data));
  }

  Future addUser(User user) async {
    return await usersCollection
        .document(uid)
        .collection('user')
        .document(uid)
        .setData(user.toMap());
  }
}
