import 'package:services/services.dart';

Future main() async {
  // start http web server
  final app = Application<ServicesChannel>()
    ..options.configurationFilePath = 'config.yaml'
    ..options.port = HTTP_SERVER_PORT;

  //https certificate options
  //..options.certificateFilePath = '/home/vladimir/Desktop/ssl/example.crt'
  //..options.privateKeyFilePath = '/home/vladimir/Desktop/ssl/example.key';

  print('Запуск $APP_NAME'); //v1.33

  await app.start(); //numberOfInstances: 3

  print('Ip адресс: $ADDRESS');
  print('HTTP порт: $HTTP_SERVER_PORT');
  print('WebSocket порт: $WEB_SOCKET_PORT');
  print('$APP_NAME запущен.'); //v1.33

  print('Используйте Ctrl-C (SIGINT) для останова запущенного приложения.');
}
