import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/transaction.dart';
import 'package:fund_tracker/shared/constants.dart';

void goHome(BuildContext context) {
  Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
}

DateTime findPrevPeriodStartDate(Period period) {
  DateTime periodStartDate = period.startDate;
  int numDaysInPeriod;

  switch (period.durationUnit) {
    case DateUnit.Years:
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
    case DateUnit.Months:
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
    case DateUnit.Weeks:
      {
        numDaysInPeriod = period.durationValue * 7;
      }
      break;
    case DateUnit.Days:
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

int findNumDaysInPeriod(
  DateTime periodStartDate,
  int durationValue,
  DateUnit durationUnit,
) {
  switch (durationUnit) {
    case DateUnit.Years:
      return DateTime(
        periodStartDate.year + durationValue,
        periodStartDate.month,
        periodStartDate.day,
      ).difference(periodStartDate).inDays;
      break;
    case DateUnit.Months:
      return DateTime(
        periodStartDate.year,
        periodStartDate.month + durationValue,
        periodStartDate.day,
      ).difference(periodStartDate).inDays;
      break;
    case DateUnit.Weeks:
      return durationValue * 7;
      break;
    default:
      return durationValue;
      break;
  }
}

String getDateStr(DateTime date) {
  String year = date.year.toString();
  String month = date.month.toString();
  String day = date.day.toString();
  return '$year.${getTwoDigitStr(month)}.${getTwoDigitStr(day)}';
}

String getTimeStr(DateTime date) {
  String hour = date.hour.toString();
  String minute = date.minute.toString();
  return '${getTwoDigitStr(hour)}:${getTwoDigitStr(minute)}';
}

String getTwoDigitStr(String str) {
  return str.length == 1 ? '0$str' : str;
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
      Period periodWithNewStartDate =
          period.setStartDate(currentPeriodStartDate);
      int numDaysInPeriod = findNumDaysInPeriod(
        periodWithNewStartDate.startDate,
        periodWithNewStartDate.durationValue,
        periodWithNewStartDate.durationUnit,
      );
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

Map<String, dynamic> findCurrentPeriod(
  List<Map<String, dynamic>> periods,
) {
  int currentPeriodIndex = getCurrentPeriodIndex(periods);
  return currentPeriodIndex == -1 ? {} : periods[currentPeriodIndex];
}

int getCurrentPeriodIndex(List<Map<String, dynamic>> list) {
  DateTime now = DateTime.now();
  return list.indexWhere(
    (map) => map['startDate'].isBefore(now) && map['endDate'].isAfter(now),
  );
}

List<Map<String, dynamic>> appendTotalCategorialAmounts(
    List<Map<String, dynamic>> dividedTransactions) {
  return dividedTransactions
      .map((map) => {
            ...map,
            'amount': map['transactions'].fold(0.0, (a, b) => a + b.amount),
          })
      .toList();
}

List<Map<String, dynamic>> divideTransactionsIntoCategories(
  List<Transaction> transactions,
  List<Category> categories,
) {
  List<Map<String, dynamic>> dividedTransactions = [];

  transactions.forEach((tx) {
    Category category = getCategory(categories, tx.cid);
    bool categoryFound =
        dividedTransactions.any((div) => div['name'] == category.name);
    if (categoryFound) {
      dividedTransactions
          .singleWhere((div) => div['name'] == category.name)['transactions']
          .add(tx);
    } else {
      dividedTransactions.add({
        'name': category.name,
        'transactions': [tx],
        'iconColor': category.iconColor,
      });
    }
  });

  return dividedTransactions;
}

List<Map<String, dynamic>> combineSmallPercentages(
    List<Map<String, dynamic>> categories) {
  final List<Map<String, dynamic>> smallCategories =
      categories.where((category) => category['percentage'] <= 0.05).toList();
  if (smallCategories.length > 0) {
    final double smallCategoriesPercentage =
        smallCategories.fold(0, (prev, curr) => prev + curr['percentage']);
    final double smallCategoriesAmount =
        smallCategories.fold(0, (prev, curr) => prev + curr['amount']);
    List<Map<String, dynamic>> bigCategories =
        categories.where((category) => category['percentage'] > 0.05).toList();

    bigCategories.add({
      'name': 'Etc.',
      'amount': smallCategoriesAmount,
      'percentage': smallCategoriesPercentage,
      'iconColor': Colors.black54,
    });
    return bigCategories;
  }
  return categories;
}

double filterAndGetTotalAmounts(
  List<Transaction> transactions, {
  bool filterOnlyExpenses,
}) {
  return transactions
      .where((tx) => tx.isExpense == filterOnlyExpenses)
      .fold(0.0, (a, b) => a + b.amount);
}

Map<String, double> getRelativePercentages(Map<String, double> values) {
  double max = 0;
  values.forEach((key, value) {
    if (value > max) max = value;
  });
  return {
    'income': values['income'] / max,
    'expenses': values['expenses'] / max,
  };
}

List<Map<String, dynamic>> getPercentagesOutOfTotalAmount(
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

List<Map<String, dynamic>> appendIndividualPercentages(
    List<Map<String, dynamic>> values) {
  double sum = 0;
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

Category getCategory(List<Category> categories, String cid) {
  return categories.singleWhere((cat) => cat.cid == cid, orElse: () => null);
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
