// vissonic command utils
class VissonicCommandHelper {
  static String commandToString(int command) {
    if (command == 0x00e) {
      return 'Keep alive';
    }

    if (command == 0x1e0) {
      return 'Интерпретатор включен';
    }
    if (command == 0x1f0) {
      return 'Интерпретатор отключен';
    }

    if (command == 0x110) {
      return 'Микрофон включен';
    }
    if (command == 0x111) {
      return 'Микрофон отключен';
    }

    if (command == 0x112) {
      return 'Микрофон ожидает';
    }
    if (command == 0x113) {
      return 'Микрофон завершил ожидание';
    }

    if (command == 0x119) {
      return 'Председатель ожидает подтверждения комманды';
    }

    if (command == 0x11a) {
      return 'Председатель завершил ожидание подтверждения комманды';
    }

    if (command == 0x11b) {
      return 'Председатель выключил ВСЕ активные микрофоны';
    }

    if (command == 0x0c0) {
      return 'Модуль в режиме ожидания';
    }
    if (command == 0x0c1) {
      return 'Модуль подключен';
    }
    if (command == 0x0c2) {
      return 'Функция микрофона отключена';
    }
    if (command == 0x0c3) {
      return 'Функция микрофона подключена';
    }

    return 'Комманда не найдена';
  }

  static String idToString(int id) {
    if (id == 0xfff) {
      return 'ВСЕ';
    }

    return id.toString();
  }

  static List<String> formatData(List<int> data) {
    var result = <String>[];

    data.forEach((element) {
      result.add(element.toRadixString(16).padLeft(2, '0'));
    });

    return result;
  }
}
