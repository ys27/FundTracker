String emailValidator(val) {
  if (val.isEmpty) {
    return 'Email is required.';
  }
  if (!RegExp(
          r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(val)) {
    return 'Not a valid email address format.';
  }
  return null;
}

String passwordValidator(val) {
  if (val.length < 6) {
    return 'The password must be 6 or more characters.';
  }
  return null;
}

String passwordConfirmValidator(val, password) {
  if (val.isEmpty) {
    return 'This is a required field.';
  }
  if (val != password) {
    return 'The passwords do not match.';
  }
  return null;
}

String fullNameValidator(val) {
  if (val.isEmpty) {
    return 'This is a required field.';
  }
  return null;
}