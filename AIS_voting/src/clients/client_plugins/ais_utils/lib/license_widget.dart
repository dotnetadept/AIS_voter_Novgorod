import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';

import 'license_manager.dart';

class LicenseWidget extends StatefulWidget {
  final Settings settings;
  final ServerState serverState;

  final void Function() navigateLicenseTab;

  LicenseWidget(
      {Key key, this.settings, this.serverState, this.navigateLicenseTab})
      : super(key: key);

  @override
  _LicenseWidgetState createState() => _LicenseWidgetState();
}

class _LicenseWidgetState extends State<LicenseWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.serverState == null) {
      return Container();
    }
    if (!LicenseManager(widget.settings).getIsLicensed(widget.serverState)) {
      return Container(
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: Text(
            'Нет лицензии',
            style: TextStyle(
                color: Colors.redAccent[700],
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          onPressed: () {
            if (widget.navigateLicenseTab != null) {
              widget.navigateLicenseTab();
            }
          },
        ),
      );
    }

    var cardCount = 0;

    if (widget.serverState?.formattedDevicesOnline != null) {
      if (widget.serverState.formattedDevicesOnline['Количество карт'] !=
          null) {
        cardCount +=
            widget.serverState.formattedDevicesOnline['Количество карт'];
      }
    }

    var terminalsCount = 0;

    if (widget.serverState?.formattedDevicesOnline != null) {
      if (widget.serverState.formattedDevicesOnline['Windows клиенты'] !=
          null) {
        terminalsCount +=
            widget.serverState.formattedDevicesOnline['Windows клиенты'];
      }
    }

    var text = 'Количество карт: $cardCount';
    //text += '\t\tWindows клиенты: $terminalsCount';

    return Container(
      child: Text(text),
    );
  }
}
