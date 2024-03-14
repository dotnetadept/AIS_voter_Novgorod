import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:ais_utils/ais_utils.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:global_configuration/global_configuration.dart';
//import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => {runApp(MyApp())});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Загрузка Повестки Заседания',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        tooltipTheme: TooltipThemeData(
          textStyle: TextStyle(fontSize: 14, color: Colors.white),
        ),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          padding: MaterialStateProperty.all(EdgeInsets.all(20)),
          overlayColor: MaterialStateProperty.all(Colors.blueAccent),
        )),
        scrollbarTheme: ScrollbarThemeData(
          thickness: MaterialStateProperty.all(12),
        ),
      ),
      home: Scaffold(
        body: DownloaderForm(),
      ),
    );
  }
}

class DownloaderForm extends StatefulWidget {
  @override
  DownloaderFormState createState() {
    return DownloaderFormState();
  }
}

class DownloaderFormState extends State<DownloaderForm> {
  final _formKeySite = GlobalKey<FormState>();
  final _formKeyFolder = GlobalKey<FormState>();

  var _tecUrl =
      TextEditingController(text: GlobalConfiguration().getValue('url'));
  var _tecLogin =
      TextEditingController(text: GlobalConfiguration().getValue('login'));
  var _tecPassword =
      TextEditingController(text: GlobalConfiguration().getValue('password'));

  var _tecFolder =
      TextEditingController(text: GlobalConfiguration().getValue('lastDir'));
  var _tecDescription = TextEditingController();
  var _tecAgendaFolder = TextEditingController(
      text: '_' + DateFormat('dd.MM.yyyy').format(DateTime.now()));
  var _tecFinalFolder = TextEditingController();

  ScrollController _scrollController = ScrollController();
  List<Widget> _checkDialogItems = <Widget>[];
  List<String> _checkDialogItemsText = <String>[];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(40, 10, 0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: leftPanel(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(width: 170, height: 126, child: rightPanel()),
          ),
        ],
      ),
    );
  }

  Widget leftPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: Form(
                key: _formKeySite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: Colors.blue,
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                            child: Text(
                              'Настройки сайта',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          Expanded(child: Container()),
                          Tooltip(
                            message: 'Проверить подключение',
                            child: TextButton(
                              child: Icon(Icons.settings, color: Colors.white),
                              onPressed: () {
                                if (_formKeySite.currentState?.validate() ??
                                    false) {
                                  _checkDialogItems = <Widget>[];
                                  processCheckLogin()
                                      .then((value) => Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () => Navigator.pop(context)))
                                      .catchError((e) {
                                    Navigator.pop(context);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 75,
                                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: TextFormField(
                                  controller: _tecUrl,
                                  decoration: InputDecoration(
                                    hintText: 'Url сайта',
                                    labelText: 'Url сайта',
                                    fillColor: Colors.blueAccent,
                                    hintStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите Url сайта';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                height: 75,
                                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: TextFormField(
                                  controller: _tecLogin,
                                  decoration: InputDecoration(
                                    hintText: 'Логин',
                                    labelText: 'Логин',
                                    hintStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите логин';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                height: 75,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                                  child: TextFormField(
                                    controller: _tecPassword,
                                    decoration: InputDecoration(
                                      hintText: 'Пароль',
                                      labelText: 'Пароль',
                                      hintStyle: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Введите пароль';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKeyFolder,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: Colors.blue,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                            child: Text(
                              'Настройки загрузки',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          Expanded(child: Container()),
                          Tooltip(
                            message: 'Проверить директорию',
                            child: TextButton(
                              child: Icon(Icons.settings, color: Colors.white),
                              onPressed: () {
                                if (_formKeyFolder.currentState?.validate() ??
                                    false) {
                                  _checkDialogItems = <Widget>[];
                                  checkDirectory();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 75,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: TextFormField(
                                controller: _tecFolder,
                                decoration: InputDecoration(
                                  hintText: 'Директория для загрузки',
                                  labelText: 'Директория для загрузки',
                                  hintStyle:
                                      TextStyle(fontStyle: FontStyle.italic),
                                ),
                                onChanged: (value) {
                                  _tecFinalFolder.text =
                                      value + '/' + _tecAgendaFolder.text;
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Выберите директорию для загрузки';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async => await selectFolder(context),
                          child: Text('Выбрать папку'),
                        ),
                        Container(
                          width: 10,
                        ),
                        Tooltip(
                          message: 'Открыть папку в проводнике',
                          child: Container(
                            height: 40,
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(10)),
                              ),
                              child:
                                  Icon(Icons.folder_open, color: Colors.white),
                              onPressed: () {
                                openDirectory();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 75,
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: TextFormField(
                              controller: _tecDescription,
                              decoration: InputDecoration(
                                hintText: 'Описание',
                                labelText: 'Описание',
                                hintStyle:
                                    TextStyle(fontStyle: FontStyle.italic),
                              ),
                              onChanged: (value) {
                                _tecAgendaFolder.text = value +
                                    '_' +
                                    DateFormat('dd.MM.yyyy')
                                        .format(DateTime.now());
                                _tecFinalFolder.text = _tecFolder.text +
                                    '/' +
                                    _tecAgendaFolder.text;

                                setState(() {});
                              },
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Введите описание';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 75,
                            color: Colors.black12,
                            child: TextFormField(
                              controller: _tecAgendaFolder,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Директория повестки',
                                labelText: 'Директория повестки',
                                hintStyle:
                                    TextStyle(fontStyle: FontStyle.italic),
                              ),
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 75,
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            color: Colors.black12,
                            child: TextFormField(
                              controller: _tecFinalFolder,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Финальный путь',
                                labelText: 'Финальный путь',
                                hintStyle:
                                    TextStyle(fontStyle: FontStyle.italic),
                              ),
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Финальный путь не должен быть пустым';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Tooltip(
                          message: 'Открыть папку в проводнике',
                          child: Container(
                            height: 40,
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(10)),
                              ),
                              child:
                                  Icon(Icons.folder_open, color: Colors.white),
                              onPressed: () {
                                openFinalDirectory();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.black12,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.blue,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                            child: Text(
                              'Журнал:',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          Expanded(child: Container()),
                          Tooltip(
                            message: 'Копировать в буфер обмена',
                            child: TextButton(
                              child: Icon(Icons.copy, color: Colors.white),
                              onPressed: () {
                                copyToClipboard();
                              },
                            ),
                          ),
                          Tooltip(
                            message: 'Сохранить в файл',
                            child: TextButton(
                              child: Icon(Icons.save, color: Colors.white),
                              onPressed: () {
                                saveToFile();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 402 > 0
                            ? MediaQuery.of(context).size.height - 402
                            : 0,
                        child: Scrollbar(
                          isAlwaysShown: true,
                          controller: _scrollController,
                          child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: _checkDialogItems.length,
                            itemBuilder: (buildContext, index) {
                              return _checkDialogItems[index];
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void copyToClipboard() {
    if (_checkDialogItemsText != null && _checkDialogItemsText.length > 0) {
      Clipboard.setData(new ClipboardData(text: getJournalText()));
    }
  }

  String getJournalText() {
    var text = '';
    _checkDialogItemsText.forEach((element) {
      text += element + '\n';
    });
    return text;
  }

  Future<void> selectFolder(BuildContext context) async {
    String path = await FilesystemPicker.open(
      title: 'Выберите папку для сохранения повестки',
      context: context,
      rootDirectory: Directory('/'),
      fsType: FilesystemType.folder,
      pickText: 'Выбрать папку',
      folderIconColor: Colors.teal,
      requestPermission: () => Future<bool>.value(true),
    );

    setState(() {
      _tecFolder.text = path;
      _tecFinalFolder.text = _tecFolder.text + '/' + _tecAgendaFolder.text;
    });
  }

  void saveToFile() {
    FilePickerCross(
      Utf8Encoder().convert(getJournalText()),
      path: 'журнал_' +
          DateFormat('dd.MM.yyyy_HH:mm:ss').format(DateTime.now()) +
          '.txt',
      type: FileTypeCross.custom,
      fileExtension: 'txt',
    ).exportToStorage();
  }

  Widget rightPanel() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 120,
              child: TextButton(
                onPressed: () {
                  if ((_formKeySite.currentState?.validate() ?? false) &&
                      (_formKeyFolder.currentState?.validate() ?? false)) {
                    _checkDialogItems = <Widget>[];
                    loadData()
                        .then((value) => Navigator.pop(context))
                        .catchError((e) => Navigator.pop(context));
                  }
                },
                child: Column(
                  children: [
                    Icon(Icons.file_download),
                    Text(
                      'Загрузить',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget getCheckDialogItem(String text, bool isOk) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text:
                DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now()) + '\t',
          ),
          TextSpan(
            text: text + '\t',
          ),
          WidgetSpan(
            child: Icon(
              isOk ? Icons.done : Icons.close,
              color: isOk ? Colors.green : Colors.red,
            ),
          ),
          TextSpan(
            text: '\n',
          ),
        ],
      ),
    );
  }

  Future<void> addDialogItem(String itemText, bool isOk) async {
    _checkDialogItemsText.add(
        DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now()) +
            '\t' +
            itemText +
            '\t' +
            (isOk ? 'УСПЕШНО' : 'ОШИБКА'));
    setState(() {
      _checkDialogItems.add(getCheckDialogItem(itemText, isOk));
    });

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> clearDialogItems() async {
    setState(() {
      _checkDialogItems.clear();
      _checkDialogItemsText.clear();
    });
    await _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> processCheckLogin() async {
    _checkDialogItems = <Widget>[];
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      'Проверка',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )),
              ],
            ),
          );
        });

    await clearDialogItems();

    var checkLoginResult;
    try {
      checkLoginResult = await checkSiteLogin();
    } catch (Exception) {
      checkLoginResult = false;
    }

    if (checkLoginResult) {
      await addDialogItem('Проверка подключения завершилась успешно', true);

      await updateSettings();
    } else {
      await addDialogItem(
          'В ходе проверки подключения возникли проблемы', false);
    }
  }

  Future<void> updateSettings() async {
    GlobalConfiguration().updateValue('url', _tecUrl.text);
    GlobalConfiguration().updateValue('login', _tecLogin.text);
    GlobalConfiguration().updateValue('password', _tecPassword.text);
    GlobalConfiguration().updateValue('lastDir', _tecFolder.text);

    File('${Directory.current.path}/data/flutter_assets/assets/cfg/app_settings.json')
        .create(recursive: true)
        .then((File file) {
      file.writeAsString(jsonEncode(GlobalConfiguration().appConfig));
    });
  }

  Future<bool> checkSiteLogin() async {
    var url = '${_tecUrl.text}/api/auth/login';
    var body = jsonEncode({
      'email': _tecLogin.text,
      'password': _tecPassword.text,
      'rememberMe': true
    });

    String authCookie = '';
    await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .then((http.Response response) {
      authCookie = response.headers['set-cookie'] ?? '';
    });

    return authCookie.isNotEmpty;
  }

  Future<void> openDirectory() async {
    if (_tecFolder.text.isNotEmpty &&
        await Directory(_tecFolder.text).exists()) {
      await Process.run('nautilus', ['${_tecFolder.text}/']);
    }
  }

  Future<void> openFinalDirectory() async {
    if (_tecFinalFolder.text.isNotEmpty &&
        await Directory(_tecFinalFolder.text).exists()) {
      await Process.run('nautilus', ['${_tecFinalFolder.text}/']);
    }
  }

  Future<void> checkDirectory() async {
    if (await Directory(_tecFinalFolder.text).exists()) {
      if (Directory(_tecFinalFolder.text).listSync().length > 0) {
        await addDialogItem(
            'Найдена не пустая директория повестки. Файлы будут перезаписаны.',
            true);
      } else {
        await addDialogItem('Найдена пустая директория повестки.', true);
      }
    } else {
      await addDialogItem('Директория повестки отсутствует.', true);
    }

    await updateSettings();
  }

  Future<void> loadData() async {
    _checkDialogItems = <Widget>[];
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      'Загрузка',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )),
              ],
            ),
          );
        });

    await clearDialogItems();

    await updateSettings();

    var agendaLoadResult;
    try {
      agendaLoadResult = await loadAgendaFromUrl();
    } catch (Exception) {
      agendaLoadResult = false;
    }

    if (agendaLoadResult) {
      await addDialogItem('Загрузка повестки завершилась успешно', true);
    } else {
      await addDialogItem('В ходе загрузки повестки возникли проблемы', false);
    }

    var agendaCheckResult;
    try {
      agendaCheckResult = await checkAgenda();
    } catch (Exception) {
      agendaCheckResult = false;
    }

    if (agendaCheckResult) {
      await addDialogItem('Проверка повестки завершилась успешно', true);
    } else {
      await addDialogItem('В ходе проверки повестки возникли проблемы', false);
    }
  }

  Future<bool> loadAgendaFromUrl() async {
    var agendaBody = '';
    agendaBody +=
        '№;Содержание вопроса;Кто вносит;Докладчики;Ответственный за подготовку\n';
    agendaBody += '0;Повестка дня;;;\n';

    var url = '${_tecUrl.text}/api/auth/login';
    var body = jsonEncode({
      'email': _tecLogin.text,
      'password': _tecPassword.text,
      'rememberMe': true
    });

    String authCookie = '';
    await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .then((http.Response response) {
      authCookie = response.headers['set-cookie'] ?? '';
    });

    if (authCookie.isNotEmpty) {
      await addDialogItem('Проверка подключения завершилась успешно', true);
    } else {
      await addDialogItem(
          'В ходе проверки подключения возникли проблемы', false);
      return false;
    }

    String activeSessionId = '';

    await http.read('${_tecUrl.text}/api/session/active',
        headers: {'Set-Cookie': authCookie}).then((contents) {
      activeSessionId = jsonDecode(contents)['uuid'];
    });

    if (activeSessionId.isNotEmpty) {
      await addDialogItem(
          'Получен идентификатор активной сессии: $activeSessionId', true);
    } else {
      await addDialogItem(
          'Не удалось загрузить идентификатор активной сессии', false);
      return false;
    }

    await http.read('${_tecUrl.text}/api/procedural/list/$activeSessionId',
        headers: {'Set-Cookie': authCookie}).then((contents) async {
      if (contents.isNotEmpty && contents != '[]') {
        List<dynamic> cont = jsonDecode(contents);

        await addDialogItem(
            'Обнаружены файлы основной повестки: ${cont.length}', true);

        Map<String, String> filesDescriptions = {};

        for (var c = 0; c < cont.length; c++) {
          var file = cont[c]['files'][0];

          String fileName =
              'Основная повестка[${c.toString().padLeft(2, '0')}].pdf';
          String fileSavePath = '${_tecFinalFolder.text}/0/$fileName';

          String fileDescription = cont[c]['annotation'].toString();
          if (fileDescription.endsWith('.pdf')) {
            fileDescription =
                fileDescription.substring(0, fileDescription.length - 4);
          }
          filesDescriptions[fileName] = fileDescription;

          await http.get(
              '${_tecUrl.text}/files/${file['documentUuid']}/${file['uuid']}.pdf',
              headers: {'Set-Cookie': authCookie}).then((response) {
            File(
              fileSavePath,
            ).create(recursive: true).then((File file) {
              file.writeAsBytes(response.bodyBytes);
            });
          });

          await addDialogItem('Загружен файл $fileSavePath', true);
        }

        await File(
          '${_tecFinalFolder.text}/0/Описание.txt',
        ).create(recursive: true).then((File file) {
          file.writeAsString(jsonEncode(filesDescriptions));
        });

        await addDialogItem(
            'Загружены описания вопросов ${_tecFinalFolder.text}/0/Описание.txt',
            true);
      } else {
        Directory('${_tecFinalFolder.text}/0').create(recursive: true);
        await addDialogItem('Файлы основной повестки не обнаружены', true);
      }
    });

    String documentsJson = '';

    await http.read('${_tecUrl.text}/api/document/list/$activeSessionId',
        headers: {'Set-Cookie': authCookie}).then((contents) {
      documentsJson = contents;
    });

    List<dynamic> documents = jsonDecode(documentsJson);

    await addDialogItem(
        'Обнаружены вопросы основной повестки: ${documents.length}', true);

    for (var d = 0; d < documents.length; d++) {
      String documentJson = '';
      await http.read(
          '${_tecUrl.text}/api/document/get/${documents[d]['uuid']}/true',
          headers: {'Set-Cookie': authCookie}).then((contents) {
        documentJson = contents;
      });

      agendaBody +=
          '${(d + 1).toString()};${HtmlUnescape().convert(jsonDecode(documentJson)['annotation']).replaceAll('\n', '')};;;\n';

      List<dynamic> files = jsonDecode(documentJson)['files'];

      Map<String, String> filesDescriptions = {};

      for (var f = 0; f < files.length; f++) {
        String fileName =
            'Вопрос${(d + 1).toString().padLeft(2, '0')}_файл${(f + 1).toString().padLeft(2, '0')}.pdf';
        String fileSavePath =
            '${_tecFinalFolder.text}/${(d + 1).toString()}/$fileName';

        String fileDescription = files[f]['description'].toString();
        if (fileDescription.endsWith('.pdf')) {
          fileDescription =
              fileDescription.substring(0, fileDescription.length - 4);
        }
        filesDescriptions[fileName] = fileDescription;

        await http.get(
            '${_tecUrl.text}/files/${files[f]['documentUuid']}/${files[f]['uuid']}.pdf',
            headers: {'Set-Cookie': authCookie}).then((response) {
          File(
            fileSavePath,
          ).create(recursive: true).then((File file) {
            file.writeAsBytes(response.bodyBytes);
          });
        });

        await addDialogItem('Загружен файл $fileSavePath', true);

        await File(
          '${_tecFinalFolder.text}/${(d + 1).toString()}/Описание.txt',
        ).create(recursive: true).then((File file) {
          file.writeAsString(jsonEncode(filesDescriptions));
        });

        await addDialogItem(
            'Загружены описания вопросов ${_tecFinalFolder.text}/${(d + 1).toString()}/Описание.txt',
            true);
      }

      await addDialogItem(
          'Загрузка файлов вопроса ${(d + 1)} завершена.', true);
    }

    await File(
      '${_tecFinalFolder.text}/Повестка.csv',
    ).create(recursive: true).then((File file) {
      file.writeAsString(agendaBody);
    });

    await addDialogItem(
        'Загрузка файла повестки ${_tecFinalFolder.text}/Повестка.csv завершена.',
        true);

    return true;
  }

  Future<bool> checkAgenda() async {
    // Проверяем доступ к файлу загрузки
    final agendaFile = new File(_tecFinalFolder.text + '/' + 'Повестка.csv');
    if (!agendaFile.existsSync()) {
      await addDialogItem('Отсутствует доступ к файлу повестки', false);
      return false;
    } else {
      await addDialogItem('Файл повестки доступен для загрузки', true);
    }

    var loadDir = agendaFile.parent;
    // Проверяем наличие файла повестки
    var agendaFilePath = '';
    var contents = loadDir.listSync();
    var documentFolders = <Directory>[];
    for (var fileOrDir in contents) {
      if (fileOrDir is File && fileOrDir.path.endsWith('.csv')) {
        agendaFilePath = fileOrDir.path;
      }

      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }

    if (agendaFilePath == '') {
      await addDialogItem('Директория не содержит файла повестки', false);
      return false;
    } else {
      await addDialogItem('Проверка наличия файла повестки', true);
    }

    // Проверяем файл повестки
    var agendaFileContent = new File(agendaFilePath).readAsStringSync();
    List<List<dynamic>> questions = const CsvToListConverter()
        .convert(agendaFileContent, fieldDelimiter: ';', eol: '\n');

    if (questions.length - 1 <= 0) {
      await addDialogItem('Файл повестки не содержит вопросов', false);
      return false;
    } else {
      await addDialogItem('Проверка формата файла повестки', true);
    }

    if (questions.length - 1 != documentFolders.length) {
      await addDialogItem(
          'Количество вопросов и директорий с документами не совпадают', false);
      return false;
    } else {
      await addDialogItem('Количество вопросов и директорий совпадают', true);
    }

    var isStructureCheckSuccess = true;
    var isDirectoriesCorrect = true;

    for (int i = 0; i < documentFolders.length; i++) {
      var documentFolder = documentFolders.firstWhere(
          (element) => path.basename(element.path) == i.toString(),
          orElse: () => Directory(''));

      if (documentFolder.path.isEmpty) {
        isDirectoriesCorrect = false;
        isStructureCheckSuccess = false;
        await addDialogItem('Не найдена директория для вопроса $i', false);
        continue;
      }

      var isFilesCorrect = true;
      var documentFolderContents = documentFolder.listSync();
      for (var fileOrDir in documentFolderContents) {
        var fullPath = fileOrDir.path;
        if (fileOrDir is Directory ||
            (path.extension(fileOrDir.path) != '.pdf' &&
                path.basename(fileOrDir.path) != 'Описание.txt')) {
          isFilesCorrect = false;
          isStructureCheckSuccess = false;

          await addDialogItem('Не поддерживается формат $fullPath', false);
        }
      }

      if (isFilesCorrect) {
        var folderFullPath = documentFolder.path;
        await addDialogItem('Проверка файлов директории $folderFullPath', true);
      } else {
        var folderFullPath = documentFolder.path;
        await addDialogItem(
            'Проверка файлов директории $folderFullPath', false);
      }
    }

    if (isDirectoriesCorrect) {
      await addDialogItem('Проверка имен директорий', true);
    }

    return isStructureCheckSuccess;
  }
}
