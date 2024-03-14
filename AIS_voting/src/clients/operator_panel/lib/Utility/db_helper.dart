import 'dart:convert';
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/server_connection.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

class DbHelper {
  static void saveSettings(Settings settings) {
    http.put(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/settings/${settings.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(settings.toJson()));
  }
}
