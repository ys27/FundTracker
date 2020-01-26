class Preferences {
  String pid;
  int limitDays;

  Preferences({
    this.pid,
    this.limitDays,
  });

  Preferences.example() {
    pid = '';
    limitDays = 0;
  }

  Preferences.original() {
    pid = '';
    limitDays = 365;
  }

  Preferences.fromMap(Map<String, dynamic> map) {
    this.pid = map['pid'];
    this.limitDays = map['limitDays'];
  }

  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'limitDays': limitDays,
    };
  }

  Preferences setPreference(String property, dynamic value) {
    switch (property) {
      case 'pid':
        this.pid = value;
        break;
      case 'limitDays':
        this.limitDays = value;
        break;
    }
    return this;
  }
}
