import 'package:ais_model/ais_model.dart';
import 'package:flutter/material.dart';

class ModelWidgets {
  Widget getSignalWidget(Signal? signal) {
    if (signal == null) {
      return Container();
    }

    var widgets = <Widget>[];

    if (signal.color != Colors.transparent.value && signal.duration != 0) {
      widgets.add(Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: Color(signal.color),
          border: Border.all(
            color: Colors.black54,
            width: 1,
          ),
        ),
      ));
      widgets.add(Container(
        width: 5,
      ));
      widgets.add(Text(
        signal.duration.toString() + 'c. ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
    } else {
      widgets.add(
        Tooltip(
          message: 'Цветовой сигнал отсутвует',
          child: Icon(Icons.stop_screen_share),
        ),
      );
    }

    if (signal.soundPath != null && signal.soundPath.isNotEmpty) {
      widgets.add(
        Tooltip(
          message: signal.soundPath,
          child: Icon(Icons.volume_up),
        ),
      );
    } else {
      widgets.add(
        Tooltip(
          message: 'Звуковой сигнал отсутвует',
          child: Icon(Icons.volume_off),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              signal.name,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: widgets,
        ),
      ],
    );
  }
}
