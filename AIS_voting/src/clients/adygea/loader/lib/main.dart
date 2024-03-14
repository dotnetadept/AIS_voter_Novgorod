import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ais_model/ais_model.dart';
import 'package:csv/csv.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
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
  Settings _settings;
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
          .get(ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
              '/settings')
          .then((value) async {
        _settings = (json.decode(value.body) as List)
            .map((data) => Settings.fromJson(data))
            .toList()
            .firstWhere((element) => element.isSelected, orElse: () => null);
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
                    if (value.isEmpty) {
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
                        if (value.isEmpty) {
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
                        if (value.isEmpty) {
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
                        if (value.isEmpty) {
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
                              if (value.isEmpty) {
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

  void selectFile() async {
    FilePickerCross.importFromStorage(
            type: FileTypeCross.custom,
            fileExtension: _settings.questionListSettings.agendaFileExtension)
        .then((filePicker) {
      _tecFile.text = filePicker.path;
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
                  if (_formKey.currentState.validate()) {
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

    var agendaQuestions = <Question>[];
    agendaQuestions.addAll(loadTxtQuestions());

    // Создаем повестку
    var agenda = new Agenda(
        name: _tecName.text,
        folder: _tecDirectoryName.text,
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        questions: agendaQuestions);

    // Отправляем повестку на сервер
    String error = '';
    await http
        .post(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                '/agendas',
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

    if (error.isNotEmpty) {
      addDialogResultItem('В ходе загрузки повестки возникли проблемы', false);
    } else {
      addDialogResultItem('Загрузка повестки завершилась успешно', true);
    }
  }

  String intFixed(int n, int count) => n.toString().padLeft(count, "0");

  List<Question> loadTxtQuestions() {
    List<Question> agendaQuestions = <Question>[];
    var agendaFile = new File(_tecFile.text);
    var agenFileBytes = agendaFile.readAsBytesSync();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());

    // Получаем папки с документами
    var documentFolders = <Directory>[];
    for (var fileOrDir in agendaFile.parent.listSync()) {
      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }

    List<String> questions = agendaFileContent.split('\n');
    questions.removeWhere((element) => element.trim().isEmpty);

    // Загружаем вопросы
    for (int i = 0; i < questions.length; i++) {
      RegExp regExp = new RegExp(r'([\d]*д?);([^"]*)');

      var questionNumberData =
          regExp.firstMatch(questions[i]).group(1).replaceAll('"', '');
      var questionDescriptionData1 =
          regExp.firstMatch(questions[i]).group(2).replaceAll('"', '');

      // Загружаем описание вопроса
      var questionDescriptions = <QuestionDescriptionItem>[];

      var questionNumber = i;
      var questionName = _tecDefaultQuestionName.text;
      var questionSettings = _settings.questionListSettings.mainQuestion;

      if (questionNumber == 0) {
        questionName = _tecFirstQuestionName.text;
        questionSettings = _settings.questionListSettings.firstQuestion;
      }

      if (int.tryParse(questionNumberData) == null) {
        questionName = _tecAddtitionalQuestionName.text;
        questionSettings = _settings.questionListSettings.additionalQiestion;
      }

      if (questionDescriptionData1.trim().isNotEmpty) {
        questionDescriptions.add(new QuestionDescriptionItem(
            caption: questionSettings.descriptionCaption1,
            text: questionDescriptionData1.toString(),
            showOnStoreboard: questionSettings.showCaption1OnStoreboard,
            showInReports: questionSettings.showCaption1InReports));
      }

      // Создаем вопрос
      var question = new Question(
        name: questionName,
        folder: '',
        orderNum: questionNumber,
        descriptions: questionDescriptions,
        files: <QuestionFile>[],
      );

      //agendaQuestions.add(question);
      QuestionListUtil.insert(
          _settings, agendaQuestions, question, agendaQuestions.length);
    }

    return agendaQuestions;
  }
}
