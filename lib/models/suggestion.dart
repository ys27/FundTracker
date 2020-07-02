class HiddenSuggestion {
  String sid;
  String tid;
  String cid;
  bool hidden;
  String uid;

  HiddenSuggestion({
    this.sid,
    this.tid,
    this.cid,
    this.hidden,
    this.uid,
  });

  HiddenSuggestion.empty(int numExistingCategories) {
    sid = null;
    tid = null;
    cid = null;
    hidden = true;
    uid = null;
  }

  HiddenSuggestion.example() {
    sid = '';
    tid = '';
    cid = '';
    hidden = true;
    uid = '';
  }

  HiddenSuggestion.fromMap(Map<String, dynamic> map) {
    this.sid = map['sid'];
    this.tid = map['tid'];
    this.cid = map['cid'];
    this.hidden = map['hidden'] == 1;
    this.uid = map['uid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'sid': sid,
      'tid': tid,
      'cid': cid,
      'hidden': hidden ? 1 : 0,
      'uid': uid,
    };
  }

  bool equalTo(HiddenSuggestion HiddenSuggestion) {
    return (this.sid == HiddenSuggestion.sid &&
        this.tid == HiddenSuggestion.tid &&
        this.cid == HiddenSuggestion.cid &&
        this.hidden == HiddenSuggestion.hidden &&
        this.uid == HiddenSuggestion.uid);
  }

  HiddenSuggestion clone() {
    return HiddenSuggestion(
      sid: this.sid,
      tid: this.tid,
      cid: this.cid,
      hidden: this.hidden,
      uid: this.uid,
    );
  }
}
