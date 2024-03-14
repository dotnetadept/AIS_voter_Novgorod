import 'dart:convert';
import 'dart:io';

import 'package:ais_utils/ais_utils.dart';
import 'package:ais_utils/dialogs.dart';
import 'package:csv/csv.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:ais_model/ais_model.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Создание списка вопросов',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          overlayColor: MaterialStateProperty.all(Colors.blueAccent),
          padding: MaterialStateProperty.all(EdgeInsets.all(20)),
        )),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String fileExtension = 'csv';
  final RegExp fileNameTrimmer = RegExp('');

  QuestionGroupSettings firstQuestion = QuestionGroupSettings();
  QuestionGroupSettings mainQuestion = QuestionGroupSettings();
  QuestionGroupSettings additionalQiestion = QuestionGroupSettings();
  Settings _settings = Settings();

  final _tecFile = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _tecQuestionName = TextEditingController();
  TextEditingController _tecQuestionPosition = TextEditingController();

  ScrollController _questionsScrollController = ScrollController();
  ScrollController _addQuestionScrollContoller = ScrollController();
  ScrollController _questionsDescriptionsScrollController = ScrollController();

  List<Question> _questions = <Question>[];
  Question _selectedQuestion = Question();
  Question _editedQuestion = Question();
  List<QuestionFile> _files = <QuestionFile>[];
  List<QuestionDescriptionItem> _questionDescriptions =
      <QuestionDescriptionItem>[];

  List<TextEditingController> _tecDescriptionCaptions =
      <TextEditingController>[];
  List<TextEditingController> _tecDescriptionTexts = <TextEditingController>[];

  @override
  void initState() {
    //init settings
    firstQuestion.defaultGroupName = 'Повестка';
    mainQuestion.defaultGroupName = 'Вопрос';
    additionalQiestion.defaultGroupName = 'Доп. вопрос';

    _settings.questionListSettings.firstQuestion = firstQuestion;
    _settings.questionListSettings.mainQuestion = mainQuestion;
    _settings.questionListSettings.additionalQiestion = additionalQiestion;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Text('Создание списка вопросов'),
            ),
            Tooltip(
              message: 'Сохранить файл повестки',
              child: TextButton(
                onPressed: saveQuestionList,
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: TextFormField(
                    controller: _tecFile,
                    readOnly: true,
                    decoration: const InputDecoration(
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
              TextButton(
                onPressed: () async {
                  await selectFile();
                  _questions = loadCsvQuestions();
                  setState(() {});
                },
                child: const Text('Выберите файл повестки'),
              ),
            ],
          ),
          Container(
            height: 20,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: getQuestionsTable(),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: getQuestionSection(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Question> loadCsvQuestions() {
    if (_tecFile.text.isEmpty) {
      return <Question>[];
    }

    final agendaFile = File(_tecFile.text);

    // Получаем папки с документами
    var documentFolders = <Directory>[];
    for (var fileOrDir in agendaFile.parent.listSync()) {
      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }

    var agendaFileContent = agendaFile.readAsStringSync();

    List<List<dynamic>> tableQuestions = const CsvToListConverter().convert(
      agendaFileContent,
      fieldDelimiter: ';',
      textDelimiter: '98045465-cc0c-43ce-9469-ab7066e4d95e',
      textEndDelimiter: '98045465-cc0c-43ce-9469-ab7066e4d95e',
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
          var descriptionItem = QuestionDescriptionItem(
              caption: '', //tableQuestions[0][j] + ':',
              text: tableQuestion[j].toString(),
              showInReports: true,
              showOnStoreboard: true);
          questionDescriptions.add(descriptionItem);
        }
      }

      // Загружаем файлы вопроса
      var questionFiles = <QuestionFile>[];
      var documentFolderContents = <FileSystemEntity>[];
      Directory documentFolder = Directory('');

      if (documentFolders.any((element) =>
          path.basename(element.path) == questionOrder.toString())) {
        documentFolder = documentFolders.firstWhere((element) =>
            path.basename(element.path) == questionOrder.toString());

        documentFolderContents = documentFolder.listSync();
        documentFolderContents.sort((a, b) => a.path.compareTo(b.path));
      }

      // Загружаем описания файлов вопросов
      Map<String, dynamic> filesDescriptions = <String, dynamic>{};
      if (documentFolderContents
          .any((element) => path.basename(element.path) == 'Описание.txt')) {
        FileSystemEntity descriptionFile = documentFolderContents.firstWhere(
            (element) => path.basename(element.path) == 'Описание.txt');
        filesDescriptions = jsonDecode(File(
          descriptionFile.path,
        ).readAsStringSync());
      }

      for (var fileOrDir in documentFolderContents) {
        if (fileOrDir is File && path.extension(fileOrDir.path) == '.pdf') {
          String fileDescription =
              filesDescriptions[path.basename(fileOrDir.path)] ??
                  path.basenameWithoutExtension(fileOrDir.path);

          if (fileDescription.startsWith(fileNameTrimmer)) {
            fileDescription = fileDescription.replaceFirst(fileNameTrimmer, '');
          }

          var questionFile = QuestionFile(
            realPath: path.dirname(fileOrDir.path),
            fileName: path.basename(fileOrDir.path),
            version: Uuid().v4(),
            description: fileDescription,
          );
          questionFiles.add(questionFile);
        }
      }

      // Создаем вопрос
      var question = Question(
        id: questionOrder,
        name: questionOrder == 0
            ? firstQuestion.defaultGroupName
            : mainQuestion.defaultGroupName,
        folder: documentFolder.path,
        orderNum: questionOrder,
        descriptions: questionDescriptions,
        files: questionFiles,
      );

      agendaQuestions.add(question);
    }

    return agendaQuestions.toList();
  }

  void saveQuestionList() {
    try {
      List<List<String>> rows = <List<String>>[];

      rows.add(<String>[
        '№',
        mainQuestion.descriptionCaption1,
        mainQuestion.descriptionCaption2,
        mainQuestion.descriptionCaption3,
        mainQuestion.descriptionCaption4,
      ]);

      for (int i = 0; i < _questions.length; i++) {
        rows.add(<String>[
          i.toString(),
          _questions[i].descriptions.length > 0
              ? _questions[i].descriptions[0].text
              : "",
          _questions[i].descriptions.length > 1
              ? _questions[i].descriptions[1].text
              : "",
          _questions[i].descriptions.length > 2
              ? _questions[i].descriptions[2].text
              : "",
          _questions[i].descriptions.length > 3
              ? _questions[i].descriptions[3].text
              : "",
        ]);
      }

      var fileContent = const ListToCsvConverter(
        fieldDelimiter: ';',
      ).convert(rows);

      File agendaFile = File(_tecFile.text);

      agendaFile.writeAsString(fileContent).then((value) async {
        await Utility().showMessageOkDialog(
          context,
          title: "Сохранение",
          message:
              TextSpan(text: "Сохранение списка вопросов завершилось успешно"),
          okButtonText: 'ОК',
        );
      });
    } catch (e) {
      Utility().showMessageOkDialog(context,
          title: 'Сохранение повестки',
          message: TextSpan(
            text: 'В ходе сохранение повестки возникла ошибка: {$e}',
          ),
          okButtonText: 'Ок');
    }

    setState(() {});
  }

  Future<void> selectFile() async {
    await FilePickerCross.importFromStorage(
            type: FileTypeCross.custom, fileExtension: fileExtension)
        .then((filePicker) {
      _tecFile.text = filePicker.path;
    }).catchError((onError) {});
  }

  Widget getQuestionsTable() {
    Question newQuestionStub = Question(
        name: 'Новый вопрос',
        descriptions: createQuestionDescription(mainQuestion));

    var newQuestionItem = DragAndDropItem(
      child: Column(children: [
        Container(
          height: 6,
        ),
        Container(
          //width: 900,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.fromLTRB(40, 0, 0, 0),
          child: Text(
            newQuestionStub.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 6,
        ),
        Container(
          //width: 900,
          height: 55,
          margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: AgendaUtil.getQuestionDescriptionText(
            newQuestionStub,
            14,
            isAutoSize: true,
            showHiddenSections: true,
          ),
        ),
      ]),
    );

    return Column(
      children: [
        Container(
          color: Colors.lightBlue,
          // width: 900,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 20,
              ),
              const Text(
                'Вопросы',
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(),
              ),
              Row(
                children: [
                  Tooltip(
                    message: 'Переместите вопрос в список вопросов',
                    child: Center(
                      child: Draggable<DragAndDropItem>(
                        feedback: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.blue),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        data: newQuestionItem,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.blue),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.black26)),
            child: DragAndDropLists(
              scrollController: _questionsScrollController,
              onItemReorder: (var a, var b, var c, var d) {
                onItemReorder(a, b, c, d);
                setState(() {});
              },
              onListReorder: (var a, var b) {
                setState(() {});
              },
              onItemAdd: (DragAndDropItem newItem, int listIndex,
                  int itemIndex) async {
                var noButtonPressed = false;
                var title = 'Добавить вопрос';
                var selectedOption;

                await Utility().showYesNoOptionsDialog(
                  context,
                  title: title,
                  text: 'Вы уверены, что хотите ${title.toLowerCase()}?',
                  options: <String>[
                    "Первый вопрос",
                    "Основной вопрос",
                    "Дополнительный вопрос",
                    "Пустой вопрос",
                  ],
                  yesButtonText: 'Да',
                  yesCallBack: (String option) {
                    selectedOption = option;

                    Navigator.of(context).pop();
                  },
                  noButtonText: 'Нет',
                  noCallBack: () {
                    noButtonPressed = true;
                    Navigator.of(context).pop();
                  },
                );

                var settingsGroup = mainQuestion;

                if (noButtonPressed) {
                  return;
                }

                if (selectedOption == "Первый вопрос") {
                  settingsGroup = firstQuestion;
                }
                if (selectedOption == "Основной вопрос") {
                  settingsGroup = mainQuestion;
                }
                if (selectedOption == "Дополнительный вопрос") {
                  settingsGroup = additionalQiestion;
                }
                if (selectedOption == "Пустой вопрос") {
                  settingsGroup = QuestionGroupSettings();
                }

                // new item
                if (itemIndex == -1) {
                  itemIndex = _questions.length;
                }

                _editedQuestion = Question();
                _editedQuestion.orderNum = itemIndex;
                _editedQuestion.name = settingsGroup.defaultGroupName;
                _editedQuestion.descriptions =
                    createQuestionDescription(settingsGroup);
                _editedQuestion.files = <QuestionFile>[];

                _questions.insert(itemIndex, _editedQuestion);
                normalizeList(_questions, true);

                // create folder for new question
                Directory(
                        '${File(_tecFile.text).parent.path}\\${_editedQuestion.orderNum}')
                    .createSync();

                setState(() {
                  _tecQuestionName.text = _editedQuestion.toString();
                  _tecQuestionPosition.text =
                      _editedQuestion.orderNum.toString();
                  _files = <QuestionFile>[];
                  _questionDescriptions =
                      createQuestionDescription(settingsGroup);
                  _tecDescriptionCaptions = <TextEditingController>[];
                  _tecDescriptionTexts = <TextEditingController>[];
                  for (var description in _questionDescriptions) {
                    _tecDescriptionCaptions
                        .add(TextEditingController(text: description.caption));
                    _tecDescriptionTexts
                        .add(TextEditingController(text: description.text));
                  }
                });
              },
              itemDragHandle: const DragHandle(
                onLeft: true,
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.menu,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              children: <DragAndDropList>[
                DragAndDropList(
                  children: _questions
                      .map(
                        ((element) => DragAndDropItem(
                              child: Container(
                                color: element.id == _editedQuestion.id
                                    ? Colors.blue.withOpacity(0.4)
                                    : Colors.white,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                    ),
                                    Text(
                                      element.orderNum.toString(),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(children: [
                                        Container(
                                          height: 6,
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          // margin: const EdgeInsets.fromLTRB(
                                          //      60, 0, 0, 0),
                                          child: Text(
                                            element.toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          height: 6,
                                        ),
                                        Container(
                                          //margin: const EdgeInsets.fromLTRB(
                                          //    30, 0, 0, 0),
                                          height: 55,
                                          child: AgendaUtil
                                              .getQuestionDescriptionText(
                                            element,
                                            14,
                                            isAutoSize: true,
                                            showHiddenSections: true,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Tooltip(
                                      message: 'Редактировать вопрос',
                                      child: TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.black),
                                          overlayColor:
                                              MaterialStateProperty.all(
                                                  Colors.black12),
                                          shape: MaterialStateProperty.all(
                                            const CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.transparent)),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (!onSaveQuestion()) {
                                            return;
                                          }

                                          setState(() {
                                            _editedQuestion = element;

                                            _tecQuestionName.text =
                                                _editedQuestion.name;
                                            _tecQuestionPosition.text =
                                                _editedQuestion.orderNum
                                                    .toString();

                                            _tecDescriptionCaptions =
                                                <TextEditingController>[];
                                            _tecDescriptionTexts =
                                                <TextEditingController>[];

                                            _questionDescriptions =
                                                _editedQuestion.descriptions;

                                            for (var description
                                                in _questionDescriptions) {
                                              _tecDescriptionCaptions.add(
                                                  TextEditingController(
                                                      text:
                                                          description.caption));
                                              _tecDescriptionTexts.add(
                                                  TextEditingController(
                                                      text: description.text));
                                            }

                                            _files = List<QuestionFile>.from(
                                                _editedQuestion.files);
                                          });
                                        },
                                        child: const Icon(Icons.edit),
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Удалить вопрос',
                                      child: TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.black),
                                          overlayColor:
                                              MaterialStateProperty.all(
                                                  Colors.black12),
                                          shape: MaterialStateProperty.all(
                                            const CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.transparent)),
                                          ),
                                        ),
                                        onPressed: () async {
                                          var noButtonPressed = false;
                                          var title = 'Удалить вопрос';

                                          await Utility().showYesNoDialog(
                                            context,
                                            title: title,
                                            message: TextSpan(
                                                text:
                                                    'Вы уверены, что хотите ${title.toLowerCase()}?'),
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
                                            return;
                                          }

                                          _questions.remove(element);

                                          // remove question folder
                                          var questionDirectory = Directory(
                                              '${File(_tecFile.text).parent.path}\\${element.orderNum}');

                                          if (questionDirectory.existsSync()) {
                                            questionDirectory.deleteSync();
                                          }

                                          normalizeList(_questions, false);

                                          setState(() {});
                                        },
                                        child: const Icon(Icons.delete,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void normalizeList(List<Question> questions, bool isReverseDirection) {
    var folders = File(_tecFile.text).parent.listSync();

    if (isReverseDirection) {
      for (int i = questions.length - 1; i >= 0; i--) {
        var foundFolder = folders.firstWhere(
            (element) =>
                path.basename(element.path) == questions[i].orderNum.toString(),
            orElse: () => Directory(''));

        bool isFolderExists =
            foundFolder is Directory && foundFolder.path != '';
        // rename existing folder
        if (questions[i].orderNum != i && isFolderExists) {
          foundFolder.renameSync('${foundFolder.parent.path}\\$i');
        }

        questions[i].id = i;
        questions[i].orderNum = i;
        questions[i].folder = i.toString();
      }
    } else {
      for (int i = 0; i < questions.length; i++) {
        var foundFolder = folders.firstWhere(
            (element) =>
                path.basename(element.path) == questions[i].orderNum.toString(),
            orElse: () => Directory(''));

        bool isFolderExists =
            foundFolder is Directory && foundFolder.path != '';
        // rename existing folder
        if (questions[i].orderNum != i && isFolderExists) {
          foundFolder.renameSync('${foundFolder.parent.path}\\$i');
        }

        questions[i].id = i;
        questions[i].orderNum = i;
        questions[i].folder = i.toString();
      }
    }
  }

  bool onSaveQuestion() {
    if (_editedQuestion.id == null) {
      return true;
    }
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    _editedQuestion.name = _tecQuestionName.text;

    _editedQuestion.descriptions = <QuestionDescriptionItem>[];
    for (int i = 0; i < _questionDescriptions.length; i++) {
      _editedQuestion.descriptions.add(QuestionDescriptionItem(
        caption: _tecDescriptionCaptions[i].text,
        text: _tecDescriptionTexts[i].text,
        showOnStoreboard: true,
        showInReports: true,
      ));
    }

    _editedQuestion.orderNum = int.parse(_tecQuestionPosition.text);
    _editedQuestion.files = _files;

    return true;
  }

  Widget getQuestionSection() {
    if (_editedQuestion.id == null) {
      return const Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Text('Выберите вопрос'),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _addQuestionScrollContoller,
        child: SingleChildScrollView(
          controller: _addQuestionScrollContoller,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListBody(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 13, 15, 13),
                  color: Colors.lightBlue,
                  width: 640,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _editedQuestion.toString(),
                          style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Tooltip(
                        message: 'Сохранить вопрос',
                        child: TextButton(
                          onPressed: () {
                            onSaveQuestion();
                          },
                          child: const Icon(Icons.save),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                TextFormField(
                  controller: _tecQuestionName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Наименование вопроса',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите наименование вопроса';
                    }
                    return null;
                  },
                ),
                Container(
                  height: 10,
                ),
                TextField(
                  enabled: false,
                  readOnly: true,
                  style: const TextStyle(color: Colors.grey),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Порядковый номер',
                  ),
                  controller: _tecQuestionPosition,
                ),
                Container(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 5, 15, 5),
                  color: Colors.lightBlue,
                  width: 640,
                  child: Row(
                    children: [
                      const Text(
                        'Содержание вопроса',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Tooltip(
                          message: 'Добавить вопрос в список вопросов',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                const CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () {
                              addQuestionDescription();
                            },
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getNewQuestionDescription(),
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 5, 15, 5),
                  color: Colors.lightBlue,
                  width: 640,
                  child: Row(
                    children: [
                      const Text(
                        'Файлы вопроса',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Tooltip(
                          message: 'Добавить файл',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                const CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () async {
                              await addSelectedQuestionFile();
                            },
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getFilesTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getFilesTable() {
    if (_files.isEmpty) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            dataRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.black12;
            }),
            columns: const [
              DataColumn(
                label: Text(
                  'Имя файла',
                ),
              ),
              DataColumn(
                label: Text(
                  'Описание',
                ),
              ),
            ],
            rows: _files
                .map(
                  ((element) => DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(element.fileName),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(children: [
                                    Tooltip(
                                      message: element.description,
                                      child: Text(element.description,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true),
                                    ),
                                  ]),
                                ),
                                Tooltip(
                                  message: 'Изменить описание',
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.black12),
                                      shape: MaterialStateProperty.all(
                                        const CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: () {
                                      showFileDescriptionDialog(element);
                                    },
                                    child: const Icon(Icons.edit),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Удалить файл',
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.black12),
                                      shape: MaterialStateProperty.all(
                                        const CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: () {
                                      removeFile(element);
                                      setState(() {});
                                    },
                                    child: const Icon(Icons.delete),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> addSelectedQuestionFile() async {
    // var fileToAdd =
    //     FilePickerCross(Uint8List(10), path: '/home/user/Desktop/1.pdf');
    FilePickerCross fileToAdd = await FilePickerCross.importFromStorage(
            type: FileTypeCross.custom, fileExtension: 'pdf')
        .catchError((onError) {});

    if (_files.any((element) => element.fileName == fileToAdd.fileName)) {
      await Utility().showMessageOkDialog(context,
          title: 'Загрузка файла',
          message: TextSpan(
            text:
                'Вопрос уже содержит файл с именем ${fileToAdd.fileName}\nЗагрузка будет отменена.',
          ),
          okButtonText: 'Ок');
      return;
    }

    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text("Загрузка файла ${fileToAdd.fileName}")),
              ],
            ),
          );
        });

    String formattedDescription = fileToAdd.fileName.endsWith('.pdf')
        ? fileToAdd.fileName.substring(0, fileToAdd.fileName.length - 4)
        : fileToAdd.fileName;

    var questionFile = QuestionFile(
        fileName: fileToAdd.fileName,
        version: Uuid().v4(),
        description: formattedDescription,
        relativePath: _editedQuestion.folder,
        questionId: null);

    setState(() {
      _files.add(questionFile);
    });

    await File(fileToAdd.path).copy(
        '${File(_tecFile.text).parent.path}\\${_editedQuestion.folder}\\${path.basename(fileToAdd.path)}');

    Navigator.of(context).pop();

    await Utility().showMessageOkDialog(context,
        title: 'Загрузка файла',
        message: TextSpan(
          text: 'Загрузка файла ${fileToAdd.fileName} успешно завершена',
        ),
        okButtonText: 'Ок');
  }

  void removeFile(QuestionFile file) {
    _files.remove(file);
  }

  void onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    var newFolderName = Uuid().v4();

    var question = _questions[oldItemIndex];
    _questions.remove(question);

    var questionDirectory =
        Directory('${File(_tecFile.text).parent.path}\\${question.orderNum}');

    // set question directory temporary name
    if (questionDirectory.existsSync()) {
      questionDirectory
          .renameSync('${questionDirectory.parent.path}\\$newFolderName');
    }

    question.orderNum = newItemIndex;

    _questions.insert(newItemIndex, question);

    normalizeList(_questions, true);

    var tempQuestionDirectory =
        Directory('${questionDirectory.parent.path}\\$newFolderName');
    // set question directory name back
    if (tempQuestionDirectory.existsSync()) {
      tempQuestionDirectory
          .renameSync('${questionDirectory.parent.path}\\$newItemIndex');
    }
  }

  List<QuestionDescriptionItem> createQuestionDescription(
      QuestionGroupSettings group) {
    return <QuestionDescriptionItem>[
      QuestionDescriptionItem(
          caption: group.descriptionCaption1,
          showOnStoreboard: group.showCaption1OnStoreboard,
          showInReports: group.showCaption1InReports),
      QuestionDescriptionItem(
          caption: group.descriptionCaption2,
          showOnStoreboard: group.showCaption2OnStoreboard,
          showInReports: group.showCaption2InReports),
      QuestionDescriptionItem(
          caption: group.descriptionCaption3,
          showOnStoreboard: group.showCaption3OnStoreboard,
          showInReports: group.showCaption3InReports),
      QuestionDescriptionItem(
          caption: group.descriptionCaption4,
          showOnStoreboard: group.showCaption4OnStoreboard,
          showInReports: group.showCaption4InReports)
    ];
  }

  void showFileDescriptionDialog(QuestionFile file) async {
    TextEditingController _tecEditFileDescription = new TextEditingController();
    _tecEditFileDescription.text = file.description;
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Изменение описания файла'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecEditFileDescription,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Описание файла',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите описание файла';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: const Text('Ок'),
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                setState(() {
                  file.description = _tecEditFileDescription.text;
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getNewQuestionDescription() {
    if (_questionDescriptions.isEmpty) {
      return Container();
    }
    return SingleChildScrollView(
      controller: _questionsDescriptionsScrollController,
      child: Container(
        color: Colors.black12,
        height: 312,
        width: 710,
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _questionDescriptions.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black38),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              color: Colors.white,
                              child: TextField(
                                minLines: 2,
                                maxLines: 2,
                                controller: _tecDescriptionCaptions[index],
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Заголовок ${index + 1}',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Удалить блок описания',
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _questionDescriptions.removeAt(index);
                                _tecDescriptionCaptions.removeAt(index);
                                _tecDescriptionTexts.removeAt(index);
                              });
                            },
                            child: const Icon(Icons.clear),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        color: Colors.white,
                        child: TextField(
                          controller: _tecDescriptionTexts[index],
                          minLines: 4,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Текст ${index + 1}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  void addQuestionDescription() {
    setState(() {
      _questionDescriptions.add(QuestionDescriptionItem(
          showInReports: false, showOnStoreboard: false));
      _tecDescriptionCaptions.add(TextEditingController());
      _tecDescriptionTexts.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    _tecFile.dispose();

    super.dispose();
  }
}
