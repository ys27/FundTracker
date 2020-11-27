import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/plannedTransaction.dart';
import 'package:fund_tracker/models/suggestion.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/shared/library.dart';

class FireDBService {
  final String uid;
  DocumentReference db;

  FireDBService(this.uid) {
    this.db = FirebaseFirestore.instance.collection('users').doc(this.uid);
  }

  // Transactions
  Future<List<Transaction>> getTransactions() {
    return db
        .collection('transactions')
        .orderBy('date', descending: true)
        .get()
        .then((snapshot) => snapshot.docs
            .map((map) => Transaction.fromMap(map.data()))
            .toList());
  }

  Future addTransactions(List<Transaction> transactions) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    transactions.forEach((tx) {
      batch.set(db.collection('transactions').doc(tx.tid), tx.toMap());
    });
    await batch.commit();
  }

  Future updateTransactions(List<Transaction> transactions) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    transactions.forEach((tx) {
      batch.update(
          db.collection('transactions').doc(tx.tid), tx.toMap());
    });
    await batch.commit();
  }

  Future deleteTransactions(List<Transaction> transactions) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    transactions.forEach((tx) {
      batch.delete(db.collection('transactions').doc(tx.tid));
    });
    await batch.commit();
  }

  Future deleteAllTransactions() async {
    await db.collection('transactions').get().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });
  }

  // Categories
  Future<List<Category>> getCategories() {
    return db
        .collection('categories')
        .orderBy('orderIndex')
        .get()
        .then((snapshot) => snapshot.docs
            .map((map) => Category.fromMap(map.data()))
            .toList());
  }

  Future addCategories(List<Category> categories) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    categories.forEach((category) {
      batch.set(
        db.collection('categories').doc(category.cid),
        category.toMap(),
      );
    });
    await batch.commit();
  }

  Future updateCategories(List<Category> categories) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    categories.forEach((category) {
      batch.update(
        db.collection('categories').doc(category.cid),
        category.toMap(),
      );
    });
    await batch.commit();
  }

  Future deleteCategories(List<Category> categories) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    categories.forEach((category) {
      batch.delete(db.collection('categories').doc(category.cid));
    });
    await batch.commit();
  }

  Future deleteAllCategories() async {
    await db.collection('categories').get().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });
  }

  // User Info
  Future<User> getUser() {
    return db
        .collection('user')
        .doc(uid)
        .get()
        .then((snapshot) => User.fromMap(snapshot.data()));
  }

  Future addUser(User user) async {
    await db.collection('user').doc(uid).set(user.toMap());
  }

  // Periods
  Future<List<Period>> getPeriods() {
    return db
        .collection('periods')
        .orderBy('isDefault', descending: true)
        .get()
        .then((snapshot) =>
            snapshot.docs.map((map) => Period.fromMap(map.data())).toList());
  }

  Future<Period> getDefaultPeriod() {
    return db
        .collection('periods')
        .where('isDefault', isEqualTo: 1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.length > 0) {
        return snapshot.docs
            .map((map) => Period.fromMap(map.data()))
            .toList()
            .first;
      } else {
        return Period.monthly();
      }
    });
  }

  Future setRemainingNotDefault(Period period) async {
    db.collection('periods').snapshots().map((snapshot) {
      snapshot.docs.map((map) async {
        return await map.reference.update({'isDefault': 0});
      });
    });
    await db
        .collection('periods')
        .doc(period.pid)
        .update({'isDefault': 1});
  }

  Future addPeriods(List<Period> periods) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    periods.forEach((period) {
      batch.set(
          db.collection('periods').doc(period.pid), period.toMap());
    });
    await batch.commit();
  }

  Future updatePeriods(List<Period> periods) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    periods.forEach((period) {
      batch.update(
          db.collection('periods').doc(period.pid), period.toMap());
    });
    await batch.commit();
  }

  Future deletePeriods(List<Period> periods) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    periods.forEach((period) {
      batch.delete(db.collection('periods').doc(period.pid));
    });
    await batch.commit();
  }

  Future deleteAllPeriods() async {
    await db.collection('periods').get().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });
  }

  // Planned Transactions
  Future<List<PlannedTransaction>> getPlannedTransactions() {
    return db
        .collection('plannedTransactions')
        .orderBy('nextDate', descending: false)
        .get()
        .then((snapshot) => snapshot.docs
            .map((map) => PlannedTransaction.fromMap(map.data()))
            .toList());
  }

  Future<PlannedTransaction> getPlannedTransaction(String rid) {
    return db.collection('plannedTransactions').doc(rid).get().then(
        (snapshot) => snapshot.data != null
            ? PlannedTransaction.fromMap(snapshot.data())
            : null);
  }

  Future addPlannedTransactions(List<PlannedTransaction> plannedTxs) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    plannedTxs.forEach((plannedTx) {
      batch.set(
        db.collection('plannedTransactions').doc(plannedTx.rid),
        plannedTx.toMap(),
      );
    });
    await batch.commit();
  }

  Future updatePlannedTransactions(List<PlannedTransaction> plannedTxs) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    plannedTxs.forEach((plannedTx) {
      batch.update(
        db.collection('plannedTransactions').doc(plannedTx.rid),
        plannedTx.toMap(),
      );
    });
    await batch.commit();
  }

  Future incrementPlannedTransactionsNextDate(
    List<PlannedTransaction> plannedTxs,
  ) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    plannedTxs.forEach((plannedTx) {
      PlannedTransaction nextRecTx = plannedTx.incrementNextDate();
      if ((nextRecTx.endDate == null && nextRecTx.occurrenceValue == null) ||
          (nextRecTx.endDate != null &&
              getDateNotTime(nextRecTx.nextDate)
                  .subtract(Duration(microseconds: 1))
                  .isBefore(nextRecTx.endDate)) ||
          (nextRecTx.occurrenceValue != null &&
              nextRecTx.occurrenceValue > 0)) {
        batch.update(
          db.collection('plannedTransactions').doc(plannedTx.rid),
          nextRecTx.toMap(),
        );
      } else {
        batch
            .delete(db.collection('plannedTransactions').doc(plannedTx.rid));
      }
    });
    await batch.commit();
  }

  Future deletePlannedTransactions(List<PlannedTransaction> plannedTxs) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    plannedTxs.forEach((plannedTx) {
      batch.delete(db.collection('plannedTransactions').doc(plannedTx.rid));
    });
    await batch.commit();
  }

  Future deleteAllPlannedTransactions() async {
    await db
        .collection('plannedTransaction')
        .get()
        .then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });
  }

  // Preferences
  Future<Preferences> getPreferences() {
    return db
        .collection('preferences')
        .doc(uid)
        .get()
        .then((snapshot) => Preferences.fromMap(snapshot.data()));
  }

  Future addDefaultPreferences() async {
    await db
        .collection('preferences')
        .doc(uid)
        .set(Preferences.original().setPreference('pid', uid).toMap());
  }

  Future addPreferences(Preferences prefs) async {
    await db
        .collection('preferences')
        .doc(prefs.pid)
        .set(prefs.toMap());
  }

  Future updatePreferences(Preferences prefs) async {
    await db.collection('preferences').doc(uid).update(prefs.toMap());
  }

  Future deletePreferences() async {
    await db.collection('preferences').doc(uid).delete();
  }

  // Hidden Suggestions
  Future<List<Suggestion>> getHiddenSuggestions() {
    return db.collection('hiddenSuggestions').get().then((snapshot) =>
        snapshot.docs.map((map) => Suggestion.fromMap(map.data())).toList());
  }

  Future addHiddenSuggestions(List<Suggestion> suggestions) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    suggestions.forEach((suggestion) {
      batch.set(db.collection('hiddenSuggestions').doc(suggestion.sid),
          suggestion.toMap());
    });
    await batch.commit();
  }

  Future deleteHiddenSuggestions(List<Suggestion> suggestions) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    suggestions.forEach((suggestion) {
      batch.delete(db.collection('hiddenSuggestions').doc(suggestion.sid));
    });
    await batch.commit();
  }
}
