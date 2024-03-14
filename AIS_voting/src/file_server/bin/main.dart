import 'package:ais_file_server/ais_file_server.dart';

Future main() async {
  // start http web server
  final app = Application<ServicesChannel>()
    ..options.configurationFilePath = 'config.yaml'
    ..options.port = HTTP_SERVER_PORT;

  print('Запуск $APP_NAME v1.927');

  await app.start(); //numberOfInstances: 3

  print('Ip адресс: $ADDRESS');
  print('HTTP порт: $HTTP_SERVER_PORT');
  print('$APP_NAME v1.927 запущен.');

  print('Используйте Ctrl-C (SIGINT) для останова запущенного приложения.');
}
