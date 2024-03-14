import 'package:services/services.dart';
import 'package:yaml/yaml.dart';

Future main() async {
  final app = Application<ServicesChannel>()
    ..options.configurationFilePath = 'config.yaml'
    ..options.port = HTTP_SERVER_PORT;

  var file = File('pubspec.yaml');
  var data = await file.readAsString();
  Map yaml = loadYaml(data);

  print('Запуск $APP_NAME ${yaml['version']}');

  await app.start();

  print('Ip адресс: $ADDRESS');
  print('HTTP порт: $HTTP_SERVER_PORT');
  print('WebSocket порт: $WEB_SOCKET_PORT');
  print('$APP_NAME ${yaml['version']} запущен.');

  print('Используйте Ctrl-C (SIGINT) для останова запущенного приложения.');
}
