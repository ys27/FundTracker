import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import 'utils.dart';

class NumericTextField extends StatefulWidget {
  final TextEditingController controller;
  final String initialValue;
  final TextAlign textAlign;
  final TextStyle style;
  final bool readOnly;
  final InputDecoration decoration;
  final Function onTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onSubmitted;
  final bool allowNegativeResult;

  NumericTextField({
    Key key,
    this.initialValue,
    this.controller,
    this.textAlign,
    this.style,
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.allowNegativeResult = true,
  }) : super(key: key);

  @override
  _NumericTextFieldState createState() => _NumericTextFieldState();
}

class _NumericTextFieldState extends State<NumericTextField> {
  static const String GROUPING_SEPARATOR = ',';
  static const String DECIMAL_SEPARATOR = '.';
  static const String NEGATIVE = '-';
  static const String LEADING_ZERO_FILTER_REGEX = "^0+(?!\$)";

  TextEditingController _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  String _mDefaultText;
  String _mPreviousText = "";
  String _mNumberFilterRegex = "[^\\d\\$DECIMAL_SEPARATOR]";
  String _mWithNegativeNumberFilterRegex =
      "[^\\d\\$DECIMAL_SEPARATOR\\$NEGATIVE]";

  String _mDecimalSeparator = DECIMAL_SEPARATOR;
  bool _hasCustomDecimalSeparator = false;
  List<NumericValueWatcher> _mNumericListeners = [];

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.controller.addListener(_afterTextChanged);
    }
  }

  void _afterTextChanged() {
    final value = _effectiveController.text;
    // bool validateLock = false;

    // if (validateLock) return;

    // valid decimal number should not have more than 2 decimal separators
    if (StringUtils.countMatches(value, _mDecimalSeparator) > 1) {
      //validateLock = true;
      _effectiveController.text = _mPreviousText;
      _effectiveController.selection = TextSelection(
          baseOffset: _mPreviousText.length,
          extentOffset: _mPreviousText.length);
      //validateLock = false;
      return;
    }

    if (value.length == 0) {
      _handleNumericValueCleared();
      return;
    }

    final valueFormated = format(value);

    _setTextInternal(valueFormated);
    _handleNumericValueChanged();
  }

  void _handleNumericValueCleared() {
    _mPreviousText = "";
    for (NumericValueWatcher listener in _mNumericListeners) {
      listener.onCleared();
    }
  }

  void _handleNumericValueChanged() {
    _mPreviousText = _effectiveController.text;
    for (NumericValueWatcher listener in _mNumericListeners) {
      listener.onChanged(getNumericValue());
    }
  }

  /*
     * Set default numeric value and how it should be displayed, this value will be used if
     * {@link #clear} is called
     *
     * @param defaultNumericValue  numeric value
     * @param defaultNumericFormat display format for numeric value
     */
  void setDefaultNumericValue(
      double defaultNumericValue, final String defaultNumericFormat) {
    _mDefaultText = NumberFormat.decimalPattern(defaultNumericFormat)
        .format(defaultNumericValue);
    if (_hasCustomDecimalSeparator) {
      // swap locale decimal separator with custom one for display
      _mDefaultText =
          _mDefaultText.replaceAll(DECIMAL_SEPARATOR, _mDecimalSeparator);
    }

    _setTextInternal(_mDefaultText);
  }

  /*
  * Use specified character for decimal separator. This will disable formatting.
  * This must be called before {@link #setDefaultNumericValue} if any
  *
  * @param customDecimalSeparator decimal separator to be used
  */
  void setCustomDecimalSeparator(String customDecimalSeparator) {
    _mDecimalSeparator = customDecimalSeparator;
    _hasCustomDecimalSeparator = true;
    _mNumberFilterRegex = "[^\\d\\$_mDecimalSeparator]";
    _mWithNegativeNumberFilterRegex = "[^\\d\\$_mDecimalSeparator\\$NEGATIVE]";
  }

  /*
  * Clear text field and replace it with default value set in {@link #setDefaultNumericValue} if
  * any
  */
  void clear() {
    _setTextInternal(
        _mDefaultText != null ? _mDefaultText : widget.initialValue);
    if (_mDefaultText != null) {
      _handleNumericValueChanged();
    }
  }

  /*
  * Return numeric value represented by the text field
  *
  * @return numeric value
  */
  double getNumericValue() {
    final allowNegativeResult = widget.allowNegativeResult;

    var original = _effectiveController.text.replaceAll(
        RegExp(allowNegativeResult
            ? _mWithNegativeNumberFilterRegex
            : _mNumberFilterRegex),
        '');

    if (_hasCustomDecimalSeparator) {
      // swap custom decimal separator with locale one to allow parsing
      original = original.replaceAll(_mDecimalSeparator, DECIMAL_SEPARATOR);
    }

    try {
      return NumberFormat.decimalPattern().parse(original).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /*
  * Add grouping separators to string
  *
  * @param original original string, may already contains incorrect grouping separators
  * @return string with correct grouping separators
  */
  String format(final String original) {
    final List parts = original.split("$_mDecimalSeparator");

    final allowNegativeResult = widget.allowNegativeResult;

    String number = parts[0]
            .replaceAll(
                RegExp(allowNegativeResult
                    ? _mWithNegativeNumberFilterRegex
                    : _mNumberFilterRegex),
                '')
            .replaceFirst(RegExp(LEADING_ZERO_FILTER_REGEX), '') ??
        '';

    // only add grouping separators for non custom decimal separator
    if (!_hasCustomDecimalSeparator) {
      // remove all separators
      number = number.replaceAll(GROUPING_SEPARATOR, '');

      // add againt grouping separators, need to reverse back and forth since Java regex does not support
      number = StringUtils.reverse(
            StringUtils.reverse(number)?.replaceAllMapped(
              RegExp('(.{3})'),
              (m) => '${m[1]}$GROUPING_SEPARATOR',
            ),
          ) ??
          '';

      number = StringUtils.removeStart(number, GROUPING_SEPARATOR);
    }

    // add fraction part if any
    if (parts.length > 1) {
      if (parts[1].length > 2) {
        number += _mDecimalSeparator +
            parts[1].substring(parts[1].length - 2, parts[1].length);
      } else {
        number += _mDecimalSeparator + parts[1];
      }
    }

    return number;
  }

  /*
  * Change display text without triggering numeric value changed
  *
  * @param text new text to apply
  */
  void _setTextInternal(String text) {
    _effectiveController.removeListener(_afterTextChanged);
    _effectiveController.text = text;
    _effectiveController.addListener(_afterTextChanged);
  }

  /*
  * Add listener for numeric value changed events
  *
  * @param watcher listener to add
  */
  void addNumericValueChangedListener(NumericValueWatcher watcher) {
    _mNumericListeners.add(watcher);
  }

  /*
  * Remove all listeners to numeric value changed events
  */
  void removeAllNumericValueChangedListeners() {
    while (_mNumericListeners.isNotEmpty) {
      _mNumericListeners.remove(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        textAlign: widget.textAlign ?? TextAlign.start,
        decoration: widget.decoration,
        style: widget.style,
        readOnly: widget.readOnly,
        controller: _effectiveController,
        onTap: widget.onTap as void Function(),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onEditingComplete: widget.onEditingComplete,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}

//Interface to notify listeners when numeric value has been changed or cleared
abstract class NumericValueWatcher {
  /*
  * Fired when numeric value has been changed
  *
  * @param newValue new numeric value
  */
  void onChanged(double newValue);

  /*
  * Fired when numeric value has been cleared (text field is empty)
  */
  void onCleared();
}
