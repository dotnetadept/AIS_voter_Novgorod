import 'package:flutter/material.dart';

class TableHelper {
  Widget getTitleItemWidget(String label, int? relativeWidth,
      {aligment = Alignment.centerLeft}) {
    if (relativeWidth == null) {
      return Container(
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        height: 56,
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: aligment,
      );
    }

    return Expanded(
      flex: relativeWidth,
      child: Container(
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        height: 56,
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: aligment,
      ),
    );
  }

  Widget generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      width: 0,
      height: 0,
    );
  }
}
