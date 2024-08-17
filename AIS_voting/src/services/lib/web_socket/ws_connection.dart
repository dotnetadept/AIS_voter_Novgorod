import 'dart:io' show WebSocket;

class WSConnection {
  late final String id;
  late String type;
  late String? terminalId;
  late String? version;
  int? deputyId;
  late bool isUseAuthcard = false;
  late bool isWindowsClient = false;
  late final WebSocket socket;
  late DateTime disconnectedTime = DateTime.now();

  WSConnection(
      {required this.id,
      required this.type,
      required this.terminalId,
      required this.version,
      required this.socket});
}
