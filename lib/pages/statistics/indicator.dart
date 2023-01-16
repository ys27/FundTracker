import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final bool isSquare;
  final double size;
  final Color textColor;
  final Function handleTap;

  const Indicator({
    Key key,
    this.color,
    this.title,
    this.subtitle,
    this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
    this.handleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          )
        ],
      ),
      onTap: handleTap,
    );
  }
}
