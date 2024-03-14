// sends messages to external systems
import 'dart:convert';
import 'dart:io';

import '../settings.dart';

class ExternalClient {
  Map<String, dynamic> _commands = <String, String>{};
  final Stack<String> _stack = Stack<String>();

  ExternalClient() {
    init();
  }

  Future<void> init() async {
    // load command list
    var jsonString =
        await File(EXTERNAL_RESOURCES_FOLDER + 'table.json').readAsString();
    _commands = JsonDecoder().convert(jsonString);

    // init console output
    await Process.run('bash', [EXTERNAL_RESOURCES_FOLDER + 'init.sh'],
            runInShell: true)
        .then((ProcessResult rs) {
      if (rs.stderr.toString().isNotEmpty) {
        print('bash ${EXTERNAL_RESOURCES_FOLDER}init.sh:\r\n' + rs.stderr);
      }
      push('default');
    });
  }

  void push(String terminalId) {
    _stack.push(terminalId);

    peekToExternal();
  }

  void remove(String terminalId) {
    _stack.remove(terminalId);

    peekToExternal();
  }

  Future<void> peekToExternal() async {
    var terminalId = _stack.peek;

    await Process.run('bash',
            [EXTERNAL_RESOURCES_FOLDER + 'send.sh', '${_commands[terminalId]}'],
            runInShell: true)
        .then((ProcessResult rs) {
      if (rs.stderr.toString().isNotEmpty) {
        print('bash ${EXTERNAL_RESOURCES_FOLDER}send.sh:\r\n' + rs.stderr);
      }
    });
  }
}

class Stack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);
  void remove(E value) => _list.remove(value);

  int get length => _list.length;

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();
}
