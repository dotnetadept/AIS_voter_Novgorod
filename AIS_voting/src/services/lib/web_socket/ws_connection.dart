import 'dart:io' show WebSocket;

class WSConnection {
  final String id;
  String type;
  String terminalId;
  String version;
  int deputyId;
  bool isUseAuthcard;
  bool isWindowsClient;
  final WebSocket socket;
  DateTime disconnectedTime;

  WSConnection(
      {this.id,
      this.type,
      this.terminalId,
      this.deputyId,
      this.version,
      this.socket});
}
