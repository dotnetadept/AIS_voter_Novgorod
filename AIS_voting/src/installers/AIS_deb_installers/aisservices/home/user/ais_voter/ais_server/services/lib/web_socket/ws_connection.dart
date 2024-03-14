import 'dart:io' show WebSocket;

class WSConnection {
  final String id;
  String type;
  String terminalId;
  int deputyId;
  bool isUseAuthcard;
  bool isWindowsClient;
  final WebSocket socket;

  WSConnection(
      {this.id, this.type, this.terminalId, this.deputyId, this.socket});
}
