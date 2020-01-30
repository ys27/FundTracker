import 'package:flutter/material.dart';

class BarTile extends StatefulWidget {
  final String title;
  final double amount;
  final double percentage;
  final Color color;

  BarTile({this.title, this.amount, this.percentage, this.color});

  @override
  _BarTileState createState() => _BarTileState();
}

class _BarTileState extends State<BarTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(widget.title),
            Text('\$${widget.amount.toStringAsFixed(2)}'),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              height: 25.0,
              width:
                  widget.percentage * (MediaQuery.of(context).size.width - 20),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: new BorderRadius.all(Radius.circular(5.0)),
              ),
            ),
            Container(
              height: 25.0,
              width: (1 - widget.percentage) *
                  (MediaQuery.of(context).size.width - 20),
            ),
          ],
        ),
      ],
    );
  }
}
