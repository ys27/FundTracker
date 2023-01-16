import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import 'numeric_text_field.dart';
import 'themes.dart';

class CalculatorOperator {
  static const none = 'none';
  static const sum = '+';
  static const subtraction = '-';
  static const multiplication = 'x';
  static const division = '/';
  static const clear = 'C';
  static const del = 'DEL';
  static const plusMinus = '±';
  static const equal = '=';
  static const submit = "DONE";

  static const main = [
    clear,
    del,
    equal,
  ];

  static const all = [
    sum,
    subtraction,
    multiplication,
    division,
    clear,
    del,
    plusMinus,
    equal,
  ];
}

const List<List<String>> _keyRows = [
  const [
    '00',
    '0',
    '.',
    '=',
  ],
  const [
    '1',
    '2',
    '3',
    '+',
  ],
  const [
    '4',
    '5',
    '6',
    '-',
  ],
  const [
    '7',
    '8',
    '9',
    'x',
  ],
  const [
    'C',
    'DEL',
    '±',
    '/',
  ],
];

class InputCalculatorArgs {
  final String title;
  final double initialValue;
  final BoxDecoration boxDecoration;
  final Color appBarBackgroundColor;
  final Color operatorButtonColor;
  final Color normalButtonColor;
  final Color operatorTextButtonColor;
  final Color normalTextButtonColor;
  final Color doneButtonColor;
  final Color doneTextButtonColor;
  final bool allowNegativeResult;
  final bool menuAtTop;
  final CalculatorThemes theme;

  InputCalculatorArgs({
    this.title,
    this.initialValue,
    this.boxDecoration,
    this.appBarBackgroundColor,
    this.operatorButtonColor,
    this.normalButtonColor,
    this.operatorTextButtonColor,
    this.normalTextButtonColor,
    this.doneButtonColor,
    this.doneTextButtonColor,
    this.allowNegativeResult = true,
    this.menuAtTop = false,
    this.theme = CalculatorThemes.curve,
  });
}

class Calculator extends StatefulWidget {
  static const id = 'input_calculator';

  final InputCalculatorArgs args;

  Calculator({this.args});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  static const ZERO = '0';
  static const ZERO_ZERO = '00';
  static const POINT = '.';

  final TextEditingController _inputNumberController = TextEditingController();

  String _equalTitleBtn = CalculatorOperator.submit;

  get equalTitleBtn => _equalTitleBtn;
  set equalTitleBtn(value) {
    setState(() {
      _equalTitleBtn = value;
    });
  }

  String _developmentOperationText = '';

  bool _clickArithmeticOperator = false;
  bool _clearInput = false;

  double _firstValue;
  double _secondValue;

  String _operatorExecute = CalculatorOperator.none;
  String _prevOperatorExecute = CalculatorOperator.none;

  bool _wasLastAOperator = false;
  bool _isEqualOrSubmit = false;

  @override
  void initState() {
    super.initState();

    final double initialValue = widget.args?.initialValue ?? 0.0;
    final parts = '$initialValue'.split(POINT);

    if (parts.length > 1 && parts[1] == '0') {
      _inputNumberController.text =
          NumberFormat.decimalPattern().format(double.parse(parts[0]));
    } else {
      _inputNumberController.text = NumberFormat("###.00").format(initialValue);
    }
  }

  @override
  void dispose() {
    _inputNumberController.dispose();
    super.dispose();
  }

  // listeners
  void _numberBtnOnPressed(value) {
    _isEqualOrSubmit = false;

    _concatNumeric(value);
    _clickArithmeticOperator = false;
    _wasLastAOperator = false;
  }

  void _operatorBtnOnPressed(value) {
    _isEqualOrSubmit = false;

    switch (value) {
      case CalculatorOperator.sum:
      case CalculatorOperator.subtraction:
      case CalculatorOperator.multiplication:
      case CalculatorOperator.division:
        if (_inputNumberController.text.isEmpty ||
            _inputNumberController.text == POINT) return;

        equalTitleBtn = CalculatorOperator.equal;
        _operatorExecute = value;
        _wasLastAOperator = true;

        if (!_clickArithmeticOperator) {
          _clickArithmeticOperator = true;
          _prepareOperation(false);
        } else {
          _replaceOperator(value);
        }
        break;
      case CalculatorOperator.clear:
        _clear();
        break;

      case CalculatorOperator.del:
        _removeLastNumber();
        break;

      case CalculatorOperator.plusMinus:
        _invertNumber();
        break;

      case CalculatorOperator.equal:
      case CalculatorOperator.submit:
        _isEqualOrSubmit = true;

        if (_inputNumberController.text == POINT) {
          String temp = _developmentOperationText;
          _clear();
          _inputNumberController.text = temp;
          break;
        }

        if (_operatorExecute == CalculatorOperator.submit ||
            _firstValue == null) {
          _returnResultOperation();
        } else {
          _prepareOperation(true);
          _clearInput = false;
          _clickArithmeticOperator = false;
          _operatorExecute = CalculatorOperator.submit;
          _prevOperatorExecute = CalculatorOperator.none;
          _firstValue = null;
          _secondValue = null;
        }
        break;
    }
  }

  // operation functions
  void _prepareOperation(bool isEqualExecute) {
    _clearInput = true;

    if (isEqualExecute) {
      equalTitleBtn = CalculatorOperator.submit;
      _developmentOperationText = '';
    } else {
      _concatDevelopingOperation(
        _operatorExecute,
        _inputNumberController.text,
        false,
      );
    }

    if (_firstValue == null) {
      _firstValue = double.parse(
        _inputNumberController.text.replaceAll(',', ''),
      );
    } else if (_secondValue == null) {
      _secondValue = double.parse(
        _inputNumberController.text.replaceAll(',', ''),
      );

      if ((_wasLastAOperator && !_isEqualOrSubmit) ||
          (!_wasLastAOperator && _isEqualOrSubmit))
        _executeOperation(_prevOperatorExecute);
    }

    _prevOperatorExecute = _operatorExecute;
  }

  void _concatDevelopingOperation(
      String calculatorOperator, String value, bool clear) {
    bool noValidCharacter = calculatorOperator == CalculatorOperator.clear ||
        calculatorOperator == CalculatorOperator.del ||
        calculatorOperator == CalculatorOperator.equal;

    if (!noValidCharacter) {
      String oldValue = clear ? '' : _developmentOperationText;
      _developmentOperationText = '$oldValue $value $calculatorOperator';
    }
  }

  void _executeOperation(String calculatorOperator) {
    if (_firstValue == null || _secondValue == null) return;

    double resultOperation = 0.0;

    switch (calculatorOperator) {
      case CalculatorOperator.sum:
        resultOperation = _firstValue + _secondValue;
        break;

      case CalculatorOperator.subtraction:
        resultOperation = _firstValue - _secondValue;
        break;

      case CalculatorOperator.multiplication:
        resultOperation = _firstValue * _secondValue;
        break;

      case CalculatorOperator.division:
        if (_secondValue > 0) resultOperation = _firstValue / _secondValue;
        break;
    }

    _inputNumberController.text = _formatValue(resultOperation);
    _firstValue = resultOperation;

    _secondValue = null;
  }

  void _concatNumeric(String value) {
    if (value.isEmpty) return;

    String oldValue = _inputNumberController.text;
    String newValue = _clearInput || (oldValue == ZERO && value != POINT)
        ? value
        : oldValue + value;

    newValue = (oldValue == ZERO && value == ZERO_ZERO) ? oldValue : newValue;

    _inputNumberController.text = newValue;
    _clearInput = false;
  }

  void _returnResultOperation() {
    final value = _inputNumberController.text;
    final parts = value.split(POINT);

    String result = parts.length > 1 && parts[1] == '' ? parts[0] : value;

    Navigator.of(context)
        .pop(double.parse(result == '' ? '0' : result.replaceAll(',', '')));
  }

  void _replaceOperator(String calculatorOperator) {
    String operationValue = _developmentOperationText;

    if (operationValue.isEmpty) return;

    String oldOperator = operationValue.substring(
        operationValue.length - 1, operationValue.length);

    if (oldOperator == calculatorOperator) return;

    String operationNewValue =
        operationValue.substring(0, operationValue.length - 2);

    _concatDevelopingOperation(calculatorOperator, operationNewValue, true);
  }

  String _formatValue(double value) {
    String valueStr = NumberFormat.simpleCurrency(name: '').format(value);

    String integerValue = valueStr.substring(0, valueStr.indexOf(POINT));
    String decimalValue =
        valueStr.substring(valueStr.indexOf(POINT) + 1, valueStr.length);

    if (decimalValue == ZERO_ZERO || decimalValue == ZERO) return integerValue;

    return valueStr;
  }

  void _removeLastNumber() {
    String value = _inputNumberController.text;

    if (value.length != 0)
      _inputNumberController.text = value.substring(0, value.length - 1);
  }

  void _invertNumber() {
    final value = double.parse(_inputNumberController.text);

    if (value == 0) return;

    final parts = '$value'.split(POINT);

    if (parts.length > 1 && parts[1] == '0') {
      final value = double.parse(parts[0]);

      _inputNumberController.text = NumberFormat("###").format(value * -1);
    } else {
      _inputNumberController.text = NumberFormat("###.00").format(value * -1);
    }
  }

  void _clear() {
    equalTitleBtn = CalculatorOperator.submit;

    _firstValue = null;
    _secondValue = null;
    _operatorExecute = CalculatorOperator.none;
    _prevOperatorExecute = CalculatorOperator.none;

    _developmentOperationText = '';
    _inputNumberController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final inputContainerHeight = MediaQuery.of(context).size.height / 3;
    final keyboardTopOverlad =
        (inputContainerHeight - (MediaQuery.of(context).size.height / 4) + 16);
    final isFlatTheme = widget.args.theme == CalculatorThemes.flat;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(widget.args?.initialValue ?? 0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args?.title ?? ''),
          backgroundColor: widget.args?.appBarBackgroundColor,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: inputContainerHeight,
                color: Colors.white,
                padding: EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: 72.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      _developmentOperationText,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    NumericTextField(
                      controller: _inputNumberController,
                      textAlign: TextAlign.end,
                      readOnly: true,
                      allowNegativeResult: widget.args.allowNegativeResult,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                      ),
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: inputContainerHeight - keyboardTopOverlad,
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                decoration: widget.args.theme.panelButtonDecoration,
                padding: EdgeInsets.all(isFlatTheme ? 0.0 : 8.0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildKeyRows(context, isFlatTheme),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKeyRows(BuildContext context, bool isFlatTheme) {
    List<Widget> keyRows = [];
    //final screenHeight = MediaQuery.of(context).size.height;

    var padding = EdgeInsets.all(isFlatTheme ? 0.0 : 4.0);

    // if (screenHeight <= 550) {
    //   padding = EdgeInsets.all(1.0);
    // } else if (screenHeight > 550 && 600 >= screenHeight) {
    //   padding = EdgeInsets.all(4.0);
    // }

    _keyRows.reversed.forEach(
      (keyRow) => keyRows.add(
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isFlatTheme
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: _buildKeyRow(context, keyRow, padding),
          ),
        ),
      ),
    );

    return keyRows;
  }

  List<Widget> _buildKeyRow(
    BuildContext context,
    List<String> row,
    EdgeInsets padding,
  ) {
    List<Widget> keyRow = [];

    row.forEach(
      (key) => keyRow.add(
        _buildButtom(
          _isEqualOperator(key) ? equalTitleBtn : key,
          circle: !_isMainOperator(key),
          titleColor: _isOperator(key)
              ? widget.args?.operatorTextButtonColor
              : widget.args?.normalTextButtonColor,
          color: _isOperator(key)
              ? widget.args?.operatorButtonColor
              : widget.args?.normalButtonColor,
          onPressed: () => _isOperator(key)
              ? _operatorBtnOnPressed(key)
              : _numberBtnOnPressed(key),
          padding: padding,
          context: context,
        ),
      ),
    );

    return keyRow;
  }

  bool _isSumitOperator(String key) => key == CalculatorOperator.submit;

  bool _isEqualOperator(String key) => key == CalculatorOperator.equal;

  bool _isMainOperator(String key) => CalculatorOperator.main.contains(key);

  bool _isOperator(String key) => CalculatorOperator.all.contains(key);

  Widget _buildButtom(
    String title, {
    bool circle = true,
    Color titleColor,
    Color color,
    EdgeInsets padding,
    Function onPressed,
    BuildContext context,
  }) {
    final isAllowNegativeResult = widget.args.allowNegativeResult;

    return Expanded(
      child: Container(
        padding: padding,
        child: _KeyboardButton(
          title: title,
          titleColor: _isSumitOperator(title)
              ? widget.args?.doneTextButtonColor
              : titleColor,
          color: _isSumitOperator(title) ? widget.args?.doneButtonColor : color,
          theme: widget.args.theme,
          onPressed:
              !isAllowNegativeResult && title == CalculatorOperator.plusMinus
                  ? null
                  : onPressed,
        ),
      ),
    );
  }
}

class _KeyboardButton extends RawMaterialButton {
  _KeyboardButton({
    String title,
    Color titleColor = Colors.grey,
    Color color = Colors.white,
    double elevation = 0.0,
    Function onPressed,
    CalculatorThemes theme,
  }) : super(
          fillColor: onPressed != null ? color : Colors.grey.shade400,
          //constraints: BoxConstraints(maxWidth: 48, maxHeight: 48),
          elevation: elevation,
          shape: theme.buttonShape,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title ?? ' ',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: onPressed != null ? titleColor : Colors.grey.shade300,
              ),
            ),
          ),
          onPressed: onPressed as void Function(),
        );
}
