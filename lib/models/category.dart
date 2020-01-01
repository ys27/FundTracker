class Category {
  String cid;
  String name;
  int icon;
  bool enabled;

  Category({this.cid, this.name, this.icon, this.enabled});

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'name': name,
      'icon': icon,
      'enabled': enabled,
    };
  }
}
