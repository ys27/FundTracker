class User {
  String uid;
  String email;
  String fullname;

  User({
    this.uid,
    this.email,
    this.fullname,
  });

  User.example() {
    uid = '';
    email = '';
    fullname = '';
  }

  User.fromMap(Map<String, dynamic> map) {
    this.uid = map['uid'];
    this.email = map['email'];
    this.fullname = map['fullname'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullname': fullname,
    };
  }
}
