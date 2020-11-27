import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/period.dart';
import 'package:fund_tracker/models/preferences.dart';
import 'package:fund_tracker/models/suggestion.dart';
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

  periodStartDate =
      periodStartDate.subtract(Duration(days: numDaysInPeriod - 1, hours: 23));

  return getDateNotTime(periodStartDate);
}

DateTime findStartDateOfGivenDateTime(DateTime date, Period period) {
  DateTime iteratingDate = period.startDate;
  while (iteratingDate.isAfter(date)) {
    iteratingDate = findPrevPeriodStartDate(period.setStartDate(iteratingDate));
  }
  return iteratingDate;
}

DateTime findStartDateOfGivenNumPeriodsAgo(int numPeriods, Period period) {
  DateTime iteratingDate = period.startDate;
  for (int i = 1; i < numPeriods; i++) {
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
  if (date == null) {
    return 'N/A';
  }
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

DateTime getClosestDayStart(DateTime dateTime) {
  DateTime nextDateTime = dateTime.add(Duration(hours: 2));
  return DateTime(nextDateTime.year, nextDateTime.month, nextDateTime.day);
}

List<Map<String, dynamic>> divideTransactionsIntoPeriods(
  List<Transaction> transactions,
  Period period,
) {
  List<Map<String, dynamic>> periodsList = [];

  DateTime latestTransactionDate = transactions.first.date;

  if (transactions.length > 0) {
    DateTime iteratingPeriodStartDate =
        findStartDateOfGivenDateTime(transactions.last.date, period);
    while (iteratingPeriodStartDate
        .isBefore(latestTransactionDate.add(Duration(microseconds: 1)))) {
      Period periodWithNewStartDate =
          period.setStartDate(iteratingPeriodStartDate);
      int numDaysInPeriod = findNumDaysInPeriod(
        periodWithNewStartDate.startDate,
        periodWithNewStartDate.durationValue,
        periodWithNewStartDate.durationUnit,
      );
      DateTime nextPeriodStartDate = getClosestDayStart(
        iteratingPeriodStartDate.add(Duration(days: numDaysInPeriod)),
      );
      periodsList.insert(
        0,
        {
          'startDate': iteratingPeriodStartDate,
          'endDate': nextPeriodStartDate.subtract(Duration(microseconds: 1)),
          'transactions': transactions
              .where((tx) =>
                  tx.date.isAfter(iteratingPeriodStartDate
                      .subtract(Duration(microseconds: 1))) &&
                  tx.date.isBefore(nextPeriodStartDate))
              .toList(),
        },
      );
      iteratingPeriodStartDate = nextPeriodStartDate;
    }
  }

  // Remove periods without any txs
  // return periodsList
  //     .where((period) => period['transactions'].length > 0)
  //     .toList();
  return periodsList;
}

List<Transaction> filterTransactionsByLimit(
  List<Transaction> transactions,
  Preferences prefs,
) {
  if (prefs.isLimitDaysEnabled) {
    return transactions
        .where((tx) => tx.date.isAfter(
            getDateNotTime(DateTime.now().add(Duration(days: 1)))
                .subtract(Duration(days: prefs.limitDays, milliseconds: 1))))
        .toList();
  } else if (prefs.isLimitByDateEnabled) {
    return transactions
        .where((tx) => tx.date
            .isAfter(prefs.limitByDate.subtract(Duration(microseconds: 1))))
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
      .map((category) => {
            ...category,
            'amount': category['transactions']
                .fold(0.0, (a, b) => a + (b.isExpense ? 1 : -1) * b.amount)
          })
      .toList()
      .where((category) => category['amount'] > 0)
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
        'icon': category.icon,
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
      'name': 'Miscellaneous',
      'amount': smallCategoriesAmount,
      'percentage': smallCategoriesPercentage,
      'iconColor': Colors.black54,
      'icon': CommunityMaterialIcons.shape_outline.codePoint,
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
  if (max == 0) {
    return {
      'income': 0.0,
      'expenses': 0.0,
    };
  }
  return {
    'income': values['income'] / max,
    'expenses': values['expenses'] / max,
  };
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

List<Map<String, dynamic>> getSuggestions(List<Transaction> txs, String uid) {
  List<Map<String, dynamic>> suggestions = [];

  txs.forEach((tx) {
    final int suggestionIndex = suggestions.indexWhere((map) {
      Suggestion suggestion = map['suggestion'];
      return suggestion.equalTo(Suggestion(
        payee: tx.payee,
        cid: tx.cid,
        uid: uid,
      ));
    });

    if (suggestionIndex != -1) {
      suggestions[suggestionIndex]['count']++;
      if (tx.date.isAfter(suggestions[suggestionIndex]['latestDate'])) {
        suggestions[suggestionIndex]['latestDate'] = tx.date;
      }
    } else {
      suggestions.add({
        'suggestion': Suggestion(
          sid: '${tx.payee}::${tx.cid}',
          payee: tx.payee,
          cid: tx.cid,
          uid: uid,
        ),
        'count': 1,
        'latestDate': tx.date
      });
    }
  });

  return suggestions;
}

String getAmountStr(double amount) {
  return amount < 0
      ? '-\$${abs(amount).toStringAsFixed(2)}'
      : '\$${amount.toStringAsFixed(2)}';
}

Category getCategory(List<Category> categories, String cid) {
  return categories.singleWhere((cat) => cat.cid == cid, orElse: () => null);
}

double getAverage(List<double> numbers) {
  return numbers.fold(0.0, (a, b) => a + b) / numbers.length;
}

double abs(double value) => value < 0 ? -1 * value : value;
dynamic max(dynamic a, dynamic b) => a > b ? a : b;
dynamic min(dynamic a, dynamic b) => a < b ? a : b;
