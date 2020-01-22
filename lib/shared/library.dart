import 'package:flutter/material.dart';
import 'package:fund_tracker/models/period.dart';
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
  Navigator.popAndPushNamed(context, Navigator.defaultRouteName);
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

  periodStartDate =
      periodStartDate.subtract(new Duration(days: numDaysInPeriod));

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
  return '${date.year.toString()}.${date.month.toString()}.${date.day.toString()}';
}
