class StringUtils {
  static int countMatches(final String str, final String ch) {
    if (str.isEmpty) {
      return 0;
    }
    int count = 0;
    for (int i = 0; i < str.length; i++) {
      if (ch == charAt(str, i)) {
        count++;
      }
    }
    return count;
  }

  static String charAt(String subject, int position) {
    if (subject is! String ||
        subject.length <= position ||
        subject.length + position < 0) {
      return '';
    }

    int _realPosition = position < 0 ? subject.length + position : position;

    return subject[_realPosition];
  }

  static String reverse(final String str) {
    if (str == null) {
      return null;
    }

    return str.split('').reversed.join('');
  }

  static String removeStart(final String str, final String remove) {
    if (str.isEmpty || remove.isEmpty) {
      return str;
    }
    if (str.startsWith(remove)) {
      return str.substring(remove.length);
    }
    return str;
  }
}
