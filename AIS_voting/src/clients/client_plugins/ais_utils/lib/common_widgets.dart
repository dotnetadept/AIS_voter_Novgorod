import 'package:flutter/material.dart';

class CommonWidgets {
  Widget getLoadingStub() {
    return Column(
      children: [
        Expanded(child: Container()),
        Row(
          children: [
            Expanded(child: Container()),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: Text(
                'Загрузка',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Container(
              child: CircularProgressIndicator(),
            ),
            Expanded(child: Container()),
          ],
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
