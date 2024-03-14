import 'vissonic_command.dart';

class VissonicBasicCommand {
  static VissonicCommand init() {
    // 00 06 00 00 03 00 FC FC
    return VissonicCommand(
        [0x00, 0x06, 0x00, 0x00, 0x03, 0x00, 0xFC, 0xFC], []);
  }

  static VissonicCommand keepAlive() {
    // 00 06 00 00 0E 00 FC FC
    return VissonicCommand([0x00, 0x06, 0x00, 0x00, 0x0E, 0x00, 0xFC, 0xFC],
        [0xFE, 0x00, 0x0E, 0x00, 0xFC]);
  }

  static VissonicCommand setMicEnabled(String terminalId, bool isEnabled) {
    // convert dec terminal id to hex terminalId
    if (terminalId != 'fff') {
      terminalId = int.parse(terminalId).toRadixString(16).padLeft(3, '0');
    }

    var terminalCommand = 0;

    if (!isEnabled) {
      terminalCommand = 2;
    } else {
      terminalCommand = 3;
    }

    var terminalIdFirstPart = int.parse(
        terminalId[0].padRight(2, terminalCommand.toString()),
        radix: 16);
    var terminalIdSecondPart =
        int.parse(terminalId[1] + terminalId[2], radix: 16);

    return VissonicCommand([
      0x00,
      0x06,
      0x00,
      0x0C,
      terminalIdFirstPart,
      terminalIdSecondPart,
      0xFC,
      0xFC
    ], [
      0xFE,
      0x0C,
      terminalIdFirstPart,
      terminalIdSecondPart,
      0xFC,
    ]);
  }

  static VissonicCommand setMicSound(String terminalId, bool isMicrophoneOn) {
    // convert dec terminal id to hex terminalId
    if (terminalId != 'fff') {
      terminalId = int.parse(terminalId).toRadixString(16).padLeft(3, '0');
    }

    var terminalCommand = 0;

    if (isMicrophoneOn) {
      terminalCommand = 0;
    } else {
      terminalCommand = 1;
    }

    var terminalIdFirstPart = int.parse(
        terminalId[0].padRight(2, terminalCommand.toString()),
        radix: 16);
    var terminalIdSecondPart =
        int.parse(terminalId[1] + terminalId[2], radix: 16);

    return VissonicCommand([
      0x00,
      0x06,
      0x00,
      0x11,
      terminalIdFirstPart,
      terminalIdSecondPart,
      0xFC,
      0xFC
    ], [
      0xFE,
      0x11,
      terminalIdFirstPart,
      terminalIdSecondPart,
      0xFC,
    ]);
  }
}
