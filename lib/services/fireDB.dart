import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/recurringTransaction.dart';
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
        // .getDocuments()
        // .then((snapshots) => snapshots.documents
        //     .map((map) => Transaction.fromMap(map.data))
        //     .toList());
        .snapshots()
        .map((snapshot) => snapshot.documents
            .map((map) => Transaction.fromMap(map.data))
            .toList());
  }

  Future addTransactions(List<Transaction> transactions) async {
    WriteBatch batch = Firestore.instance.batch();
    transactions.forEach((tx) {
      batch.setData(db.collection('transactions').document(tx.tid), tx.toMap());
    });
    await batch.commit();
  }

  Future updateTransactions(List<Transaction> transactions) async {
    WriteBatch batch = Firestore.instance.batch();
    transactions.forEach((tx) {
      batch.updateData(
          db.collection('transactions').document(tx.tid), tx.toMap());
    });
    await batch.commit();
  }

  Future deleteTransactions(List<Transaction> transactions) async {
    WriteBatch batch = Firestore.instance.batch();
    transactions.forEach((tx) {
      batch.delete(db.collection('transactions').document(tx.tid));
    });
    await batch.commit();
  }

  Future deleteAllTransactions() async {
    await db.collection('transactions').getDocuments().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.documents) {
        await doc.reference.delete();
      }
    });
  }

  // Categories
  Stream<List<Category>> getCategories() {
    return db.collection('categories').orderBy('orderIndex').snapshots().map(
        (snapshot) => snapshot.documents
            .map((map) => Category.fromMap(map.data))
            .toList());
  }

  Future addDefaultCategories() async {
    categoriesRegistry.asMap().forEach((index, category) async {
      String cid = Uuid().v1();
      await db.collection('categories').document(cid).setData(
            Category(
              cid: cid,
              name: category['name'],
              icon: category['icon'],
              iconColor: category['color'],
              enabled: true,
              unfiltered: true,
              orderIndex: index,
              uid: uid,
            ).toMap(),
          );
    });
  }

  Future addCategories(List<Category> categories) async {
    WriteBatch batch = Firestore.instance.batch();
    categories.forEach((category) {
      batch.setData(
        db.collection('categories').document(category.cid),
        category.toMap(),
      );
    });
    await batch.commit();
  }

  Future updateCategories(List<Category> categories) async {
    WriteBatch batch = Firestore.instance.batch();
    categories.forEach((category) {
      batch.updateData(
        db.collection('categories').document(category.cid),
        category.toMap(),
      );
    });
    await batch.commit();
  }

  Future deleteCategories(List<Category> categories) async {
    WriteBatch batch = Firestore.instance.batch();
    categories.forEach((category) {
      batch.delete(db.collection('categories').document(category.cid));
    });
    await batch.commit();
  }

  Future deleteAllCategories() async {
    await db.collection('categories').getDocuments().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.documents) {
        await doc.reference.delete();
      }
    });
  }

  // User Info
  Future<User> getUser() {
    return db
        .collection('user')
        .document(uid)
        .get()
        .then((snapshot) => User.fromMap(snapshot.data));
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
          (snapshot) => snapshot.documents
              .map((map) => Period.fromMap(map.data))
              .toList()
              .first,
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

  Future addPeriods(List<Period> periods) async {
    WriteBatch batch = Firestore.instance.batch();
    periods.forEach((period) {
      batch.setData(
          db.collection('periods').document(period.pid), period.toMap());
    });
    await batch.commit();
  }

  Future updatePeriods(List<Period> periods) async {
    WriteBatch batch = Firestore.instance.batch();
    periods.forEach((period) {
      batch.updateData(
          db.collection('periods').document(period.pid), period.toMap());
    });
    await batch.commit();
  }

  Future deletePeriods(List<Period> periods) async {
    WriteBatch batch = Firestore.instance.batch();
    periods.forEach((period) {
      batch.delete(db.collection('periods').document(period.pid));
    });
    await batch.commit();
  }

  Future deleteAllPeriods() async {
    await db.collection('periods').getDocuments().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.documents) {
        await doc.reference.delete();
      }
    });
  }

  // Recurring Transactions
  Stream<List<RecurringTransaction>> getRecurringTransactions() {
    return db
        .collection('recurringTransactions')
        .orderBy('nextDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.documents
            .map((map) => RecurringTransaction.fromMap(map.data))
            .toList());
  }

  Future<RecurringTransaction> getRecurringTransaction(String rid) {
    return db
        .collection('recurringTransactions')
        .document(rid)
        .get()
        .then((snapshot) => RecurringTransaction.fromMap(snapshot.data));
  }

  Future addRecurringTransactions(List<RecurringTransaction> recTxs) async {
    WriteBatch batch = Firestore.instance.batch();
    recTxs.forEach((recTx) {
      batch.setData(
        db.collection('recurringTransactions').document(recTx.rid),
        recTx.toMap(),
      );
    });
    await batch.commit();
  }

  Future updateRecurringTransactions(List<RecurringTransaction> recTxs) async {
    WriteBatch batch = Firestore.instance.batch();
    recTxs.forEach((recTx) {
      batch.updateData(
        db.collection('recurringTransactions').document(recTx.rid),
        recTx.toMap(),
      );
    });
    await batch.commit();
  }

  Future incrementRecurringTransactionsNextDate(
    List<RecurringTransaction> recTxs,
  ) async {
    WriteBatch batch = Firestore.instance.batch();
    recTxs.forEach((recTx) {
      batch.updateData(
        db.collection('recurringTransactions').document(recTx.rid),
        recTx.incrementNextDate().toMap(),
      );
    });
    await batch.commit();
  }

  Future deleteRecurringTransactions(List<RecurringTransaction> recTxs) async {
    WriteBatch batch = Firestore.instance.batch();
    recTxs.forEach((recTx) {
      batch.delete(db.collection('recurringTransactions').document(recTx.rid));
    });
    await batch.commit();
  }

  Future deleteAllRecurringTransactions() async {
    await db
        .collection('recurringTransaction')
        .getDocuments()
        .then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.documents) {
        await doc.reference.delete();
      }
    });
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
        .document(uid)
        .setData(Preferences.original().setPreference('pid', uid).toMap());
  }

  Future addPreferences(Preferences prefs) async {
    await db
        .collection('preferences')
        .document(prefs.pid)
        .setData(prefs.toMap());
  }

  Future updatePreferences(Preferences prefs) async {
    await db.collection('preferences').document(uid).updateData(prefs.toMap());
  }

  Future deletePreferences() async {
    await db.collection('preferences').document(uid).delete();
  }
}
