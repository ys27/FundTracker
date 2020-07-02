class Suggestion {
  String sid;
  String payee;
  String cid;
  String uid;

  Suggestion({
    this.sid,
    this.payee,
    this.cid,
    this.uid,
  });

  Suggestion.empty(int numExistingCategories) {
    sid = null;
    payee = null;
    cid = null;
    uid = null;
  }

  Suggestion.example() {
    sid = '';
    payee = '';
    cid = '';
    uid = '';
  }

  Suggestion.fromMap(Map<String, dynamic> map) {
    this.sid = map['sid'];
    this.payee = map['payee'];
    this.cid = map['cid'];
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'sid': sid,
      'payee': payee,
      'cid': cid,
      'uid': uid,
    };
  }

  bool equalTo(Suggestion suggestion) {
    return (this.payee == suggestion.payee &&
        this.cid == suggestion.cid &&
        this.uid == suggestion.uid);
  }

  Suggestion clone() {
    return Suggestion(
      sid: this.sid,
      payee: this.payee,
      cid: this.cid,
      uid: this.uid,
    );
  }
}
