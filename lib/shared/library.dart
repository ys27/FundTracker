import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/shared/constants.dart';

void openPage(BuildContext context, Widget page) {
  goHome(context);
  showDialog(
    context: context,
    builder: (context) {
      return page;
    },
  );
}

void goHome(BuildContext context) {
  Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
}

DateTime findPrevPeriodStartDate(Period period) {
  DateTime periodStartDate = period.startDate;
  int numDaysInPeriod;

  switch (period.durationUnit) {
    case DurationUnit.Years:
      {
        numDaysInPeriod = periodStartDate
            .difference(DateTime.utc(
              periodStartDate.year - period.durationValue,
              periodStartDate.month,
              periodStartDate.day,
            ))
            .inDays;
      }
      break;
    case DurationUnit.Months:
      {
        int prevDateTimeYear = periodStartDate.month - period.durationValue <= 0
            ? periodStartDate.year - 1
            : periodStartDate.year;
        int prevDateTimeMonth =
            periodStartDate.month - period.durationValue == 0
                ? 12
                : periodStartDate.month - period.durationValue;
        numDaysInPeriod = periodStartDate
            .difference(DateTime.utc(
              prevDateTimeYear,
              prevDateTimeMonth,
              periodStartDate.day,
            ))
            .inDays;
      }
      break;
    case DurationUnit.Weeks:
      {
        numDaysInPeriod = period.durationValue * 7;
      }
      break;
    case DurationUnit.Days:
      {
        numDaysInPeriod = period.durationValue;
      }
      break;
  }

  periodStartDate = periodStartDate.subtract(Duration(days: numDaysInPeriod));

  return DateTime.utc(
      periodStartDate.year, periodStartDate.month, periodStartDate.day);
}

DateTime findFirstPeriodDate(Transaction firstTx, Period period) {
  DateTime iteratingDate = period.startDate;
  while (iteratingDate.isAfter(firstTx.date)) {
    iteratingDate = findPrevPeriodStartDate(period.setStartDate(iteratingDate));
  }

  return iteratingDate;
}

int findNumDaysInPeriod(Period period) {
  DateTime periodStartDate = period.startDate;

  switch (period.durationUnit) {
    case DurationUnit.Years:
      return DateTime.utc(
        periodStartDate.year + period.durationValue,
        periodStartDate.month,
        periodStartDate.day,
      ).difference(periodStartDate).inDays;
      break;
    case DurationUnit.Months:
      return DateTime.utc(
        periodStartDate.year,
        periodStartDate.month + period.durationValue,
        periodStartDate.day,
      ).difference(periodStartDate).inDays;
      break;
    case DurationUnit.Weeks:
      return period.durationValue * 7;
      break;
    default:
      return period.durationValue;
      break;
  }
}

String getDate(DateTime date) {
  String day = date.day.toString();
  return '${date.year.toString()}.${date.month.toString()}.${day.length == 1 ? '0$day' : day}';
}

String checkIfInteger(String val) {
  if (val.isEmpty) {
    return 'Enter a value for the duration.';
  } else if (val.contains('.')) {
    return 'This value must be an integer.';
  } else if (int.parse(val) <= 0) {
    return 'This value must be greater than 0';
  }
  return null;
}

List<Map<String, dynamic>> divideTransactionsIntoPeriods(
    List<Transaction> transactions, Period period) {
  List<Map<String, dynamic>> periodsList = [];

  if (transactions.length > 0) {
    DateTime iteratingPeriodStartDate =
        findFirstPeriodDate(transactions.last, period);

    while (iteratingPeriodStartDate.isBefore(transactions.first.date)) {
      int numDaysInPeriod =
          findNumDaysInPeriod(period.setStartDate(iteratingPeriodStartDate));
      DateTime iteratingNextPeriodStartDate =
          iteratingPeriodStartDate.add(Duration(days: numDaysInPeriod));
      iteratingNextPeriodStartDate = DateTime.utc(
        iteratingNextPeriodStartDate.year,
        iteratingNextPeriodStartDate.month,
        iteratingNextPeriodStartDate.day,
      );

      periodsList.insert(
        0,
        {
          'startDate': iteratingPeriodStartDate,
          'endDate':
              iteratingNextPeriodStartDate.subtract(Duration(microseconds: 1)),
          'transactions': transactions
              .where((tx) =>
                  tx.date.isAfter(iteratingPeriodStartDate) &&
                  tx.date.isBefore(iteratingNextPeriodStartDate))
              .toList(),
        },
      );

      iteratingPeriodStartDate = iteratingNextPeriodStartDate;
    }
  }

  return periodsList;
}

List<Transaction> filterTransactionsByLimit(
    List<Transaction> transactions, Preferences prefs) {
  if (prefs.isLimitDaysEnabled) {
    return transactions
        .where((tx) => tx.date
            .isAfter(DateTime.now().subtract(Duration(days: prefs.limitDays))))
        .toList();
  } else if (prefs.isLimitByDateEnabled) {
    return transactions
        .where((tx) => tx.date.isAfter(prefs.limitByDate))
        .toList();
  } else {
    return transactions;
  }
}

List<Map<String, dynamic>> filterTransactionsByPeriods(
    List<Map<String, dynamic>> transactions, Preferences prefs) {
  DateTime now = DateTime.now();
  int currentDatePeriodIndex = transactions.indexWhere(
      (map) => map['startDate'].isBefore(now) && map['endDate'].isAfter(now));
  return transactions.sublist(
    0,
    min(
      currentDatePeriodIndex + prefs.limitPeriods,
      transactions.length,
    ),
  );
}

List<Map<String, dynamic>> divideTransactionsIntoCategories(
    List<Transaction> transactions) {
  List<Map<String, dynamic>> dividedTransactions = [];
  transactions.forEach((tx) {
    if (dividedTransactions
        .where((div) => div['category'] == tx.category)
        .toList()
        .isEmpty) {
      dividedTransactions.add({
        'category': tx.category,
        'transactions': [tx],
      });
    } else {
      dividedTransactions
          .firstWhere((div) => div['category'] == tx.category)['transactions']
          .add(tx);
    }
  });
  return dividedTransactions;
}

List<Map<String, dynamic>> getRelativePercentages(
    List<Map<String, dynamic>> values) {
  double max = values.first['amount'];
  values.forEach((e) {
    if (e['amount'] > max) max = e['amount'];
  });
  return values
      .map((v) => {
            ...v,
            'percentage': v['amount'] / max,
          })
      .toList();
}

List<Map<String, dynamic>> getTotalValues(
    List<Map<String, dynamic>> dividedTransactions) {
  return dividedTransactions
      .map((map) => {
            'category': map['category'],
            'amount': map['transactions'].fold(0.0, (a, b) => a + b.amount),
          })
      .toList();
}

List<Map<String, dynamic>> getIndividualPercentages(
    List<Map<String, dynamic>> values) {
  double sum = values.first['amount'];
  values.forEach((e) {
    sum += e['amount'];
  });
  return values
      .map((v) => {
            ...v,
            'percentage': v['amount'] / sum,
          })
      .toList();
}

String getAmountStr(double amount) {
  return amount < 0
      ? '-\$${abs(amount).toStringAsFixed(2)}'
      : '\$${amount.toStringAsFixed(2)}';
}

double abs(double value) {
  if (value < 0) {
    return -1 * value;
  }
  return value;
}

int min(int a, int b) {
  if (a < b) {
    return a;
  }
  return b;
}
