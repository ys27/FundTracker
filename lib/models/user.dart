class User {
  String uid;
  String email;
  String fullname;

  User({this.uid, this.email, this.fullname});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullname': fullname,
    };
  }
}
