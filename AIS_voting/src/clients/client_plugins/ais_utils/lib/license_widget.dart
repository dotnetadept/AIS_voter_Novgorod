import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';

import 'license_manager.dart';

class LicenseWidget extends StatefulWidget {
  final Settings settings;
  final ServerState serverState;

  final void Function() navigateLicenseTab;

  LicenseWidget({
    Key? key,
    required this.settings,
    required this.serverState,
    required this.navigateLicenseTab,
  }) : super(key: key);

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
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
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
      cardCount +=
          widget.serverState.formattedDevicesOnline['Количество карт'] ?? 0;
    }

    var terminalsCount = 0;

    if (widget.serverState?.formattedDevicesOnline != null) {
      terminalsCount +=
          widget.serverState.formattedDevicesOnline['Windows клиенты'] ?? 0;
    }

    var text = 'Количество карт: $cardCount';
    //text += '\t\tWindows клиенты: $terminalsCount';

    return Container(
      child: Text(text),
    );
  }
}
