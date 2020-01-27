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

  Future addTransaction(Transaction tx) async {
    await db.collection('transactions').add(tx.toMap());
  }

  Future updateTransaction(Transaction tx) async {
    await db.collection('transactions').document(tx.tid).setData(tx.toMap());
  }

  Future deleteTransaction(Transaction tx) async {
    await db.collection('transactions').document(tx.tid).delete();
  }

  // Categories
  Stream<List<Category>> getCategories() {
    return db.collection('categories').orderBy('orderIndex').snapshots().map(
        (snapshot) => snapshot.documents
            .map((map) => Category.fromMap(map.data))
            .toList());
  }

  Future addDefaultCategories() async {
    CATEGORIES.asMap().forEach((index, category) async {
      await db.collection('categories').add({
        'cid': Uuid().v1(),
        'name': category['name'],
        'icon': category['icon'],
        'enabled': true,
        'orderIndex': index,
        'uid': uid,
      });
    });
  }

  Future setCategory(Category category) async {
    await db
        .collection('categories')
        .document(category.cid)
        .setData(category.toMap());
  }

  Future deleteAllCategories() async {
    await db.collection('categories').getDocuments().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.documents) {
        await doc.reference.delete();
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

  Future addUser(User user) async {
    await db.collection('user').document(uid).setData(user.toMap());
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

  Future setRemainingNotDefault(Period period) async {
    db.collection('periods').snapshots().map((snapshot) {
      snapshot.documents.map((map) async {
        return await map.reference.updateData({'isDefault': 0});
      });
    });
    await db
        .collection('periods')
        .document(period.pid)
        .updateData({'isDefault': 1});
  }

  Future addPeriod(Period period) async {
    await db.collection('periods').add(period.toMap());
  }

  Future updatePeriod(Period period) async {
    await db.collection('periods').document(period.pid).setData(period.toMap());
  }

  Future deletePeriod(Period period) async {
    await db.collection('periods').document(period.pid).delete();
  }

  // Preferences
  Stream<Preferences> getPreferences() {
    return db
        .collection('preferences')
        .document(uid)
        .snapshots()
        .map((snapshot) => Preferences.fromMap(snapshot.data));
  }

  Future addDefaultPreferences() async {
    await db
        .collection('preferences')
        .add(Preferences.original().setPreference('pid', uid).toMap());
  }

  Future updatePreferences(Preferences prefs) async {
    await db.collection('preferences').document(uid).setData(prefs.toMap());
  }

  Future deletePreferences() async {
    await db.collection('preferences').document(uid).delete();
  }
}
