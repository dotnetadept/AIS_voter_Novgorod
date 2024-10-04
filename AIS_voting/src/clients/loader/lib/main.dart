import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ais_model/ais_model.dart';
import 'package:csv/csv.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:loader/AgendaListUtil.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:ais_utils/ais_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => runApp(MyApp()));
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
          backgroundColor: WidgetStateProperty.all(Colors.blue),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(EdgeInsets.all(20)),
          overlayColor: WidgetStateProperty.all(Colors.blueAccent),
        )),
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(12),
        ),
      ),
      home: Scaffold(
        body: LoaderForm(),
      ),
    );
  }
}

class LoaderForm extends StatefulWidget {
  @override
  LoaderFormState createState() {
    return LoaderFormState();
  }
}

class LoaderFormState extends State<LoaderForm> {
  final _formKey = GlobalKey<FormState>();
  var _tecName = TextEditingController();
  var _tecFile = TextEditingController(text: '');
  var _tecDirectoryName = TextEditingController(
      text: '_' + DateFormat('dd.MM.yyyy').format(DateTime.now()));
  ScrollController _scrollController = ScrollController();
  List<Widget> _checkDialogItems = <Widget>[];
  List<String> _checkDialogItemsText = <String>[];
  late Settings _settings;
  var _tecDefaultQuestionName = TextEditingController();
  var _tecFirstQuestionName = TextEditingController();
  var _tecAddtitionalQuestionName = TextEditingController();
  var _isSettingsLoaded = false;

  @override
  initState() {
    super.initState();

    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      await http
          .get(Uri.http(
              ServerConnection.getHttpServerUrl(GlobalConfiguration()),
              '/settings'))
          .then((value) async {
        _settings = (json.decode(value.body) as List)
            .map((data) => Settings.fromJson(data))
            .toList()
            .firstWhere((element) => element.isSelected);
        setState(() {
          _tecFirstQuestionName.text =
              _settings.questionListSettings.firstQuestion.defaultGroupName;
          _tecDefaultQuestionName.text =
              _settings.questionListSettings.mainQuestion.defaultGroupName;
          _tecAddtitionalQuestionName.text = _settings
              .questionListSettings.additionalQiestion.defaultGroupName;
        });
      }).then((value) {
        setState(() {
          _isSettingsLoaded = true;
        });
      });
    } catch (exception) {
      var noButtonPressed = false;
      var title = 'Отсутсвует подключение';

      await Utility().showYesNoDialog(
        context,
        title: title,
        message: TextSpan(
          text: 'Повторить попытку подключения?',
        ),
        yesButtonText: 'Да',
        yesCallBack: () {
          Navigator.of(context).pop();
        },
        noButtonText: 'Нет',
        noCallBack: () {
          noButtonPressed = true;
          Navigator.of(context).pop();
        },
      );

      if (noButtonPressed) {
        exit(0);
      }
      loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSettingsLoaded) {
      return Container();
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: leftPanel(),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(width: 170, height: 120, child: rightPanel()),
            ),
          ],
        ),
      ),
    );
  }

  Widget leftPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: Colors.blue,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                child: Text(
                  'Настройка повестки',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: TextFormField(
                  controller: _tecName,
                  decoration: InputDecoration(
                    hintText: 'Описание',
                    labelText: 'Описание',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  onChanged: (value) {
                    _tecDirectoryName.text = value +
                        '_' +
                        DateFormat('dd.MM.yyyy').format(DateTime.now());
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите описание';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: TextFormField(
                  controller: _tecDirectoryName,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Директория повестки на сервере',
                    labelText: 'Директория повестки на сервере',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: TextFormField(
                      controller: _tecFile,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Файл повестки заседания',
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите файл повестки';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => selectFile(),
                child: Text('Выберите файл повестки'),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.blue,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                child: Text(
                  'Настройка списка вопросов',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: TextFormField(
                      controller: _tecDefaultQuestionName,
                      decoration: InputDecoration(
                        labelText: 'Наименование вопроса по умолчанию',
                        hintText: 'Наименование вопроса по умолчанию',
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите наименование вопроса по умолчанию';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: TextFormField(
                      controller: _tecFirstQuestionName,
                      decoration: InputDecoration(
                        labelText: 'Наименование нулевого вопроса',
                        hintText: 'Наименование нулевого вопроса',
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите наименование нулевого вопроса';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _settings.questionListSettings.agendaFileExtension == 'csv'
            ? Container()
            : Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: TextFormField(
                            controller: _tecAddtitionalQuestionName,
                            decoration: InputDecoration(
                              labelText:
                                  'Наименование дополнительного вопроса по умолчанию',
                              hintText:
                                  'Наименование дополнительного вопроса по умолчанию',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите наименование дополнительного вопроса по умолчанию';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        Expanded(
          child: Container(
            color: Colors.black12,
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
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Scrollbar(
                      thumbVisibility: true,
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
        Container(
          height: 10,
        ),
      ],
    );
  }

  void copyToClipboard() {
    if (_checkDialogItemsText.length > 0) {
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

  void saveToFile() {
    FilePicker.platform.saveFile(
      fileName: 'журнал_' +
          DateFormat('dd.MM.yyyy_HH:mm:ss').format(DateTime.now()) +
          '.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
  }

  void selectFile() async {
    FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [_settings.questionListSettings.agendaFileExtension],
    ).then((filePicker) {
      _tecFile.text = filePicker?.files[0].path ?? '';
    }).catchError((onError) {});
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
              height: 10,
            ),
            Container(
              width: 120,
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _checkDialogItems = <Widget>[];
                    processCheck()
                        .then((value) => Future.delayed(
                            const Duration(milliseconds: 500),
                            () => Navigator.pop(context)))
                        .catchError((e) {
                      Navigator.pop(context);
                    });
                  }
                },
                child: Text(
                  'Проверить',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              height: 20,
            ),
            Container(
              width: 120,
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _checkDialogItems = <Widget>[];
                    loadData()
                        .then((value) => Navigator.pop(context))
                        .catchError((e) => Navigator.pop(context));
                  }
                },
                child: Text(
                  'Загрузить',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> processCheck() async {
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
                      "Проверка",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )),
              ],
            ),
          );
        });

    await clearDialogItems();

    var agendaCheckResult;
    try {
      agendaCheckResult = await checkAgenda();
    } catch (exception) {
      agendaCheckResult = false;
    }

    if (agendaCheckResult) {
      await addDialogResultItem('Проверка повестки завершилась успешно', true);
    } else {
      await addDialogResultItem(
          'В ходе проверки повестки возникли проблемы', false);
    }
  }

  Future<bool> checkAgenda() async {
    //Проверка соединения с базой данных
    var isOnline = true;
    var isUploadDirectoryExists = false;
    var agendas = <Agenda>[];
    await http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/agendas"))
        .then((response) async {
      agendas = (json.decode(response.body) as List)
          .map((data) => Agenda.fromJson(data))
          .toList();
      await addDialogResultItem('Проверка подключения к базе данных', true);

      // Проверяем существование повестки с подобной директорией
      if (agendas.any((element) => element.folder == _tecDirectoryName.text)) {
        isUploadDirectoryExists = true;
      }

      if (isUploadDirectoryExists) {
        await addDialogResultItem(
            'Директория с данным именем уже существует на сервере', false);
      } else {
        await addDialogResultItem(
            'Директория для загрузки имеет уникальное имя', true);
      }
    }).catchError((e) async {
      isOnline = false;
      await addDialogResultItem(
          'Отсутствует подключение к базе данных: {$e}', false);
    });

    // Проверяем подключение к файловому серверу
    String error = '';
    var request = http.MultipartRequest(
        'POST', Uri.parse(ServerConnection.getFileServerUploadUrl(_settings)));

    request.fields['ping'] = 'true';

    try {
      await request.send().then((value) async {
        if (value.statusCode != 200) {
          error = value.statusCode.toString();
        } else {
          await addDialogResultItem(
              'Проверка подключения к файловому серверу (${ServerConnection.getFileServerUploadUrl(_settings)}) ',
              true);
        }
      }).catchError((e) {
        error = e.toString();
      });
    } catch (exception) {
      error = exception.toString();
    }

    if (error.isNotEmpty) {
      await addDialogResultItem(
          'В ходе проверки подключения к файловому серверу (${ServerConnection.getFileServerUploadUrl(_settings)}) возникла ошибка: {$error}',
          false);
      return false;
    }

    // Проверяем доступ к файлу загрузки
    final agendaFile = new File(_tecFile.text);
    if (!agendaFile.existsSync()) {
      await addDialogResultItem('Отсутствует доступ к файлу повестки', false);
      return false;
    } else {
      await addDialogResultItem('Файл повестки доступен для загрузки', true);
    }

    var loadDir = agendaFile.parent;
    // Проверяем наличие файла повестки
    var agendaFilePath = '';
    var contents = loadDir.listSync();
    var documentFolders = <Directory>[];
    for (var fileOrDir in contents) {
      if (fileOrDir is File &&
          fileOrDir.path.endsWith(
              '.' + _settings.questionListSettings.agendaFileExtension)) {
        agendaFilePath = fileOrDir.path;
      }

      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }

    if (agendaFilePath == '') {
      await addDialogResultItem('Директория не содержит файла повестки', false);
      return false;
    } else {
      await addDialogResultItem('Проверка наличия файла повестки', true);
    }

    var isStructureCheckSuccess = false;

    if (_settings.questionListSettings.agendaFileExtension == 'txt') {
      isStructureCheckSuccess =
          await checkTxtStructure(agendaFilePath, documentFolders);
    }
    if (_settings.questionListSettings.agendaFileExtension == 'csv') {
      isStructureCheckSuccess =
          await checkCsvStructure(agendaFilePath, documentFolders);
    }

    return isOnline && !isUploadDirectoryExists && isStructureCheckSuccess;
  }

  Future<bool> checkCsvStructure(
      String agendaFilePath, List<Directory> documentFolders) async {
    // Проверяем файл повестки
    var agenFileBytes = await new File(agendaFilePath).readAsBytes();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());
    agendaFileContent = agendaFileContent.replaceAll('\r\n', '\n');

    List<List<dynamic>> questions =
        const CsvToListConverter().convert(agendaFileContent,
            fieldDelimiter: ',',
            textDelimiter: '"', // '98045465-cc0c-43ce-9469-ab7066e4d95e',
            textEndDelimiter: '"', // '98045465-cc0c-43ce-9469-ab7066e4d95e',
            eol: '\n');

    if (questions.length - 1 <= 0) {
      await addDialogResultItem('Файл повестки не содержит вопросов', false);
      return false;
    }

    if (questions.length - 1 != documentFolders.length) {
      await addDialogResultItem(
          'Количество вопросов и директорий с документами не совпадают', false);
      return false;
    } else {
      await addDialogResultItem(
          'Количество вопросов и директорий совпадают', true);
    }

    var isStructureCheckSuccess = true;
    var isDirectoriesCorrect = true;

    for (int i = 0; i < documentFolders.length; i++) {
      var documentFolder = documentFolders.firstWhereOrNull(
          (element) => path.basename(element.path) == i.toString());

      if (documentFolder == null) {
        isDirectoriesCorrect = false;
        isStructureCheckSuccess = false;
        await addDialogResultItem(
            'Не найдена директория для вопроса $i', false);
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

          await addDialogResultItem(
              'Не поддерживается формат $fullPath', false);
        }
      }

      if (isFilesCorrect) {
        await addDialogResultItem(
            'Проверка файлов директории ${documentFolder.path}', true);
      } else {
        await addDialogResultItem(
            'Проверка файлов директории ${documentFolder.path}', false);
      }
    }

    if (isDirectoriesCorrect) {
      await addDialogResultItem('Проверка имен директорий', true);
    }

    return isStructureCheckSuccess;
  }

  Future<bool> checkTxtStructure(
      String agendaFilePath, List<Directory> documentFolders) async {
    var agenFileBytes = await new File(agendaFilePath).readAsBytes();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());
    agendaFileContent = agendaFileContent.replaceAll('\r\n', '\n');

    // Проверяем файл повестки
    if (agendaFileContent.isEmpty) {
      await addDialogResultItem('Файл повестки пуст', false);
      return false;
    }

    List<String> questions = agendaFileContent.split('\n');
    questions.removeWhere((element) => element.trim().isEmpty);

    if (questions.length - 1 <= 0) {
      await addDialogResultItem('Файл повестки не содержит вопросов', false);
      return false;
    }

    questions.removeAt(0);

    if (questions.length != documentFolders.length) {
      await addDialogResultItem(
          'Количество вопросов и директорий с документами не совпадают', false);
      return false;
    } else {
      await addDialogResultItem(
          'Количество вопросов и директорий совпадают', true);
    }

    var isStructureCheckSuccess = true;
    // Проверяем вопросы
    for (int i = 0; i < questions.length; i++) {
      RegExp regExp = new RegExp(
          r'("[^"]*"),("?[^"]+"?),("[^"]*"),("[^"]*"),("[^"]*"),("[^"]*"),("[^"]*")');

      if (!regExp.hasMatch(questions[i])) {
        isStructureCheckSuccess = false;

        await addDialogResultItem(
            'Описание вопроса на строке $i не распознано', false);
        continue;
      }

      var isQuestionCorrect = true;
      var questionNumberData =
          regExp.firstMatch(questions[i])?.group(2)?.replaceAll('"', '') ?? '';

      var questionNumber = int.tryParse(questionNumberData);
      var expectedQuestionNumber = AgendaListUtil.getQuestionNumber(
          i, questions, _settings.questionListSettings);
      if (questionNumber != null && questionNumber != expectedQuestionNumber) {
        isQuestionCorrect = false;
        isStructureCheckSuccess = false;

        await addDialogResultItem(
            'Номер вопроса $questionNumber не соответвует ожидаемому $expectedQuestionNumber',
            false);
      }

      bool isDocumentFolderExists = documentFolders
          .any((element) => path.basename(element.path) == questionNumberData);

      if (!isDocumentFolderExists) {
        isQuestionCorrect = false;
        isStructureCheckSuccess = false;

        await addDialogResultItem(
            'Не найдена директория для вопроса $questionNumberData', false);
      } else {
        var documentFolder = documentFolders.firstWhere(
            (element) => path.basename(element.path) == questionNumberData);

        var descriptionFile = File(
            '${File(agendaFilePath).parent.path}/$questionNumberData/Описание.txt');

        if (!await descriptionFile.exists() && questions[i].isNotEmpty) {
          isQuestionCorrect = false;
          isStructureCheckSuccess = false;

          await addDialogResultItem(
              'Отсутствуeт файл описания документов: ${descriptionFile.path}',
              false);
          continue;
        }

        var realFileNames = <String>[];
        var documentFolderContents = documentFolder.listSync();

        documentFolderContents.sort((a, b) {
          return path.basename(a.path).compareTo(path.basename(b.path));
        });

        var descriptionsBytes = await descriptionFile.readAsBytes();
        var descriptionsFileContent =
            String.fromCharCodes(descriptionsBytes.buffer.asUint16List());
        Map<String, dynamic> descriptions =
            json.decode(descriptionsFileContent.substring(1));

        if (descriptions.length != documentFolderContents.length - 1) {
          isQuestionCorrect = false;
          isStructureCheckSuccess = false;

          await addDialogResultItem(
              'Количество документов[${(documentFolderContents.length - 1)}] и их описаний[${descriptions.length}] не совпадают ${documentFolder.path}',
              false);
          continue;
        }

        var j = 0;
        for (var fileOrDir in documentFolderContents) {
          var fullPath = fileOrDir.path;

          if (fileOrDir is File &&
              path.basename(fileOrDir.path) == 'Описание.txt') {
            continue;
          }

          if (fileOrDir is Directory ||
              path.extension(fileOrDir.path) != '.pdf') {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            await addDialogResultItem(
                'Не поддерживается формат $fullPath', false);
          } else {
            realFileNames.add(path.basename(fileOrDir.path));
          }

          String expectedFileName =
              AgendaListUtil.getFileName(questionNumberData, j + 1);

          if (realFileNames.last != expectedFileName) {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            await addDialogResultItem(
                'Имя файла: ${realFileNames.last} не соответвует ожидаемому: $expectedFileName',
                false);
          }

          j++;
        }

        if (descriptions.length != realFileNames.length) {
          isQuestionCorrect = false;
          isStructureCheckSuccess = false;

          await addDialogResultItem(
              'Несовпадает количество файлов в описании вопроса и директории $questionNumberData',
              false);
        }

        for (var fileDescription in descriptions.keys) {
          if (!realFileNames.contains(fileDescription)) {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            await addDialogResultItem(
                'Не найден файл $questionNumberData/$fileDescription', false);
          } else {
            await addDialogResultItem(
                'Проверка файла $questionNumberData/$fileDescription ', true);
          }
        }
      }

      await addDialogResultItem(
          'Проверка вопроса $questionNumberData', isQuestionCorrect);
    }

    return isStructureCheckSuccess;
  }

  Widget getResultDialogItem(String text, bool isOk) {
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

  Future<void> addDialogResultItem(String itemText, bool isOk) async {
    _checkDialogItemsText.add(
        DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now()) +
            '\t' +
            itemText +
            '\t' +
            (isOk ? 'УСПЕШНО' : 'ОШИБКА'));
    setState(() {
      _checkDialogItems.add(getResultDialogItem(itemText, isOk));
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

  Future<void> loadData() async {
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
                      "Загрузка",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )),
              ],
            ),
          );
        });

    await clearDialogItems();

    var agendaCheckResult;
    try {
      agendaCheckResult = await checkAgenda();
    } catch (exception) {
      print(exception);
      agendaCheckResult = false;
    }

    if (agendaCheckResult) {
      addDialogResultItem('Проверка повестки завершилась успешно', true);
    } else {
      addDialogResultItem('В ходе проверки повестки возникли проблемы', false);
      return;
    }

    var agendaQuestions = <Question>[];
    if (_settings.questionListSettings.agendaFileExtension == 'txt') {
      agendaQuestions.addAll(loadTxtQuestions());
    }
    if (_settings.questionListSettings.agendaFileExtension == 'csv') {
      agendaQuestions.addAll(loadCsvQuestions());
    }

    // Создаем повестку
    var agenda = new Agenda(
        id: 0,
        name: _tecName.text,
        folder: _tecDirectoryName.text,
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        questions: agendaQuestions);

    // Отправляем повестку на сервер
    String error = '';
    await http
        .post(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/agendas'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(agenda.toJson()))
        .then((value) {
      addDialogResultItem('Загрузка файла повестки', true);
    }).catchError((e) {
      error = e;
      addDialogResultItem(
          'В ходе загрузки повестки возникла ошибка: {$e}', false);
    });

    // Отправляем файлы на сервер
    if (error.isEmpty) {
      for (Question question in agenda.questions) {
        for (QuestionFile file in question.files) {
          var folderName = question.folder;
          var fullFilePath = file.realPath + '/' + file.fileName;
          var agendaFolderName = _tecDirectoryName.text;
          var request = http.MultipartRequest('POST',
              Uri.parse(ServerConnection.getFileServerUploadUrl(_settings)));

          request.fields['agendaName'] = '$agendaFolderName';
          request.fields['folderName'] = '$folderName';

          request.files
              .add(await http.MultipartFile.fromPath('file', fullFilePath));

          try {
            await request.send().then((value) {
              if (value.statusCode != 200) {
                error = value.statusCode.toString();
              } else {
                addDialogResultItem('Загрузка файла $fullFilePath', true);
              }
            }).catchError((e) {
              error = e.toString();
            });
          } catch (exception) {
            error = exception.toString();
          }

          if (error.isNotEmpty) {
            addDialogResultItem(
                'В ходе загрузки файла $fullFilePath возникла ошибка: {$error}',
                false);
            break;
          }
        }

        if (error.isNotEmpty) {
          break;
        }
      }
    }
    if (error.isNotEmpty) {
      addDialogResultItem('В ходе загрузки повестки возникли проблемы', false);
    } else {
      addDialogResultItem('Загрузка повестки завершилась успешно', true);
    }
  }

  String intFixed(int n, int count) => n.toString().padLeft(count, "0");

  List<Question> loadCsvQuestions() {
    final agendaFile = new File(_tecFile.text);

    // Получаем папки с документами
    var documentFolders = <Directory>[];
    for (var fileOrDir in agendaFile.parent.listSync()) {
      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }

    var agenFileBytes = agendaFile.readAsBytesSync();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());
    agendaFileContent = agendaFileContent.replaceAll('\r\n', '\n');

    List<List<dynamic>> tableQuestions = const CsvToListConverter().convert(
      agendaFileContent,
      fieldDelimiter: ',',
      textDelimiter: '"', // '98045465-cc0c-43ce-9469-ab7066e4d95e',
      textEndDelimiter: '"', // '98045465-cc0c-43ce-9469-ab7066e4d95e',
      eol: '\n',
    );
    var agendaQuestions = <Question>[];

    for (int i = 0; i < tableQuestions.length; i++) {
      if (i == 0) {
        continue;
      }

      // Вычисляем порядковый номер вопроса
      var questionOrder = i - 1;

      // Загружаем описание вопроса
      var tableQuestion = tableQuestions[i];
      var questionDescriptions = <QuestionDescriptionItem>[];
      for (int j = 0; j < tableQuestion.length; j++) {
        if (j == 0 || i == 1) {
          continue;
        }
        if (tableQuestion[j].toString().isNotEmpty) {
          var descriptionItem = new QuestionDescriptionItem(
              caption: '', //tableQuestions[0][j] + ':',
              text: tableQuestion[j].toString(),
              showInReports: true,
              showOnStoreboard: true);
          questionDescriptions.add(descriptionItem);
        }
      }

      // Загружаем файлы вопроса
      var questionFolder = Uuid().v4();
      var documentFolder = documentFolders.firstWhereOrNull(
          (element) => path.basename(element.path) == questionOrder.toString());
      var questionFiles = <QuestionFile>[];

      var documentFolderContents = documentFolder!.listSync();
      documentFolderContents.sort((a, b) => a.path.compareTo(b.path));

      // Загружаем описания файлов вопросов
      var descriptionFile = documentFolderContents.firstWhereOrNull(
          (element) => path.basename(element.path) == 'Описание.txt');
      Map<String, dynamic> filesDescriptions = {};
      if (descriptionFile != null) {
        filesDescriptions = jsonDecode(String.fromCharCodes(File(
          descriptionFile.path,
        ).readAsBytesSync().buffer.asUint16List()));
      }

      for (var fileOrDir in documentFolderContents) {
        if (fileOrDir is File && path.extension(fileOrDir.path) == '.pdf') {
          String fileDescription =
              filesDescriptions[path.basename(fileOrDir.path)] ??
                  path.basenameWithoutExtension(fileOrDir.path);

          RegExp fileNameTrimmer =
              new RegExp(_settings.questionListSettings.fileNameTrimmer);

          if (fileDescription.startsWith(fileNameTrimmer)) {
            fileDescription = fileDescription.replaceFirst(fileNameTrimmer, '');
          }

          var questionFile = new QuestionFile(
            id: 0,
            questionId: 0,
            relativePath:
                _tecDirectoryName.text + '/' + questionFolder.toString(),
            realPath: path.dirname(fileOrDir.path),
            fileName: path.basename(fileOrDir.path),
            version: Uuid().v4(),
            description: fileDescription,
          );
          questionFiles.add(questionFile);
        }
      }

      // Создаем вопрос
      var question = new Question(
          id: 0,
          accessRights: <int>[],
          agendaId: 0,
          name: questionOrder == 0
              ? _tecFirstQuestionName.text
              : _tecDefaultQuestionName.text,
          folder: questionFolder,
          orderNum: questionOrder,
          descriptions: questionDescriptions,
          files: questionFiles);

      agendaQuestions.add(question);
    }

    return agendaQuestions.toList();
  }

  List<Question> loadTxtQuestions() {
    List<Question> agendaQuestions = <Question>[];
    var agendaFile = new File(_tecFile.text);
    var agenFileBytes = agendaFile.readAsBytesSync();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());
    agendaFileContent = agendaFileContent.replaceAll('\r\n', '\n');

    // Получаем папки с документами
    var documentFolders = <Directory>[];
    for (var fileOrDir in agendaFile.parent.listSync()) {
      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }

    List<String> questions = agendaFileContent.split('\n');
    questions.removeWhere((element) => element.trim().isEmpty);
    questions.removeAt(0);

    // Загружаем вопросы
    for (int i = 0; i < questions.length; i++) {
      RegExp regExp = new RegExp(
          r'("[^"]*"),("?[^"]+"?),("[^"]*"),("[^"]*"),("[^"]*"),("[^"]*"),("[^"]*")');

      var questionNumberData =
          regExp.firstMatch(questions[i])?.group(2)?.replaceAll('"', '');
      var questionDescriptionData1 =
          regExp.firstMatch(questions[i])?.group(4)?.replaceAll('"', '');
      var questionDescriptionData2 =
          regExp.firstMatch(questions[i])?.group(5)?.replaceAll('"', '');
      var questionDescriptionData3 =
          regExp.firstMatch(questions[i])?.group(6)?.replaceAll('"', '');
      var questionDescriptionData4 =
          regExp.firstMatch(questions[i])?.group(7)?.replaceAll('"', '');

      // Загружаем описание вопроса
      var questionDescriptions = <QuestionDescriptionItem>[];

      var questionNumber = i;
      var questionName = _tecDefaultQuestionName.text;
      var questionSettings = _settings.questionListSettings.mainQuestion;

      if (questionNumber == 0) {
        questionName = _tecFirstQuestionName.text;
        questionSettings = _settings.questionListSettings.firstQuestion;
      }

      if (int.tryParse(questionNumberData ?? '') == null) {
        questionName = _tecAddtitionalQuestionName.text;
        questionSettings = _settings.questionListSettings.additionalQiestion;
      }

      //if (questionDescriptionData1.trim().isNotEmpty) {
      questionDescriptions.add(new QuestionDescriptionItem(
          caption: questionSettings.descriptionCaption1,
          text: questionDescriptionData1.toString(),
          showOnStoreboard: questionSettings.showCaption1OnStoreboard,
          showInReports: questionSettings.showCaption1InReports));
      //}
      //if (questionDescriptionData2.trim().isNotEmpty) {
      questionDescriptions.add(new QuestionDescriptionItem(
          caption: questionSettings.descriptionCaption2,
          text: questionDescriptionData2.toString(),
          showOnStoreboard: questionSettings.showCaption2OnStoreboard,
          showInReports: questionSettings.showCaption2InReports));
      //}
      //if (questionDescriptionData3.trim().isNotEmpty) {
      questionDescriptions.add(new QuestionDescriptionItem(
          caption: questionSettings.descriptionCaption3,
          text: questionDescriptionData3.toString(),
          showOnStoreboard: questionSettings.showCaption3OnStoreboard,
          showInReports: questionSettings.showCaption3InReports));
      //}
      //if (questionDescriptionData4.trim().isNotEmpty) {
      questionDescriptions.add(new QuestionDescriptionItem(
          caption: questionSettings.descriptionCaption4,
          text: questionDescriptionData4.toString(),
          showOnStoreboard: questionSettings.showCaption4OnStoreboard,
          showInReports: questionSettings.showCaption4InReports));
      //}

      // Загружаем файлы вопроса
      var questionFolder = Uuid().v4();
      var documentFolder = documentFolders.firstWhereOrNull((element) =>
          path.basename(element.path) == questionNumberData.toString());
      var questionFiles = <QuestionFile>[];

      var documentFolderContents = documentFolder!.listSync();
      documentFolderContents.sort((a, b) => a.path.compareTo(b.path));

      var descriptionFile = documentFolderContents.firstWhereOrNull(
          (element) => path.basename(element.path) == 'Описание.txt');
      Map<String, dynamic> filesDescriptions = {};
      if (descriptionFile != null) {
        var descriptionsBytes = File(descriptionFile.path).readAsBytesSync();
        var descriptionsFileContent =
            String.fromCharCodes(descriptionsBytes.buffer.asUint16List());
        filesDescriptions = json.decode(descriptionsFileContent.substring(1));
      }

      for (var fileOrDir in documentFolderContents) {
        if (fileOrDir is File && path.extension(fileOrDir.path) == '.pdf') {
          String fileDescription =
              filesDescriptions[path.basename(fileOrDir.path)] ??
                  path.basenameWithoutExtension(fileOrDir.path);

          RegExp fileNameTrimmer =
              new RegExp(_settings.questionListSettings.fileNameTrimmer);
          if (fileDescription.startsWith(fileNameTrimmer)) {
            fileDescription = fileDescription.replaceFirst(fileNameTrimmer, '');
          }

          var questionFile = new QuestionFile(
            id: 0,
            questionId: 0,
            relativePath:
                _tecDirectoryName.text + '/' + questionFolder.toString(),
            realPath: path.dirname(fileOrDir.path),
            fileName: path.basename(fileOrDir.path),
            version: Uuid().v4(),
            description: fileDescription,
          );
          questionFiles.add(questionFile);
        }
      }

      // Создаем вопрос
      var question = new Question(
          id: 0,
          name: questionName,
          folder: questionFolder,
          orderNum: questionNumber,
          descriptions: questionDescriptions,
          files: questionFiles,
          accessRights: <int>[],
          agendaId: 0);

      //agendaQuestions.add(question);
      QuestionListUtil.insert(
          _settings, agendaQuestions, question, agendaQuestions.length);
    }

    return agendaQuestions;
  }
}
