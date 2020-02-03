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
            .difference(DateTime(
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
            .difference(DateTime(
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

  return getDateNotTime(periodStartDate);
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
      return DateTime(
        periodStartDate.year + period.durationValue,
        periodStartDate.month,
        periodStartDate.day,
      ).difference(periodStartDate).inDays;
      break;
    case DurationUnit.Months:
      return DateTime(
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

String getDateStr(DateTime date) {
  String month = date.month.toString();
  String day = date.day.toString();
  return '${date.year.toString()}.${month.length == 1 ? '0$month' : month}.${day.length == 1 ? '0$day' : day}';
}

DateTime getDateNotTime(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

List<Map<String, dynamic>> divideTransactionsIntoPeriods(
  List<Transaction> transactions,
  Period period,
) {
  List<Map<String, dynamic>> periodsList = [];

  if (transactions.length > 0) {
    DateTime currentPeriodStartDate =
        findFirstPeriodDate(transactions.last, period);
    while (currentPeriodStartDate.isBefore(
      transactions.first.date.add(Duration(milliseconds: 1)),
    )) {
      int numDaysInPeriod =
          findNumDaysInPeriod(period.setStartDate(currentPeriodStartDate));
      DateTime nextPeriodStartDate = getDateNotTime(
        currentPeriodStartDate.add(Duration(days: numDaysInPeriod)),
      );
      periodsList.insert(
        0,
        {
          'startDate': currentPeriodStartDate,
          'endDate': nextPeriodStartDate.subtract(Duration(microseconds: 1)),
          'transactions': transactions
              .where((tx) =>
                  tx.date.isAfter(currentPeriodStartDate
                      .subtract(Duration(microseconds: 1))) &&
                  tx.date.isBefore(nextPeriodStartDate))
              .toList(),
        },
      );
      currentPeriodStartDate = nextPeriodStartDate;
    }
  }
  return periodsList;
}

List<Map<String, dynamic>> filterByLimitAndDivideIntoPeriods(
  List<Transaction> transactions,
  Preferences prefs,
  Period currentPeriod,
) {
  List<Transaction> filteredTransactions =
      filterTransactionsByLimit(transactions, prefs);
  List<Map<String, dynamic>> dividedTransactions =
      divideTransactionsIntoPeriods(filteredTransactions, currentPeriod);
  if (prefs.isLimitPeriodsEnabled) {
    dividedTransactions =
        filterPeriodsWithLimit(dividedTransactions, prefs.limitPeriods);
  }
  // Remove periods without any txs
  return dividedTransactions
      .where((period) => period['transactions'].length > 0)
      .toList();
}

List<Transaction> filterTransactionsByLimit(
  List<Transaction> transactions,
  Preferences prefs,
) {
  if (prefs.isLimitDaysEnabled) {
    return transactions
        .where((tx) => tx.date.isAfter(DateTime.now()
            .subtract(Duration(days: prefs.limitDays, milliseconds: 1))))
        .toList();
  } else if (prefs.isLimitByDateEnabled) {
    return transactions
        .where((tx) => tx.date
            .isAfter(prefs.limitByDate.subtract(Duration(milliseconds: 1))))
        .toList();
  } else {
    return transactions;
  }
}

List<Map<String, dynamic>> filterPeriodsWithLimit(
  List<Map<String, dynamic>> periods,
  int numPeriods,
) {
  int currentPeriodIndex = getCurrentPeriodIndex(periods);
  return sublist(periods, 0, currentPeriodIndex + numPeriods);
}

List<Map<String, dynamic>> sublist(
    List<Map<String, dynamic>> list, int start, int end) {
  return list.sublist(start, min(end, list.length));
}

List<Map<String, dynamic>> findCurrentAndPreviousPeriods(
  List<Map<String, dynamic>> periods,
) {
  int currentPeriodIndex = getCurrentPeriodIndex(periods);

  if (currentPeriodIndex == -1) {
    return [];
  } else {
    return sublist(periods, currentPeriodIndex, currentPeriodIndex + 2);
  }
}

int getCurrentPeriodIndex(List<Map<String, dynamic>> list) {
  DateTime now = DateTime.now();
  return list.indexWhere(
    (map) => map['startDate'].isBefore(now) && map['endDate'].isAfter(now),
  );
}

List<Map<String, dynamic>> divideTransactionsIntoCategories(
  List<Transaction> transactions,
) {
  List<Map<String, dynamic>> dividedTransactions = [];
  transactions.forEach((tx) {
    bool categoryFound =
        dividedTransactions.any((div) => div['category'] == tx.category);
    if (categoryFound) {
      dividedTransactions
          .singleWhere((div) => div['category'] == tx.category)['transactions']
          .add(tx);
    } else {
      dividedTransactions.add({
        'category': tx.category,
        'transactions': [tx],
      });
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
            'percentage': max == 0 ? 0.0 : v['amount'] / max,
          })
      .toList();
}

List<Map<String, dynamic>> getPercentagesOutOfTotalIncome(
  List<Map<String, dynamic>> values,
  double totalIncome,
) {
  return values
      .map((v) => {
            ...v,
            'percentage': v['amount'] / totalIncome,
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
