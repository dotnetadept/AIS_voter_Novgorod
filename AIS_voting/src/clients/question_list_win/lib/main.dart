import 'dart:convert';
import 'dart:io';

import 'package:ais_utils/ais_utils.dart';
import 'package:ais_utils/dialogs.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:ais_model/ais_model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'utils/agenda_list_util.dart';

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
        scrollbarTheme: ScrollbarThemeData(
          thickness: MaterialStateProperty.all(12),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            overlayColor: MaterialStateProperty.all(Colors.blueAccent),
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10.0),
        ),
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
  final _tecFile = TextEditingController();

  List<Widget> _checkDialogItems = <Widget>[];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tecQuestionName = TextEditingController();
  final TextEditingController _tecQuestionPosition = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final ScrollController _questionsScrollController = ScrollController();
  final ScrollController _addQuestionScrollContoller = ScrollController();
  final ScrollController _questionsDescriptionsScrollController =
      ScrollController();

  Question _editedQuestion = Question();

  List<TextEditingController> _tecDescriptionCaptions =
      <TextEditingController>[];
  List<TextEditingController> _tecDescriptionTexts = <TextEditingController>[];
  List<bool> _tecDescriptionShowTexts = <bool>[];

  late Function(VoidCallback fn) _setStateForDialog = setState;
  bool _isCheckEnded = false;

  @override
  void initState() {
    AgendaListUtil.init(context, setState);

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
              message: 'Сохранить список вопросов',
              child: TextButton(
                onPressed: () {
                  if (!onSaveQuestion()) {
                    return;
                  }

                  try {
                    AgendaListUtil.saveQuestionList().then((value) async {
                      _isCheckEnded = false;
                      await clearDialogItems();
                      await processCheck().then((value) {
                        _isCheckEnded = true;
                        _setStateForDialog(() {});
                      }).catchError((e) {
                        _isCheckEnded = true;
                        _setStateForDialog(() {});
                      });
                    });
                  } catch (e) {
                    Utility().showMessageOkDialog(context,
                        title: 'Сохранение повестки',
                        message: TextSpan(
                          text:
                              'В ходе сохранение повестки возникла ошибка: {$e}',
                        ),
                        okButtonText: 'Ок');
                  }
                },
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 10,
          ),
          Row(
            children: [
              Container(
                width: 10,
              ),
              Expanded(
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
              Container(
                width: 10,
              ),
              TextButton(
                onPressed: () async {
                  await selectFile();
                },
                child: const Text('Выберите файл повестки'),
              ),
              Container(
                width: 10,
              ),
            ],
          ),
          Container(
            height: 10,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: getQuestionsTable(),
                ),
                Expanded(
                  child: getQuestionSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectFile() async {
    try {
      await FilePickerCross.importFromStorage(
              type: FileTypeCross.custom,
              fileExtension: AgendaListUtil.fileExtension)
          .then((filePicker) {
        _tecFile.text = filePicker.path;
        AgendaListUtil.loadCsvQuestions(filePicker.path);
      }).catchError((onError) {});
    } catch (error) {}
  }

  Widget getQuestionsTable() {
    return Column(
      children: [
        Container(
          color: Colors.lightBlue,
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
                    message: 'Добавить вопрос в список вопросов',
                    child: Center(
                      child: TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black),
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          shape: MaterialStateProperty.all(
                            const CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        onPressed: () async {
                          if (!onSaveQuestion()) {
                            return;
                          }

                          await AgendaListUtil.onNewItemAdd(
                              AgendaListUtil.questions.length);
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
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
                AgendaListUtil.onItemReorder(a, b, c, d);
                setState(() {});
              },
              onListReorder: (var a, var b) {
                setState(() {});
              },
              onItemAdd: (DragAndDropItem newItem, int listIndex,
                  int itemIndex) async {
                if (!onSaveQuestion()) {
                  return;
                }

                itemIndex = itemIndex < 0 ? 0 : itemIndex;

                var newQuestion = await AgendaListUtil.onNewItemAdd(itemIndex);
                if (newQuestion != null) {
                  editQuestion(newQuestion);
                }
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
                  children: AgendaListUtil.questions
                      .map(
                        ((element) => DragAndDropItem(
                              child: Container(
                                color: element == _editedQuestion
                                    ? Colors.blue.withOpacity(0.4)
                                    : Colors.white,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 50),
                                      child: Text(
                                        (element.orderNum ?? '  ').toString(),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
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
                                          child: Text(
                                            element.name ==
                                                    AgendaListUtil
                                                        .settings
                                                        .firstQuestion
                                                        .defaultGroupName
                                                ? element.toString()
                                                : '${element.id ?? ''} $element',
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
                                          alignment: Alignment.centerLeft,
                                          height: 55,
                                          child: AgendaUtil
                                              .getQuestionDescriptionText(
                                            element,
                                            14,
                                            isAutoSize: true,
                                            textAlign: TextAlign.left,
                                            showHiddenSections: true,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
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
                                                  shape:
                                                      MaterialStateProperty.all(
                                                    const CircleBorder(
                                                        side: BorderSide(
                                                            color: Colors
                                                                .transparent)),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (!onSaveQuestion()) {
                                                    return;
                                                  }

                                                  editQuestion(element);
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
                                                  shape:
                                                      MaterialStateProperty.all(
                                                    const CircleBorder(
                                                        side: BorderSide(
                                                            color: Colors
                                                                .transparent)),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  var noButtonPressed = false;
                                                  var title = 'Удалить вопрос';

                                                  await Utility()
                                                      .showYesNoDialog(
                                                    context,
                                                    title: title,
                                                    message: TextSpan(
                                                        text:
                                                            'Вы уверены, что хотите ${title.toLowerCase()}?'),
                                                    yesButtonText: 'Да',
                                                    yesCallBack: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    noButtonText: 'Нет',
                                                    noCallBack: () {
                                                      noButtonPressed = true;
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  );

                                                  if (noButtonPressed) {
                                                    return;
                                                  }

                                                  AgendaListUtil.questions
                                                      .remove(element);

                                                  // remove question folder
                                                  var questionDirectory = Directory(
                                                      '${File(_tecFile.text).parent.path}\\${element.folder}');

                                                  if (questionDirectory
                                                      .existsSync()) {
                                                    questionDirectory
                                                        .deleteSync(
                                                            recursive: true);
                                                  }

                                                  setState(() {
                                                    AgendaListUtil
                                                        .normalizeList(false);
                                                  });
                                                },
                                                child: const Icon(Icons.delete,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Tooltip(
                                          message: 'Добавить следующий вопрос',
                                          child: TextButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(15)),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black),
                                              overlayColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black12),
                                              shape: MaterialStateProperty.all(
                                                const CircleBorder(
                                                    side: BorderSide(
                                                        color: Colors.black)),
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (!onSaveQuestion()) {
                                                return;
                                              }

                                              var newQuestion =
                                                  await AgendaListUtil
                                                      .onNewItemAdd(
                                                          element.orderNum + 1);

                                              if (newQuestion != null) {
                                                editQuestion(newQuestion);
                                              }
                                            },
                                            child: const Icon(Icons.add),
                                          ),
                                        ),
                                      ],
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

  void editQuestion(Question question) {
    _editedQuestion = question;
    _tecQuestionName.text = question.toString();
    _tecQuestionPosition.text = question.orderNum.toString();

    _tecDescriptionCaptions = <TextEditingController>[];
    _tecDescriptionTexts = <TextEditingController>[];
    _tecDescriptionShowTexts = <bool>[];

    for (var description in question.descriptions) {
      _tecDescriptionCaptions
          .add(TextEditingController(text: description.caption));
      _tecDescriptionTexts.add(TextEditingController(text: description.text));
      _tecDescriptionShowTexts.add((description.text ?? '').isNotEmpty);
    }

    setState(() {});
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
    for (int i = 0; i < _tecDescriptionCaptions.length; i++) {
      _editedQuestion.descriptions.add(QuestionDescriptionItem(
        caption: _tecDescriptionCaptions[i].text,
        text: _tecDescriptionTexts[i]
            .text
            .replaceAll('\r\n', ' ')
            .replaceAll('\r', ' ')
            .replaceAll('\n', ' '),
        showOnStoreboard: true,
        showInReports: true,
      ));
    }

    _editedQuestion.orderNum = int.parse(_tecQuestionPosition.text);

    return true;
  }

  Widget getQuestionSection() {
    if (_editedQuestion.id == null) {
      return const Align(
        alignment: Alignment.center,
        child: Text('Выберите вопрос'),
      );
    }

    return Form(
      key: _formKey,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _addQuestionScrollContoller,
        child: SingleChildScrollView(
          controller: _addQuestionScrollContoller,
          child: Column(
            children: <Widget>[
              Container(
                height: 60,
                padding: const EdgeInsets.fromLTRB(25, 7, 15, 7),
                color: Colors.lightBlue,
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
                  ],
                ),
              ),
              Container(
                height: 10,
              ),
              TextFormField(
                controller: _tecQuestionName,
                readOnly: true,
                decoration: const InputDecoration(
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
                  labelText: 'Порядковый номер',
                ),
                controller: _tecQuestionPosition,
              ),
              Container(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(25, 5, 15, 5),
                height: 55.0,
                color: Colors.lightBlue,
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
                  ],
                ),
              ),
              getNewQuestionDescription(),
              Container(
                padding: const EdgeInsets.fromLTRB(25, 5, 15, 5),
                color: Colors.lightBlue,
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
                                  side: BorderSide(color: Colors.transparent)),
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
    );
  }

  Widget getFilesTable() {
    if (_editedQuestion.files.isEmpty) {
      return Container();
    }

    return DragAndDropLists(
      disableScrolling: true,
      lastListTargetSize: 0.0,
      onItemReorder: (var a, var b, var c, var d) {
        AgendaListUtil.onFilesReorder(_editedQuestion, a, b, c, d);
        setState(() {});
      },
      onListReorder: (var a, var b) {},
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
          children: _editedQuestion.files
              .map(
                ((element) => DragAndDropItem(
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              height: 55,
                              child: Text(element.description),
                            ),
                          ),
                          Container(
                            width: 10,
                          ),
                          Tooltip(
                            message: 'Изменить описание',
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                overlayColor:
                                    MaterialStateProperty.all(Colors.black12),
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
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                overlayColor:
                                    MaterialStateProperty.all(Colors.black12),
                                shape: MaterialStateProperty.all(
                                  const CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () async {
                                var noButtonPressed = false;
                                var title = 'Удалить файл';

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

                                removeFile(element);
                              },
                              child:
                                  const Icon(Icons.delete, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    )),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> addSelectedQuestionFile() async {
    FilePickerCross fileToAdd = await FilePickerCross.importFromStorage(
            type: FileTypeCross.custom, fileExtension: 'pdf')
        .catchError((onError) {});

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

    String newFileName =
        "Вопрос${_editedQuestion.orderNum.toString().padLeft(2, '0')}_файл${(_editedQuestion.files.length + 1).toString().padLeft(2, '0')}.pdf";
    var questionFile = QuestionFile(
        fileName: newFileName,
        realPath:
            '${File(_tecFile.text).parent.path}\\${_editedQuestion.folder}',
        version: Uuid().v4(),
        description: formattedDescription,
        relativePath: _editedQuestion.folder,
        questionId: null);

    setState(() {
      _editedQuestion.files.add(questionFile);
    });

    await File(fileToAdd.path).copy(
        '${File(_tecFile.text).parent.path}\\${_editedQuestion.folder}\\$newFileName');

    AgendaListUtil.normalizeFiles(_editedQuestion, true);

    Navigator.of(context).pop();

    await Utility().showMessageOkDialog(context,
        title: 'Загрузка файла',
        message: TextSpan(
          text: 'Загрузка файла ${fileToAdd.fileName} успешно завершена',
        ),
        okButtonText: 'Ок');
  }

  void removeFile(QuestionFile file) {
    _editedQuestion.files.remove(file);
    try {
      File('${file.realPath}\\${file.fileName}').deleteSync();
    } catch (exc) {
      print('error:' + exc.toString());
    }

    AgendaListUtil.normalizeFiles(_editedQuestion, false);

    setState(() {});
  }

  void showFileDescriptionDialog(QuestionFile file) async {
    TextEditingController tecEditFileDescription = TextEditingController();
    tecEditFileDescription.text = file.description;
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
                    controller: tecEditFileDescription,
                    decoration: const InputDecoration(
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
                  file.description = tecEditFileDescription.text;
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
    if (_editedQuestion.descriptions.isEmpty) {
      return Container();
    }
    return SingleChildScrollView(
      controller: _questionsDescriptionsScrollController,
      child: Container(
        color: Colors.black12,
        height: 400,
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _editedQuestion.descriptions.length,
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
                            color: Colors.white,
                            child: TextField(
                              controller: _tecDescriptionCaptions[index],
                              enabled: false,
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                labelText: 'Заголовок ${index + 1}',
                              ),
                            ),
                          ),
                        ),
                        _tecDescriptionShowTexts[index]
                            ? Container()
                            : Tooltip(
                                message: 'Развернуть блок описания',
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _tecDescriptionShowTexts[index] = true;
                                    });
                                  },
                                  child: const Icon(Icons.arrow_downward),
                                ),
                              ),
                      ],
                    ),
                    !_tecDescriptionShowTexts[index]
                        ? Container()
                        : Container(
                            padding: const EdgeInsets.all(5),
                            color: Colors.white,
                            child: TextField(
                              controller: _tecDescriptionTexts[index],
                              minLines: 4,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Текст ${index + 1}',
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

  Future<void> processCheck() async {
    _checkDialogItems = <Widget>[];
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setStateForDialog) {
            _setStateForDialog = setStateForDialog;
            return Dialog(
              elevation: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      !_isCheckEnded
                          ? const CircularProgressIndicator()
                          : Container(),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Text(
                          "Проверка",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  !_isCheckEnded ? Colors.grey : Colors.blue),
                          onPressed: !_isCheckEnded
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _setStateForDialog = setState;
                                },
                          child: const Text('Ок'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });

    bool agendaCheckResult;
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
    // Проверяем доступ к файлу загрузки
    final agendaFile = File(_tecFile.text);
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
      if (fileOrDir is File && fileOrDir.path.endsWith('.txt')) {
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

    isStructureCheckSuccess =
        await checkTxtStructure(agendaFilePath, documentFolders);

    return isStructureCheckSuccess;
  }

  Future<void> clearDialogItems() async {
    _checkDialogItems.clear();

    _setStateForDialog(() {});

    if (_scrollController.positions.isNotEmpty) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 10),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Future<bool> checkTxtStructure(
      String agendaFilePath, List<Directory> documentFolders) async {
    // read file content
    var agenFileBytes = await File(agendaFilePath).readAsBytes();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());
    agendaFileContent = agendaFileContent.replaceAll('\r\n', '\n');

    // check agenda file
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
          'Количество вопросов[${questions.length}] и директорий[${documentFolders.length}] с документами не совпадают',
          false);
      return false;
    } else {
      await addDialogResultItem(
          'Количество вопросов и директорий совпадают', true);
    }

    // Проверяем вопросы
    var isStructureCheckSuccess = true;
    for (int i = 0; i < questions.length; i++) {
      RegExp regExp = RegExp(
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
      var expectedQuestionNumber = AgendaListUtil.getQuestionNumber(i);
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
            '${File(agendaFilePath).parent.path}\\$questionNumberData\\Описание.txt');

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
                'Не найден файл $questionNumberData\\$fileDescription', false);
          } else {
            await addDialogResultItem(
                'Проверка файла $questionNumberData\\$fileDescription ', true);
          }
        }
      }

      await addDialogResultItem(
          'Проверка вопроса $questionNumberData', isQuestionCorrect);
    }

    return isStructureCheckSuccess;
  }

  Future<void> addDialogResultItem(String itemText, bool isOk) async {
    _checkDialogItems.add(getResultDialogItem(itemText, isOk));
    _setStateForDialog(() {});

    if (_scrollController.positions.isNotEmpty) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Widget getResultDialogItem(String text, bool isOk) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text:
                '${DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now())}\t',
          ),
          TextSpan(
            text: '$text\t',
          ),
          WidgetSpan(
            child: Icon(
              isOk ? Icons.done : Icons.close,
              color: isOk ? Colors.green : Colors.red,
            ),
          ),
          const TextSpan(
            text: '\n',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tecFile.dispose();

    _scrollController.dispose();
    _questionsScrollController.dispose();
    _addQuestionScrollContoller.dispose();
    _questionsDescriptionsScrollController.dispose();

    super.dispose();
  }
}
