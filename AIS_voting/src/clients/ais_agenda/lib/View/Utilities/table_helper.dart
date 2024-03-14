import 'package:flutter/material.dart';

class TableHelper {
  Widget getTitleItemWidget(String label, int relativeWidth,
      {aligment = Alignment.centerLeft}) {
    return Expanded(
      flex: relativeWidth,
      child: Container(
        height: 56,
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: aligment,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget generateFirstColumnRow(BuildContext context, int index) {
    return const SizedBox(
      width: 0,
      height: 0,
    );
  }
}
