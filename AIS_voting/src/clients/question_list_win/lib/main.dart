import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ais_utils/ais_utils.dart';
import 'package:ais_utils/dialogs.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'utils/agenda_list_util.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('АИС Повестка');

    Future.delayed(Duration(milliseconds: 100), () async {
      await windowManager.maximize();
    });
  });

  await WindowsSingleInstance.ensureSingleInstance(args, "agenda",
      onSecondWindow: (args) {});
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final _tecDirectory = TextEditingController();

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

  bool _agendaCheckResult = true;

  late TabController _tabController;

  @override
  void initState() {
    AgendaListUtil.init(context, setState);

    _tabController = TabController(vsync: this, length: 2);

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
              message: 'Архивировать повестку',
              child: TextButton(
                onPressed: () async {
                  await selectArchiveFolder();
                },
                child: const Icon(Icons.archive),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) async {
            if (index == 1) {
              await saveAndCheck();
            }

            _tabController.index = index;
            setState(() {});
          },
          tabs: [
            const Tab(
              icon: Icon(Icons.list),
              text: 'Повестка',
            ),
            Tab(
              icon: Icon(
                Icons.save,
                color: _agendaCheckResult == true ? Colors.white : Colors.red,
              ),
              child: Text(
                'Сохранить',
                style: TextStyle(
                    color:
                        _agendaCheckResult == true ? Colors.white : Colors.red),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          getAgendaTab(),
          getCheckTab(),
        ],
      ),
    );
  }

  Widget getAgendaTab() {
    return Tab(
      child: Column(
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
                  controller: _tecDirectory,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'Директория повестки заседания',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Выберите директорию повестки';
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
                  await selectFolder();
                },
                child: const Text('Директория повестки'),
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

  Widget getCheckTab() {
    Timer(const Duration(milliseconds: 500), () {
      if (_scrollController.positions.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 10),
          curve: Curves.fastOutSlowIn,
        );
      }
    });

    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: _checkDialogItems.isEmpty
                  ? const Center(
                      child: Text('Нет данных'),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: _checkDialogItems.length,
                        itemBuilder: (buildContext, index) {
                          if (_checkDialogItems.length <= index) {
                            return Container();
                          }
                          return _checkDialogItems[index];
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showSpinner(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                const CircularProgressIndicator(),
                Container(
                  width: 20,
                ),
                Text(
                  message,
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> selectArchiveFolder() async {
    final file = DirectoryPicker()..title = 'Архивировать повестку в папку';

    final result = file.getDirectory();
    if (result == null) {
      return;
    }

    showSpinner('Сохранение');

    await Future.delayed(const Duration(seconds: 1));

    var copyFrom = Directory(_tecDirectory.text);
    var copyTo = Directory(result.path);
    var newAgendaDirectory = Directory(
        '${copyTo.path}\\${DateFormat('dd.MM.yyyy-HH.mm.ss').format(DateTime.now())}');

    try {
      if (!await copyFrom.exists()) {
        await Utility().showMessageOkDialog(context,
            title: 'Архивация повестки',
            message: TextSpan(
              text:
                  'В ходе архивации повестки возникла ошибка: директория повестки ${copyFrom.path} не существует. Копирование отменено.',
            ),
            okButtonText: 'Ок');

        Navigator.of(context).pop();
        return;
      }
      if (!await copyTo.exists()) {
        await Utility().showMessageOkDialog(context,
            title: 'Архивация повестки',
            message: TextSpan(
              text:
                  'В ходе архивации повестки возникла ошибка: директория назначения ${copyTo.path} не существует. Копирование отменено.',
            ),
            okButtonText: 'Ок');

        Navigator.of(context).pop();
        return;
      } else {
        if (path.isWithin(copyFrom.path, newAgendaDirectory.path)) {
          await Utility().showMessageOkDialog(context,
              title: 'Архивация повестки',
              message: TextSpan(
                text:
                    'В ходе архивации повестки возникла ошибка: директория назначения ${newAgendaDirectory.path} является дочерней директорией повестки ${copyFrom.path}. Копирование отменено.',
              ),
              okButtonText: 'Ок');
        } else {
          newAgendaDirectory.createSync();

          copyDirectorySync(copyFrom, newAgendaDirectory);
        }

        Navigator.of(context).pop();
      }
    } catch (error) {
      await Utility().showMessageOkDialog(context,
          title: 'Архивация повестки',
          message: TextSpan(
            text:
                'В ходе архивации повестки из директории:${copyFrom.path} в директорию:${newAgendaDirectory.path} возникла ошибка: $error',
          ),
          okButtonText: 'Ок');
    }
  }

  void copyDirectorySync(Directory source, Directory destination) {
    /// create destination folder if not exist
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    /// get all files from source (recursive: false is important here)
    source.listSync(recursive: false).forEach((entity) {
      final newPath = destination.path +
          Platform.pathSeparator +
          path.basename(entity.path);
      if (entity is File) {
        entity.copySync(newPath);
      } else if (entity is Directory) {
        copyDirectorySync(entity, Directory(newPath));
      }
    });
  }

  Future<void> selectFolder() async {
    try {
      final file = DirectoryPicker()..title = 'Выберите директорию повестки';

      final result = file.getDirectory();
      if (result == null) {
        return;
      }

      showSpinner("Загрузка повестки");

      await Future.delayed(const Duration(seconds: 1));

      _editedQuestion = Question();
      _tecDirectory.text = result.path;

      _agendaCheckResult = await checkAgenda(true, true);

      if (!_agendaCheckResult) {
        AgendaListUtil.questions.clear();
        AgendaListUtil.isLoaded = false;
        _tabController.index = 1;
      } else {
        AgendaListUtil.loadQuestions(getAgendaFilePath());
      }

      Navigator.of(context).pop();
    } catch (error) {
      await Utility().showMessageOkDialog(context,
          title: 'Загрузка повестки',
          message: TextSpan(
            text:
                'В ходе загрузки повестки ${_tecDirectory.text} возникла ошибка: $error',
          ),
          okButtonText: 'Ок');
    }

    setState(() {});
  }

  String getAgendaFilePath() {
    String result = '';
    if (Directory(_tecDirectory.text).existsSync() &&
        Directory(_tecDirectory.text)
            .listSync()
            .any((element) => path.extension(element.path) == '.txt')) {
      result = Directory(_tecDirectory.text)
          .listSync()
          .firstWhere((element) => path.extension(element.path) == '.txt')
          .path;
    }

    return result;
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
                          if (!await saveAndCheck()) {
                            return;
                          }

                          await AgendaListUtil.onNewItemAdd(
                              AgendaListUtil.questions.length);

                          await saveAndCheck();
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
              onItemReorder: (var a, var b, var c, var d) async {
                if (!await saveAndCheck()) {
                  return;
                }
                AgendaListUtil.onItemReorder(a, b, c, d);
                if (_editedQuestion.id != null) {
                  editQuestion(_editedQuestion);
                }

                await saveAndCheck();
                setState(() {});
              },
              onListReorder: (var a, var b) {
                setState(() {});
              },
              onItemAdd: (DragAndDropItem newItem, int listIndex,
                  int itemIndex) async {
                if (!await saveAndCheck()) {
                  return;
                }

                itemIndex = itemIndex < 0 ? 0 : itemIndex;

                var newQuestion = await AgendaListUtil.onNewItemAdd(itemIndex);
                if (newQuestion != null) {
                  editQuestion(newQuestion);
                }

                await saveAndCheck();
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
                                            showHiddenSections: false,
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
                                                onPressed: () async {
                                                  if (!await saveAndCheck()) {
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

                                                  if (_editedQuestion.id ==
                                                      element.id) {
                                                    _editedQuestion =
                                                        Question();
                                                  }

                                                  AgendaListUtil.questions
                                                      .remove(element);

                                                  // remove question folder
                                                  var questionDirectory = Directory(
                                                      '${Directory(_tecDirectory.text).path}\\${element.folder}');

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

                                                  await saveAndCheck();
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
                                              if (!await saveAndCheck()) {
                                                return;
                                              }

                                              var newQuestion =
                                                  await AgendaListUtil
                                                      .onNewItemAdd(
                                                          element.orderNum + 1);

                                              if (newQuestion != null) {
                                                editQuestion(newQuestion);
                                              }

                                              await saveAndCheck();
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

  Future<bool> onSaveQuestion() async {
    var result = false;

    if (_editedQuestion.id == null) {
      result = true;
    } else if (_formKey.currentState != null &&
        !_formKey.currentState!.validate()) {
      result = false;
    } else {
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
          showOnStoreboard: !(i == 1 || i == 3),
          showInReports: true,
        ));
      }

      //_editedQuestion.orderNum = int.parse(_tecQuestionPosition.text);

      result = true;
    }

    return result;
  }

  Future<bool> saveAndCheck() async {
    var result = false;

    if (!AgendaListUtil.isLoaded) {
      return result;
    }

    if (!await onSaveQuestion()) {
      addDialogResultItem(
          'При сохранении редактируемого вопроса повестки возникли ошибки',
          false);

      setState(() {});
      return result;
    }

    _agendaCheckResult = await checkAgenda(false, false);

    if (!_agendaCheckResult) {
      addDialogResultItem(
          'При проверке повестки возникли ошибки, сохранение отменено', false);
      setState(() {});
      return false;
    }

    if (!await AgendaListUtil.saveQuestionList()) {
      addDialogResultItem('При сохранении повестки возникли ошибки', false);
      setState(() {});
      return false;
    }

    addDialogResultItem('Файл повестки успешно сохранен', true);
    setState(() {});
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
      onItemReorder: (var a, var b, var c, var d) async {
        AgendaListUtil.onFilesReorder(_editedQuestion, a, b, c, d);
        await saveAndCheck();
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
                              child: Text(element.fileName),
                            ),
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
    final fileToAdd = OpenFilePicker()
      ..defaultFilterIndex = 0
      ..defaultExtension = 'pdf'
      ..title = 'Загрузка файла';

    final result = fileToAdd.getFile();
    if (result == null) {
      return;
    }

    showSpinner("Загрузка файла ${path.basename(result.path)}");

    await Future.delayed(const Duration(seconds: 1));

    String formattedDescription = path.basenameWithoutExtension(result.path);

    String newFileName =
        "Вопрос${_editedQuestion.orderNum.toString().padLeft(2, '0')}_файл${(_editedQuestion.files.length + 1).toString().padLeft(2, '0')}.pdf";
    var questionFile = QuestionFile(
        fileName: newFileName,
        realPath:
            '${Directory(_tecDirectory.text).path}\\${_editedQuestion.folder}',
        version: Uuid().v4(),
        description: formattedDescription,
        relativePath: _editedQuestion.folder,
        questionId: null);

    setState(() {
      _editedQuestion.files.add(questionFile);
    });

    await File(result.path).copy(
        '${Directory(_tecDirectory.text).path}\\${_editedQuestion.folder}\\$newFileName');

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
    } catch (error) {
      Utility().showMessageOkDialog(context,
          title: 'Удаление файла',
          message: TextSpan(
            text:
                'В ходе удаления файла ${file.fileName} возникла ошибка: $error',
          ),
          okButtonText: 'Ок');
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

                AgendaListUtil.normalizeFiles(_editedQuestion, false);

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
              if (index == 1 || index == 3) {
                return Container();
              }
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

  Future<bool> checkAgenda(bool isCheckFile, bool isCreateNew) async {
    _checkDialogItems.clear();

    // Проверяем доступ к директории повестки
    final agendaDirectory = Directory(_tecDirectory.text);
    if (!agendaDirectory.existsSync()) {
      addDialogResultItem('Отсутствует доступ к директории повестки', false);
      return false;
    } else {
      addDialogResultItem('Директория повестки доступна для загрузки', true);
    }

    // Проверяем доступ к файлу повестки
    File? agendaFile;
    if (getAgendaFilePath().isNotEmpty) {
      agendaFile = File(getAgendaFilePath());
    }

    if (isCreateNew && agendaDirectory.listSync().isEmpty) {
      var noButtonPressed = false;

      await Utility().showYesNoDialog(
        context,
        title: "Директория пуста",
        message: TextSpan(text: 'Создать повестку в этой директории?'),
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
        addDialogResultItem('Отсутствует доступ к файлу повестки', false);
        return false;
      }

      copyDirectorySync(
          Directory(
              '${Directory.current.path}\\data\\flutter_assets\\assets\\data\\povestka_example'),
          Directory(_tecDirectory.text));

      if (getAgendaFilePath().isNotEmpty) {
        agendaFile = File(getAgendaFilePath());
      }
    }

    if (agendaFile == null || !agendaFile.existsSync()) {
      addDialogResultItem('Отсутствует доступ к файлу повестки', false);
      return false;
    } else {
      addDialogResultItem('Файл повестки доступен для загрузки', true);
    }

    if (agendaFile.path.endsWith('.${AgendaListUtil.fileExtension}')) {
      addDialogResultItem('Проверка формата файла повестки', true);
    } else {
      addDialogResultItem(
          'Файл повестки должен иметь текстовый формат .${AgendaListUtil.fileExtension}',
          false);
      return false;
    }

    var isStructureCheckSuccess = false;

    isStructureCheckSuccess = isCheckFile
        ? await checkAgendaFileStructure(agendaFile.path)
        : await checkAgendaListStructure(agendaFile.path);

    if (isStructureCheckSuccess) {
      addDialogResultItem('Проверка повестки завершилась успешно', true);
    } else {
      addDialogResultItem('В ходе проверки повестки возникли ошибки', false);
    }

    return isStructureCheckSuccess;
  }

  Future<bool> checkAgendaFileStructure(String agendaFilePath) async {
    // Получаем список папок повестки
    var contents = File(agendaFilePath).parent.listSync();
    var documentFolders = <Directory>[];
    for (var fileOrDir in contents) {
      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }
    var usedDocumentFolders = <Directory>[];

    // read file content
    var agenFileBytes = await File(agendaFilePath).readAsBytes();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());
    agendaFileContent = agendaFileContent.replaceAll('\r\n', '\n');

    // check agenda file
    if (agendaFileContent.isEmpty) {
      addDialogResultItem('Файл повестки пуст', true);
      return true;
    }

    List<String> questions = agendaFileContent.split('\n');
    questions.removeWhere((element) => element.trim().isEmpty);
    if (questions.isNotEmpty) {
      questions.removeAt(0);
    }

    if (questions.isEmpty && documentFolders.isEmpty) {
      addDialogResultItem('Список вопросов повестки пуст', true);
      return true;
    }

    // Проверяем вопросы
    var isStructureCheckSuccess = true;

    if (questions.length != documentFolders.length) {
      addDialogResultItem(
          'Количество вопросов[${questions.length}] и директорий[${documentFolders.length}] с документами не совпадают',
          false);
      isStructureCheckSuccess = false;
    } else {
      addDialogResultItem('Количество вопросов и директорий совпадают', true);
    }

    var additionalQuestionCount = 0;
    var errorCount = 0;
    for (int i = 0; i < questions.length; i++) {
      // check question format
      RegExp regExp = RegExp(
          r'("[^"]*"),("?[^"]+"?),("[^"]*"),(".*"),(".*"),(".*"),(".*")');

      if (!regExp.hasMatch(questions[i])) {
        isStructureCheckSuccess = false;

        addDialogResultItem(
            'Описание вопроса на строке ${i + 2} не распознано', false);
        errorCount++;
        continue;
      }

      var isQuestionCorrect = true;
      var isQuestionAdditional = false;
      // check question number sequence
      var questionNumber =
          regExp.firstMatch(questions[i])?.group(2)?.replaceAll('"', '') ?? '';

      if (questionNumber.contains(' д')) {
        isQuestionAdditional = true;
        additionalQuestionCount++;
      }

      var expectedQuestionNumber = isQuestionAdditional
          ? '$additionalQuestionCount д'
          : (i - additionalQuestionCount - errorCount).toString();

      if (questionNumber != expectedQuestionNumber) {
        isQuestionCorrect = false;
        isStructureCheckSuccess = false;

        addDialogResultItem(
            'Номер вопроса $questionNumber не соответвует ожидаемому $expectedQuestionNumber',
            false);
      }

      // check question document folder exists
      bool isDocumentFolderExists = documentFolders
          .any((element) => path.basename(element.path) == questionNumber);

      if (!isDocumentFolderExists) {
        isQuestionCorrect = false;
        isStructureCheckSuccess = false;

        addDialogResultItem(
            'Не найдена директория для вопроса $questionNumber', false);
      } else {
        var documentFolder = documentFolders.firstWhere(
            (element) => path.basename(element.path) == questionNumber);

        usedDocumentFolders.add(documentFolder);

        var descriptionFile = File(
            '${File(agendaFilePath).parent.path}\\$questionNumber\\Description.txt');

        if (!await descriptionFile.exists() && questions[i].isNotEmpty) {
          isQuestionCorrect = false;
          isStructureCheckSuccess = false;

          addDialogResultItem(
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

          addDialogResultItem(
              'Количество документов[${(documentFolderContents.length - 1)}] и их описаний[${descriptions.length}] не совпадают ${documentFolder.path}',
              false);
          continue;
        }

        var j = 0;
        for (var fileOrDir in documentFolderContents) {
          var fullPath = fileOrDir.path;

          if (fileOrDir is File &&
              path.basename(fileOrDir.path) == 'Description.txt') {
            continue;
          }

          if (fileOrDir is Directory ||
              path.extension(fileOrDir.path) != '.pdf') {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            addDialogResultItem('Не поддерживается формат $fullPath', false);
          } else {
            realFileNames.add(path.basename(fileOrDir.path));
          }

          String expectedFileName =
              AgendaListUtil.getFileName(questionNumber, j + 1);

          if (realFileNames.last != expectedFileName) {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            addDialogResultItem(
                'Имя файла: ${realFileNames.last} не соответвует ожидаемому: $expectedFileName',
                false);
          }

          j++;
        }

        if (descriptions.length != realFileNames.length) {
          isQuestionCorrect = false;
          isStructureCheckSuccess = false;

          addDialogResultItem(
              'Несовпадает количество файлов в описании вопроса и директории $questionNumber',
              false);
        }

        for (var fileDescription in descriptions.keys) {
          if (!realFileNames.contains(fileDescription)) {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            addDialogResultItem(
                'Не найден файл $questionNumber\\$fileDescription', false);
          } else {
            addDialogResultItem(
                'Проверка файла $questionNumber\\$fileDescription ', true);
          }
        }
      }

      addDialogResultItem(
          'Проверка вопроса $questionNumber', isQuestionCorrect);
    }

    for (int i = 0; i < documentFolders.length; i++) {
      if (!usedDocumentFolders.contains(documentFolders[i])) {
        addDialogResultItem(
            'Директория "${path.basename(documentFolders[i].path)}" не используется',
            false);
      }
    }

    return isStructureCheckSuccess;
  }

  Future<bool> checkAgendaListStructure(String agendaFilePath) async {
    // Получаем список папок повестки
    var contents = File(agendaFilePath).parent.listSync();
    var documentFolders = <Directory>[];
    for (var fileOrDir in contents) {
      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }
    var usedDocumentFolders = <Directory>[];

    var isStructureCheckSuccess = true;
    if (AgendaListUtil.questions.length != documentFolders.length) {
      addDialogResultItem(
          'Количество вопросов[${AgendaListUtil.questions.length}] и директорий[${documentFolders.length}] с документами не совпадают',
          false);
      isStructureCheckSuccess = false;
    } else {
      addDialogResultItem('Количество вопросов и директорий совпадают', true);
    }

    // Проверяем вопросы
    for (int i = 0; i < AgendaListUtil.questions.length; i++) {
      var isQuestionCorrect = true;

      var questionNumber =
          int.parse(AgendaListUtil.questions[i].folder.replaceAll(' д', ''));
      var expectedQuestionNumber = AgendaListUtil.getQuestionNumber(i);
      if (questionNumber != expectedQuestionNumber) {
        isQuestionCorrect = false;
        isStructureCheckSuccess = false;

        addDialogResultItem(
            'Номер вопроса $questionNumber не соответвует ожидаемому $expectedQuestionNumber',
            false);
      }

      bool isDocumentFolderExists = documentFolders.any((element) =>
          path.basename(element.path) == AgendaListUtil.questions[i].folder);

      if (!isDocumentFolderExists) {
        isQuestionCorrect = false;
        isStructureCheckSuccess = false;

        addDialogResultItem(
            'Не найдена директория для вопроса ${AgendaListUtil.questions[i].folder}',
            false);
      } else {
        var documentFolder = documentFolders.firstWhere((element) =>
            path.basename(element.path) == AgendaListUtil.questions[i].folder);

        usedDocumentFolders.add(documentFolder);

        var descriptionFile = File(
            '${File(agendaFilePath).parent.path}\\${AgendaListUtil.questions[i].folder}\\Description.txt');

        if (!await descriptionFile.exists()) {
          isQuestionCorrect = false;
          isStructureCheckSuccess = false;

          addDialogResultItem(
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

          addDialogResultItem(
              'Количество документов[${(documentFolderContents.length - 1)}] и их описаний[${descriptions.length}] не совпадают ${documentFolder.path}',
              false);
          continue;
        }

        var j = 0;
        for (var fileOrDir in documentFolderContents) {
          var fullPath = fileOrDir.path;

          if (fileOrDir is File &&
              path.basename(fileOrDir.path) == 'Description.txt') {
            continue;
          }

          if (fileOrDir is Directory ||
              path.extension(fileOrDir.path) != '.pdf') {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            addDialogResultItem('Не поддерживается формат $fullPath', false);
          } else {
            realFileNames.add(path.basename(fileOrDir.path));
          }

          String expectedFileName = AgendaListUtil.getFileName(
              AgendaListUtil.questions[i].folder, j + 1);

          if (realFileNames.last != expectedFileName) {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            addDialogResultItem(
                'Имя файла: ${realFileNames.last} не соответвует ожидаемому: $expectedFileName',
                false);
          }

          j++;
        }

        if (descriptions.length != realFileNames.length) {
          isQuestionCorrect = false;
          isStructureCheckSuccess = false;

          addDialogResultItem(
              'Несовпадает количество файлов в описании вопроса и директории ${AgendaListUtil.questions[i].folder}',
              false);
        }

        for (var fileDescription in descriptions.keys) {
          if (!realFileNames.contains(fileDescription)) {
            isQuestionCorrect = false;
            isStructureCheckSuccess = false;

            addDialogResultItem(
                'Не найден файл ${AgendaListUtil.questions[i].folder}\\$fileDescription',
                false);
          } else {
            addDialogResultItem(
                'Проверка файла ${AgendaListUtil.questions[i].folder}\\$fileDescription ',
                true);
          }
        }
      }

      addDialogResultItem(
          'Проверка вопроса ${AgendaListUtil.questions[i].folder}',
          isQuestionCorrect);
    }

    for (int i = 0; i < documentFolders.length; i++) {
      if (!usedDocumentFolders.contains(documentFolders[i])) {
        isStructureCheckSuccess = false;
        addDialogResultItem(
            'Директория "${path.basename(documentFolders[i].path)}" не используется',
            false);
      }
    }

    return isStructureCheckSuccess;
  }

  void addDialogResultItem(String itemText, bool isOk) {
    _checkDialogItems.add(getResultDialogItem(itemText, isOk));
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
    _tecDirectory.dispose();

    _scrollController.dispose();
    _questionsScrollController.dispose();
    _addQuestionScrollContoller.dispose();
    _questionsDescriptionsScrollController.dispose();

    super.dispose();
  }
}
