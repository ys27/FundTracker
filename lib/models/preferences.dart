class Preferences {
  String pid;
  int limitDays;
  bool isLimitDaysEnabled;
  int limitPeriods;
  bool isLimitPeriodsEnabled;
  DateTime limitByDate;
  bool isLimitByDateEnabled;

  Preferences({
    this.pid,
    this.limitDays,
    this.isLimitDaysEnabled,
    this.limitPeriods,
    this.isLimitPeriodsEnabled,
    this.limitByDate,
    this.isLimitByDateEnabled,
  });

  Preferences.example() {
    pid = '';
    limitDays = 0;
    isLimitDaysEnabled = false;
    limitPeriods = 0;
    isLimitPeriodsEnabled = false;
    limitByDate = DateTime.now();
    isLimitByDateEnabled = false;
  }

  Preferences.original() {
    pid = '';
    limitDays = 365;
    isLimitDaysEnabled = true;
    limitPeriods = 12;
    isLimitPeriodsEnabled = false;
    limitByDate = DateTime(DateTime.now().year, 1, 1);
    isLimitByDateEnabled = false;
  }

  Preferences.fromMap(Map<String, dynamic> map) {
    this.pid = map['pid'];
    this.limitDays = map['limitDays'];
    this.isLimitDaysEnabled = map['isLimitDaysEnabled'] == 1;
    this.limitPeriods = map['limitPeriods'];
    this.isLimitPeriodsEnabled = map['isLimitPeriodsEnabled'] == 1;
    this.limitByDate = DateTime.parse(map['limitByDate']);
    this.isLimitByDateEnabled = map['isLimitByDateEnabled'] == 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'limitDays': limitDays,
      'isLimitDaysEnabled': isLimitDaysEnabled ? 1 : 0,
      'limitPeriods': limitPeriods,
      'isLimitPeriodsEnabled': isLimitPeriodsEnabled ? 1 : 0,
      'limitByDate': limitByDate.toString(),
      'isLimitByDateEnabled': isLimitByDateEnabled ? 1 : 0,
    };
  }

  Preferences setPreference(String property, dynamic value) {
    Preferences copy = this.clone();
    switch (property) {
      case 'pid':
        copy.pid = value;
        break;
      case 'limitDays':
        copy.limitDays = value;
        break;
      case 'isLimitDaysEnabled':
        copy.isLimitDaysEnabled = value;
        break;
      case 'limitPeriods':
        copy.limitPeriods = value;
        break;
      case 'isLimitPeriodsEnabled':
        copy.isLimitPeriodsEnabled = value;
        break;
      case 'limitByDate':
        copy.limitByDate = value;
        break;
      case 'isLimitByDateEnabled':
        copy.isLimitByDateEnabled = value;
        break;
    }
    return copy;
  }

  Preferences clone() {
    return Preferences(
      pid: this.pid,
      limitDays: this.limitDays,
      isLimitDaysEnabled: this.isLimitDaysEnabled,
      limitPeriods: this.limitPeriods,
      isLimitPeriodsEnabled: this.isLimitPeriodsEnabled,
      limitByDate: this.limitByDate,
      isLimitByDateEnabled: this.isLimitByDateEnabled,
    );
  }
}
