class Category {
  String cid;
  String name;
  int icon;
  bool enabled;
  bool unfiltered;
  int orderIndex;
  String uid;

  Category({
    this.cid,
    this.name,
    this.icon,
    this.enabled,
    this.unfiltered,
    this.orderIndex,
    this.uid,
  });

  Category.example() {
    cid = '';
    name = '';
    icon = 0;
    enabled = true;
    unfiltered = false;
    orderIndex = 0;
    uid = '';
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.cid = map['cid'];
    this.name = map['name'];
    this.icon = map['icon'];
    this.enabled = map['enabled'] == 1;
    this.unfiltered = map['unfiltered'] == 1;
    this.orderIndex = map['orderIndex'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'name': name,
      'icon': icon,
      'enabled': enabled ? 1 : 0,
      'unfiltered': unfiltered ? 1 : 0,
      'orderIndex': orderIndex,
      'uid': uid,
    };
  }

  Category setEnabled(bool enabled) {
    this.enabled = enabled;
    return this;
  }

  Category setUnfiltered(bool unfiltered) {
    this.unfiltered = unfiltered;
    return this;
  }

  Category setOrder(int orderIndex) {
    this.orderIndex = orderIndex;
    return this;
  }
}
