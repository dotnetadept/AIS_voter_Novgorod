import 'package:ais_model/ais_model.dart';
import 'package:flutter/material.dart';

class LicenseManager {
  final Settings _settings;
  LicenseManager(this._settings);

  bool getIsLicensed(ServerState state) {
    var result = false;

    if (state == null) {
      return result;
    }
    if (Settings()
            .licenseSettings
            .licenseKeyRegex
            .stringMatch(_settings.licenseSettings.licenseKey) ==
        _settings.licenseSettings.licenseKey) {
      var keyParts = _settings.licenseSettings.licenseKey.split('-');
      var isLisenceActive = true;

      int i = 0;
      for (String keyPart in keyParts) {
        var subKeyPart1 = int.tryParse(keyPart.substring(1, 3));
        var subKeyPart2 = int.tryParse(keyPart.substring(3, 5));

        var currentValue = 0;
        switch (i) {
          case 0:
            {
              currentValue = state.formattedDevicesOnline['Операторские места'];
            }
            break;
          case 1:
            {
              currentValue =
                  state.formattedDevicesOnline['Председательские места'];
            }
            break;
          case 2:
            {
              currentValue = state.formattedDevicesOnline['Депутатские места'];
            }
            break;
          case 3:
            {
              currentValue = state.formattedDevicesOnline['Гости'];
            }
            break;
          case 4:
            {
              currentValue = state.formattedDevicesOnline['Табло'];
            }
            break;
        }

        var licenceValue =
            subKeyPart2 - subKeyPart1 > 0 ? subKeyPart2 - subKeyPart1 : 0;

        if (currentValue > licenceValue) {
          isLisenceActive = false;
          break;
        }

        i++;
      }

      result = isLisenceActive;
    }

    return result;
  }

  Widget getLicenseInfo(ServerState state) {
    if (_settings.licenseSettings.licenseKey == null ||
        _settings.licenseSettings.licenseKey.isEmpty ||
        state == null) {
      return Container();
    }

    var licenseInfo = <Widget>[];

    if (Settings()
            .licenseSettings
            .licenseKeyRegex
            .stringMatch(_settings.licenseSettings.licenseKey) ==
        _settings.licenseSettings.licenseKey) {
      var keyParts = _settings.licenseSettings.licenseKey.split('-');

      var isLisenceActive = true;
      int i = 0;

      licenseInfo.add(getLicenseItem('Серверная часть:', 1, 1));

      for (String keyPart in keyParts) {
        var subKeyPart1 = int.tryParse(keyPart.substring(1, 3));
        var subKeyPart2 = int.tryParse(keyPart.substring(3, 5));

        var licenceValue =
            subKeyPart2 - subKeyPart1 > 0 ? subKeyPart2 - subKeyPart1 : 0;

        var currentValue = 0;
        switch (i) {
          case 0:
            {
              currentValue = state.formattedDevicesOnline['Операторские места'];
              licenseInfo.add(getLicenseItem(
                  'Рабочее место оператора (секретаря) заседания:',
                  licenceValue,
                  currentValue));
            }
            break;
          case 1:
            {
              currentValue =
                  state.formattedDevicesOnline['Председательские места'];
              licenseInfo.add(getLicenseItem(
                  'Рабочее место Председателя заседания:',
                  licenceValue,
                  currentValue));
            }
            break;
          case 2:
            {
              currentValue = state.formattedDevicesOnline['Депутатские места'];
              licenseInfo.add(getLicenseItem(
                  'Рабочее место участника заседания (депутата):',
                  licenceValue,
                  currentValue));
            }
            break;
          case 3:
            {
              currentValue = state.formattedDevicesOnline['Гости'];
              licenseInfo.add(getLicenseItem(
                  'Рабочее место гостя (без функционала голосования):',
                  licenceValue,
                  currentValue));
            }
            break;
          case 4:
            {
              currentValue = state.formattedDevicesOnline['Табло'];
              licenseInfo.add(getLicenseItem(
                  'Модуль отображения информации (табло):',
                  licenceValue,
                  currentValue));
            }
            break;
        }

        if (licenceValue < currentValue) {
          isLisenceActive = false;
        }

        i++;
      }

      if (isLisenceActive) {
        licenseInfo.add(
          Row(
            children: [
              Container(
                width: 510,
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(10),
                child: Text(
                  'Лицензия активна',
                  style: TextStyle(color: Colors.green, fontSize: 22),
                ),
              ),
            ],
          ),
        );
      } else {
        licenseInfo.add(Row(
          children: [
            Container(
              width: 510,
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(10),
              child: Text(
                'Лицензия не активна',
                style: TextStyle(color: Colors.red, fontSize: 22),
              ),
            ),
          ],
        ));
      }

      return Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: licenseInfo,
        ),
      );
    }

    return Container();
  }

  Widget getLicenseItem(String name, int licenseValue, int currentValue) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Row(
        children: [
          Container(
            width: 600,
            alignment: Alignment.centerRight,
            child: Text('$name', style: TextStyle(fontSize: 18)),
          ),
          Container(
            width: 50,
            child: Text(' $licenseValue', style: TextStyle(fontSize: 18)),
          ),
          Container(
            width: 200,
            child: Text(
              'используется: $currentValue',
              style: TextStyle(
                  fontSize: 18,
                  color:
                      currentValue > licenseValue ? Colors.red : Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
