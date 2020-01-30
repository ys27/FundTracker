import 'package:flutter/material.dart';

class BarTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String midLine;
  final double amount;
  final double percentage;
  final Color color;

  BarTile({
    this.title,
    this.subtitle,
    this.midLine,
    this.amount,
    this.percentage,
    this.color,
  });

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
            widget.midLine != null
                ? Text(
                    widget.midLine,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                : Container(),
            Text('\$${widget.amount.toStringAsFixed(2)}'),
          ],
        ),
        widget.subtitle != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(widget.subtitle),
                ],
              )
            : Container(),
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
