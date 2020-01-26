import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/categories/categoriesRegistry.dart';
import 'package:uuid/uuid.dart';

class FireDBService {
  final String uid;
  DocumentReference db;

  FireDBService(this.uid) {
    this.db = Firestore.instance.collection('users').document(this.uid);
  }

  // Transactions
  Stream<List<Transaction>> getTransactions() {
    return db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.documents
            .map((map) => Transaction.fromMap(map.data))
            .toList());
  }

  void addTransaction(Transaction tx) {
    db.collection('transactions').add(tx.toMap());
  }

  void updateTransaction(Transaction tx) {
    db.collection('transactions').document(tx.tid).setData(tx.toMap());
  }

  void deleteTransaction(Transaction tx) {
    db.collection('transactions').document(tx.tid).delete();
  }

  // Categories
  Stream<List<Category>> getCategories() {
    return db.collection('categories').orderBy('orderIndex').snapshots().map(
        (snapshot) => snapshot.documents
            .map((map) => Category.fromMap(map.data))
            .toList());
  }

  void addDefaultCategories() {
    CATEGORIES.asMap().forEach((index, category) {
      db.collection('categories').add({
        'cid': Uuid().v1(),
        'name': category['name'],
        'icon': category['icon'],
        'enabled': true,
        'orderIndex': index,
        'uid': uid,
      });
    });
  }

  void setCategory(Category category) {
    db
        .collection('categories')
        .document(category.cid)
        .setData(category.toMap());
  }

  void removeAllCategories() {
    db.collection('categories').getDocuments().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  // User Info
  Stream<User> findUser() {
    return db
        .collection('user')
        .document(uid)
        .snapshots()
        .map((snapshot) => User.fromMap(snapshot.data));
  }

  void addUser(User user) {
    db.collection('user').document(uid).setData(user.toMap());
  }

  // Periods
  Stream<List<Period>> getPeriods() {
    return db
        .collection('periods')
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.documents.map((map) => Period.fromMap(map.data)).toList());
  }

  Stream<Period> getDefaultPeriod() {
    return db
        .collection('periods')
        .where('isDefault', isEqualTo: 1)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.documents
                  .map((map) => Period.fromMap(map.data))
                  .toList()
                  .first ??
              Period.monthly(),
        );
  }

  void setRemainingNotDefault(Period period) {
    db.collection('periods').snapshots().map((snapshot) {
      snapshot.documents
          .map((map) => map.reference.updateData({'isDefault': 0}));
    });
    db.collection('periods').document(period.pid).updateData({'isDefault': 1});
  }

  void addPeriod(Period period) {
    db.collection('periods').add(period.toMap());
  }

  void updatePeriod(Period period) {
    db.collection('periods').document(period.pid).setData(period.toMap());
  }

  void deletePeriod(Period period) {
    db.collection('periods').document(period.pid).delete();
  }

  // Preferences
  Stream<Preferences> getPreferences() {
    return db
        .collection('preferences')
        .document(uid)
        .snapshots()
        .map((snapshot) => Preferences.fromMap(snapshot.data));
  }

  void addDefaultPreferences() {
    db
        .collection('preferences')
        .add(Preferences.original().setPreference('pid', uid).toMap());
  }

  void updatePreferences(Preferences prefs) {
    db.collection('preferences').document(uid).setData(prefs.toMap());
  }

  void removePreferences() {
    db.collection('preferences').document(uid).delete();
  }
}
