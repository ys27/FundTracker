import 'package:flutter/material.dart';

class BarTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final double percentage;
  final Color color;

  BarTile({
    this.title,
    this.subtitle,
    this.amount,
    this.percentage,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('\$${amount.toStringAsFixed(2)}'),
          ],
        ),
        subtitle != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(subtitle),
                ],
              )
            : Container(),
        percentage != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 25.0,
                    width:
                        percentage * (MediaQuery.of(context).size.width - 20),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: new BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }
}
