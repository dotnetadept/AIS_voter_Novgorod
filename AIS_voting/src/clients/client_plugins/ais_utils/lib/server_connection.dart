import 'package:global_configuration/global_configuration.dart';
import 'package:ais_model/ais_model.dart';

class ServerConnection {
  static String getHttpServerUrl(GlobalConfiguration settings) {
    var server = settings.getValue('server');
    var port = settings.getValue('http_port');
    return '$server:$port';
  }

  static String getWebSocketServerUrl(GlobalConfiguration settings) {
    var server = settings.getValue('server');
    var port = settings.getValue('ws_port');
    return 'ws://$server:$port';
  }

  static String getFileServerUploadUrl(Settings settings) {
    return 'http://${settings.fileSettings.ip}:${settings.fileSettings.port}/${settings.fileSettings.uploadPath}';
  }

  static String getFileServerDownloadUrl(Settings settings) {
    return 'http://${settings.fileSettings.ip}:${settings.fileSettings.port}/${settings.fileSettings.downloadPath}';
  }
}
