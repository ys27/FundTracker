class Category {
  String cid;
  String name;
  int icon;
  bool enabled;
  int orderIndex;
  String uid;

  Category(
      {this.cid,
      this.name,
      this.icon,
      this.enabled,
      this.orderIndex,
      this.uid});

  Category.example() {
    cid = '';
    name = '';
    icon = 0;
    enabled = true;
    orderIndex = 0;
    uid = '';
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.cid = map['cid'];
    this.name = map['name'];
    this.icon = map['icon'];
    this.enabled = map['enabled'] == 1;
    this.orderIndex = map['orderIndex'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'name': name,
      'icon': icon,
      'enabled': enabled ? 1 : 0,
      'orderIndex': orderIndex,
      'uid': uid,
    };
  }

  Category setEnabled(bool enabled) {
    this.enabled = enabled;
    return this;
  }

  Category setOrder(int orderIndex) {
    this.orderIndex = orderIndex;
    return this;
  }
}
