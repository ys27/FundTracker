class Category {
  String cid;
  String name;
  int icon;
  bool enabled;
  int orderIndex;

  Category.empty();

  Category({this.cid, this.name, this.icon, this.enabled, this.orderIndex});

  Category.fromMap(Map<String, dynamic> map) {
    this.cid = map['cid'];
    this.name = map['name'];
    this.icon = map['icon'];
    this.enabled = map['enabled'];
    this.orderIndex = map['orderIndex'];
  }

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'name': name,
      'icon': icon,
      'enabled': enabled,
      'orderIndex': orderIndex,
    };
  }
}
