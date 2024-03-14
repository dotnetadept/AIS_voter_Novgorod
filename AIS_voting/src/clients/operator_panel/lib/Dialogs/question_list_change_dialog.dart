import 'dart:async';
import 'dart:convert';

import 'package:ais_utils/ais_utils.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:provider/provider.dart';
import '../Providers/WebSocketConnection.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class QuestionListChangeDialog {
  ScrollController _questionsScrollController;
  ScrollController _addQuestionScrollContoller = ScrollController();
  ScrollController _questionsDescriptionsScrollController = ScrollController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _tecQuestionName = TextEditingController();
  TextEditingController _tecQuestionPosition = TextEditingController();

  List<TextEditingController> _tecDescriptionCaptions =
      <TextEditingController>[];
  List<TextEditingController> _tecDescriptionTexts = <TextEditingController>[];
  List<bool> _cbDescriptionShowOnStroreboard = <bool>[];
  List<bool> _cbDescriptionShowInReports = <bool>[];

  BuildContext _context;
  Settings _settings;
  Meeting _selectedMeeting;
  List<Question> _questions;
  List<Question> _questionsBase;
  Question _selectedQuestion;
  Question _editedQuestion;
  List<int> _accessRights;
  List<QuestionFile> _files;
  List<QuestionDescriptionItem> _questionDescriptions;
  String _filesFolder;
  WebSocketConnection _connection;
  List<User> _users;

  Question _newQuestionStub;

  QuestionListChangeDialog(this._context, this._selectedMeeting,
      this._selectedQuestion, this._settings, this._users) {
    _connection = Provider.of<WebSocketConnection>(_context, listen: false);

    _questions = copyQuestions(_selectedMeeting.agenda.questions);

    _questionsScrollController = ScrollController(
        initialScrollOffset: 87.0 * _questions.indexOf(_selectedQuestion));

    _accessRights = <int>[];
    _files = <QuestionFile>[];
    _filesFolder = Uuid().v4();

    _newQuestionStub = Question(
        name: 'Новый вопрос',
        descriptions: createQuestionDescription(
            _settings.questionListSettings.mainQuestion));
  }

  List<Question> copyQuestions(List<Question> questions) {
    List<Question> copiedQuestions = <Question>[];
    for (int i = 0; i < questions.length; i++) {
      copiedQuestions
          .add(Question.fromJson(jsonDecode(jsonEncode(questions[i]))));
    }
    return copiedQuestions;
  }

  Future<void> openDialog() async {
    return showDialog<void>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateForDialog) {
              return AlertDialog(
                title: Container(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                          color: Colors.lightBlue,
                          alignment: Alignment.center,
                          child: Text(
                            'Изменить список вопросов',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                content: Container(
                    height: 600,
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 0),
                      firstChild: getQuestionsTable(context, setStateForDialog),
                      secondChild:
                          getQuestionSection(context, setStateForDialog),
                      crossFadeState: _editedQuestion == null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                    )),
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
                              child: TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Отмена',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  if (_editedQuestion == null) {
                                    Navigator.of(context).pop();
                                  } else {
                                    setStateForDialog(() {
                                      _questions = _questionsBase;
                                      _editedQuestion = null;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                        child: TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _editedQuestion == null
                                    ? 'Сохранить список'
                                    : 'Сохранить вопрос',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            var result = false;
                            if (_editedQuestion == null) {
                              result = await onSaveQuestion(context);
                            } else {
                              result = onAddQuestion();
                            }

                            if (result) {
                              if (_editedQuestion == null) {
                                Navigator.of(context).pop();
                              } else {
                                setStateForDialog(() {
                                  _editedQuestion = null;
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        });
  }

  Widget getQuestionsTable(BuildContext context, Function setStateForDialog) {
    var newQuestionItem = DragAndDropItem(
      child: Column(children: [
        Container(
          height: 6,
        ),
        Container(
          width: 900,
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
          child: Text(
            _newQuestionStub.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 6,
        ),
        Container(
          width: 900,
          height: 55,
          margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: AgendaUtil.getQuestionDescriptionText(
            _newQuestionStub,
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
          width: 900,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 20,
              ),
              Text(
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
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.blue),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        data: newQuestionItem,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.blue),
                          child: Icon(
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
        Container(
          width: 900,
          height: 540,
          decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
          child: DragAndDropLists(
            scrollController: _questionsScrollController,
            onItemReorder: (var a, var b, var c, var d) {
              _onItemReorder(a, b, c, d);
              setStateForDialog(() {});
            },
            onListReorder: (var a, var b) {
              setStateForDialog(() {});
            },
            onItemAdd:
                (DragAndDropItem newItem, int listIndex, int itemIndex) async {
              onNewItemAdd(context, setStateForDialog, itemIndex);
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
                              color: isSelectedQuestion(element)
                                  ? Colors.blue.withOpacity(0.4)
                                  : Colors.white,
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        height: 6,
                                      ),
                                      Container(
                                        width: 710,
                                        alignment: Alignment.centerLeft,
                                        margin:
                                            EdgeInsets.fromLTRB(40, 0, 0, 0),
                                        child: Text(
                                          element.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        height: 6,
                                      ),
                                      Container(
                                        width: 710,
                                        margin:
                                            EdgeInsets.fromLTRB(30, 0, 0, 0),
                                        height: 55,
                                        child: AgendaUtil
                                            .getQuestionDescriptionText(
                                          element,
                                          14,
                                          isAutoSize: true,
                                          showHiddenSections: true,
                                        ),
                                      ),
                                    ],
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
                                                padding:
                                                    MaterialStateProperty.all(
                                                        EdgeInsets.all(15)),
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
                                                  CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .transparent)),
                                                ),
                                              ),
                                              onPressed: () {
                                                setStateForDialog(() {
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
                                                  _cbDescriptionShowOnStroreboard =
                                                      <bool>[];
                                                  _cbDescriptionShowInReports =
                                                      <bool>[];

                                                  _questionDescriptions =
                                                      _editedQuestion
                                                          .descriptions;

                                                  for (var description
                                                      in _questionDescriptions) {
                                                    _tecDescriptionCaptions.add(
                                                        TextEditingController(
                                                            text: description
                                                                .caption));
                                                    _tecDescriptionTexts.add(
                                                        TextEditingController(
                                                            text: description
                                                                .text));
                                                    _cbDescriptionShowOnStroreboard
                                                        .add(description
                                                            .showOnStoreboard);
                                                    _cbDescriptionShowInReports
                                                        .add(description
                                                            .showInReports);
                                                  }

                                                  _accessRights =
                                                      List<int>.from(
                                                          _editedQuestion
                                                              .accessRights);

                                                  _files =
                                                      List<QuestionFile>.from(
                                                          _editedQuestion
                                                              .files);
                                                  _filesFolder =
                                                      _editedQuestion.folder;

                                                  _questionsBase =
                                                      copyQuestions(_questions);
                                                });
                                              },
                                              child: Icon(Icons.edit),
                                            ),
                                          ),
                                          Tooltip(
                                            message: 'Удалить вопрос',
                                            child: TextButton(
                                              style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                        EdgeInsets.all(15)),
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
                                                  CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .transparent)),
                                                ),
                                              ),
                                              onPressed: isSelectedQuestion(
                                                      element)
                                                  ? null
                                                  : () async {
                                                      var noButtonPressed =
                                                          false;
                                                      var title =
                                                          'Удалить вопрос';
                                                      var selectedOption;

                                                      await Utility()
                                                          .showYesNoOptionsDialog(
                                                        context,
                                                        title: title,
                                                        text:
                                                            'Вы уверены, что хотите ${title.toLowerCase()}?',
                                                        options: <String>[
                                                          "с обновлением порядкового номера",
                                                          "с сохранением порядкового номера",
                                                        ],
                                                        yesButtonText: 'Да',
                                                        yesCallBack:
                                                            (String option) {
                                                          selectedOption =
                                                              option;

                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        noButtonText: 'Нет',
                                                        noCallBack: () {
                                                          noButtonPressed =
                                                              true;
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      );

                                                      if (noButtonPressed) {
                                                        return;
                                                      }
                                                      if (selectedOption ==
                                                          "с обновлением порядкового номера") {
                                                        QuestionListUtil
                                                            .removeQuestionAndUpdate(
                                                                _settings,
                                                                _questions,
                                                                element);
                                                      }
                                                      if (selectedOption ==
                                                          "с сохранением порядкового номера") {
                                                        QuestionListUtil
                                                            .removeQuestion(
                                                                _questions,
                                                                element);
                                                      }

                                                      setStateForDialog(() {});
                                                    },
                                              child: Icon(Icons.delete,
                                                  color: isSelectedQuestion(
                                                          element)
                                                      ? Colors.grey
                                                      : Colors.black),
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
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.all(15)),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    Colors.black12),
                                            shape: MaterialStateProperty.all(
                                              CircleBorder(
                                                  side: BorderSide(
                                                      color:
                                                          Colors.transparent)),
                                            ),
                                          ),
                                          onPressed: () {
                                            onNewItemAdd(
                                                context,
                                                setStateForDialog,
                                                element.orderNum + 1);
                                          },
                                          child: Icon(Icons.add),
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
      ],
    );
  }

  bool isSelectedQuestion(Question question) {
    return question.id == _selectedQuestion?.id &&
        _selectedQuestion?.id != null;
  }

  onNewItemAdd(
      BuildContext context, Function setStateForDialog, int itemIndex) async {
    setStateForDialog(() {
      _questions.insert(itemIndex, _newQuestionStub);
    });

    var noButtonPressed = false;
    var title = 'Добавить вопрос';
    var selectedOption;

    await Utility().showYesNoOptionsDialog(
      context,
      title: title,
      text: 'Вы уверены, что хотите ${title.toLowerCase()}?',
      options: <String>[
        "Основной вопрос",
        "Дополнительный вопрос",
        "Пустой вопрос",
      ],
      yesButtonText: 'Да',
      yesCallBack: (String option) {
        setStateForDialog(() {
          _questions.remove(_newQuestionStub);
        });

        selectedOption = option;
        Navigator.of(context).pop();
      },
      noButtonText: 'Нет',
      noCallBack: () {
        setStateForDialog(() {
          _questions.remove(_newQuestionStub);
        });

        noButtonPressed = true;
        Navigator.of(context).pop();
      },
    );

    var settingsGroup = _settings.questionListSettings.mainQuestion;

    if (noButtonPressed) {
      return;
    }

    _questionsBase = copyQuestions(_questions);

    if (selectedOption == "Основной вопрос") {
      settingsGroup = _settings.questionListSettings.mainQuestion;
    }
    if (selectedOption == "Дополнительный вопрос") {
      settingsGroup = _settings.questionListSettings.additionalQiestion;
    }
    if (selectedOption == "Пустой вопрос") {
      settingsGroup = new QuestionGroupSettings();
    }

    _editedQuestion = new Question();
    _editedQuestion.name = settingsGroup.defaultGroupName;
    _editedQuestion.orderNum = itemIndex;

    QuestionListUtil.insert(_settings, _questions, _editedQuestion, itemIndex);

    setStateForDialog(() {
      _tecQuestionName.text = _editedQuestion.toString();
      _tecQuestionPosition.text = _editedQuestion.orderNum.toString();
      _files = <QuestionFile>[];
      _accessRights = <int>[];
      _filesFolder = Uuid().v4();
      _questionDescriptions = createQuestionDescription(settingsGroup);
      _tecDescriptionCaptions = <TextEditingController>[];
      _tecDescriptionTexts = <TextEditingController>[];
      _cbDescriptionShowOnStroreboard = <bool>[];
      _cbDescriptionShowInReports = <bool>[];
      for (var description in _questionDescriptions) {
        _tecDescriptionCaptions
            .add(TextEditingController(text: description.caption));
        _tecDescriptionTexts.add(TextEditingController(text: description.text));
        _cbDescriptionShowOnStroreboard.add(description.showOnStoreboard);
        _cbDescriptionShowInReports.add(description.showInReports);
      }
    });
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

  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    var question = _questions[oldItemIndex];
    QuestionListUtil.removeQuestionAndUpdate(_settings, _questions, question);
    question.orderNum = newItemIndex;
    QuestionListUtil.insert(_settings, _questions, question, newItemIndex);
    //var movedList = _questions.removeAt(oldItemIndex);
    //_questions.insert(newItemIndex, movedList);
  }

  bool onAddQuestion() {
    if (!_formKey.currentState.validate()) {
      return false;
    }

    _editedQuestion.name = _tecQuestionName.text;
    _editedQuestion.agendaId = _selectedMeeting.agenda.id;

    _editedQuestion.descriptions = <QuestionDescriptionItem>[];
    for (int i = 0; i < _questionDescriptions.length; i++) {
      _editedQuestion.descriptions.add(QuestionDescriptionItem(
        caption: _tecDescriptionCaptions[i].text,
        text: _tecDescriptionTexts[i].text,
        showOnStoreboard: _cbDescriptionShowOnStroreboard[i],
        showInReports: _cbDescriptionShowInReports[i],
      ));
    }

    _editedQuestion.orderNum = int.parse(_tecQuestionPosition.text);
    _editedQuestion.folder = _filesFolder;
    _editedQuestion.files = _files;
    _editedQuestion.accessRights = _accessRights;

    return true;
  }

  Future<bool> onSaveQuestion(BuildContext context) async {
    var noButtonPressed = false;

    var title = 'Сохранить список вопросов';

    await Utility().showYesNoDialog(
      context,
      title: title,
      message: TextSpan(
        text: 'Вы уверены, что хотите ${title.toLowerCase()}?',
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
      return false;
    }

    var agenda =
        Agenda.fromJson(jsonDecode(jsonEncode(_selectedMeeting.agenda)));
    agenda.questions = _questions;
    _connection.updateAgenda(agenda);

    return true;
  }

  Widget getNewQuestionDescription(Function setStateForDialog) {
    if (_questionDescriptions == null) {
      return Container();
    }
    return SingleChildScrollView(
      controller: _questionsDescriptionsScrollController,
      child: Container(
        color: Colors.black12,
        height: 312,
        width: 710,
        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _questionDescriptions.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black38),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _cbDescriptionShowOnStroreboard[index],
                              onChanged: (bool value) {
                                setStateForDialog(() {
                                  _cbDescriptionShowOnStroreboard[index] =
                                      value;
                                });
                              },
                            ),
                            Text('Отображать на табло'),
                          ],
                        ),
                        Container(
                          width: 15,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _cbDescriptionShowInReports[index],
                              onChanged: (bool value) {
                                setStateForDialog(() {
                                  _cbDescriptionShowInReports[index] = value;
                                });
                              },
                            ),
                            Text('Отображать в отчете'),
                          ],
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Tooltip(
                          message: 'Удалить',
                          child: TextButton(
                            onPressed: () {
                              setStateForDialog(() {
                                _questionDescriptions.removeAt(index);
                                _tecDescriptionCaptions.removeAt(index);
                                _tecDescriptionTexts.removeAt(index);
                                _cbDescriptionShowOnStroreboard.removeAt(index);
                                _cbDescriptionShowInReports.removeAt(index);
                              });
                            },
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        color: Colors.white,
                        child: TextField(
                          minLines: 2,
                          maxLines: 2,
                          controller: _tecDescriptionCaptions[index],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Заголовок ${index + 1}',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        color: Colors.white,
                        child: TextField(
                          controller: _tecDescriptionTexts[index],
                          minLines: 4,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
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

  Widget getQuestionSection(BuildContext context, Function setStateForDialog) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _addQuestionScrollContoller,
        child: SingleChildScrollView(
          controller: _addQuestionScrollContoller,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListBody(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                  color: Colors.lightBlue,
                  width: 640,
                  child: Text(
                    _editedQuestion?.id == null
                        ? 'Добавить вопрос'
                        : 'Изменить вопрос: ${_editedQuestion?.toString()}',
                    style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  height: 10,
                ),
                TextFormField(
                  controller: _tecQuestionName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Наименование вопроса',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
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
                  style: TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Порядковый номер',
                  ),
                  controller: _tecQuestionPosition,
                ),
                Container(height: 10),
                Container(
                  padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                  color: Colors.lightBlue,
                  width: 640,
                  child: Row(
                    children: [
                      Text(
                        'Содержание вопроса',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Tooltip(
                          message: 'Добавить вопрос в список вопросов',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () {
                              addQuestionDescription(setStateForDialog);
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getNewQuestionDescription(setStateForDialog),
                Container(
                  padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                  color: Colors.lightBlue,
                  width: 640,
                  child: Row(
                    children: [
                      Text(
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
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Tooltip(
                          message: 'Добавить файл',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () async {
                              await addSelectedQuestionFile(setStateForDialog);
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                  color: Colors.lightBlue,
                  width: 640,
                  child: Row(
                    children: [
                      Text(
                        'Права доступа',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Tooltip(
                          message: 'Добавить права доступа',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () async {
                              await addAccessRights(context, setStateForDialog);
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getAccessRightsTable(context, setStateForDialog),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getFilesTable(BuildContext context, Function setStateForDialog) {
    if (_files.length == 0) {
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
            columns: [
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
                                        CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: () {
                                      showFileDescriptionDialog(
                                          context, setStateForDialog, element);
                                    },
                                    child: Icon(Icons.edit),
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
                                        CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: () {
                                      removeFile(element);
                                      setStateForDialog(() {});
                                    },
                                    child: Icon(Icons.delete),
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

  Widget getAccessRightsTable(
      BuildContext context, Function setStateForDialog) {
    if (_accessRights.length == 0) {
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
            columns: [
              DataColumn(
                label: Text(
                  'Имя пользователя',
                ),
              ),
            ],
            rows: _accessRights.map(
              ((element) {
                var foundUser = _users.firstWhere(
                  (u) => u.id == element,
                  orElse: () => null,
                );

                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(children: [
                              Text(foundUser.getFullName()),
                            ]),
                          ),
                          Tooltip(
                            message: 'Удалить права доступа',
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                overlayColor:
                                    MaterialStateProperty.all(Colors.black12),
                                shape: MaterialStateProperty.all(
                                  CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () {
                                _accessRights.remove(element);
                                setStateForDialog(() {});
                              },
                              child: Icon(Icons.delete),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ).toList(),
          ),
        ),
      ],
    );
  }

  void addQuestionDescription(Function setStateForDialog) {
    setStateForDialog(() {
      _questionDescriptions.add(QuestionDescriptionItem(
          showInReports: false, showOnStoreboard: false));
      _tecDescriptionCaptions.add(TextEditingController());
      _tecDescriptionTexts.add(TextEditingController());
      _cbDescriptionShowOnStroreboard.add(false);
      _cbDescriptionShowInReports.add(false);
    });
  }

  Future<void> addAccessRights(
      BuildContext context, Function setStateForDialog) async {
    // show select user dialog
    final formKey = GlobalKey<FormState>();
    User selectedUser;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить депутата'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  getDeputySelector((value) {
                    selectedUser = value;
                  }),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }

                setStateForDialog(() {
                  var isContains =
                      _accessRights.any((x) => x == selectedUser.id);
                  if (!isContains) {
                    _accessRights.add(selectedUser.id);
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getDeputySelector(void onChanged(User value)) {
    var groupUsers = _users.where((element) => isHaveRights(element)).toList();

    return DropdownSearch<User>(
      mode: Mode.DIALOG,
      showSearchBox: true,
      showClearButton: true,
      items: _users.where((element) => !groupUsers.contains(element)).toList(),
      label: 'Депутат',
      popupTitle: Container(
          alignment: Alignment.center,
          color: Colors.blueAccent,
          padding: EdgeInsets.all(10),
          child: Text(
            'Депутат',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          )),
      hint: 'Выберите Депутата',
      selectedItem: null,
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Выберите Депутата';
        }
        return null;
      },
      dropdownBuilder: userDropDownItemBuilder,
      popupItemBuilder: userItemBuilder,
      emptyBuilder: emptyBuilder,
    );
  }

  bool isHaveRights(User user) {
    return _accessRights.any((element) => element == user.id);
  }

  Widget userDropDownItemBuilder(
    BuildContext context,
    User item,
    String itemDesignation,
  ) {
    return item == null
        ? Container(
            child: Text(
              'Выберите депутата',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : userItemBuilder(context, item, true);
  }

  Widget userItemBuilder(BuildContext context, User item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Row(
          children: [
            Text(item.toString()),
            Expanded(child: Container()),
            Container(
              width: 20,
            ),
            Container(),
          ],
        ),
      ),
    );
  }

  Widget emptyBuilder(BuildContext context, String text) {
    return Center(child: Text('Нет данных'));
  }

  Future<void> addSelectedQuestionFile(Function setStateForDialog) async {
    XTypeGroup typeGroup = XTypeGroup(
      label: 'Выберите документ',
      extensions: <String>['pdf'],
    );
    final String initialDirectory =
        (await getApplicationDocumentsDirectory()).path;
    final XFile result = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
      initialDirectory: initialDirectory,
    );

    if (result == null) {
      return;
    }

    if (_files.any((element) => element.fileName == result.name)) {
      Utility().showMessageOkDialog(_context,
          title: 'Загрузка файла',
          message: TextSpan(
            text:
                'Вопрос уже содержит файл с именем ${result.name}\nЗагрузка будет отменена.',
          ),
          okButtonText: 'Ок');
      return;
    }

    showDialog<void>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text("Загрузка файла ${result.name}")),
              ],
            ),
          );
        });

    var folderUploadName = _filesFolder;
    var agendaFolderName = _selectedMeeting.agenda.folder;
    var request = http.MultipartRequest(
        'POST', Uri.parse(ServerConnection.getFileServerUploadUrl(_settings)));

    request.fields['agendaName'] = '$agendaFolderName';
    request.fields['folderName'] = '$folderUploadName';

    request.files.add(await http.MultipartFile.fromPath('file', result.path));

    await request.send().timeout(Duration(seconds: 10)).then((value) async {
      String formattedDescription = result.name.endsWith('.pdf')
          ? result.name.substring(0, result.name.length - 4)
          : result.name;

      var questionFile = QuestionFile(
          fileName: result.name,
          version: Uuid().v4(),
          description: formattedDescription,
          relativePath: agendaFolderName + '/' + _filesFolder,
          questionId: null);

      setStateForDialog(() {
        _files.add(questionFile);
      });

      Navigator.of(_context).pop();

      await Utility().showMessageOkDialog(_context,
          title: 'Загрузка файла',
          message: TextSpan(
            text: 'Загрузка файла ${result.name} успешно завершена',
          ),
          okButtonText: 'Ок');
    }).catchError((e) async {
      Navigator.of(_context).pop();
      await Utility().showMessageOkDialog(_context,
          title: 'Загрузка файла',
          message: TextSpan(
            text: 'В ходе загрузки файла ${result.name}  возникла ошибка: {$e}',
          ),
          okButtonText: 'Ок');
    });
  }

  void showFileDescriptionDialog(BuildContext context,
      Function setStateForDialog, QuestionFile file) async {
    TextEditingController _tecEditFileDescription = new TextEditingController();
    _tecEditFileDescription.text = file.description;
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Изменение описания файла'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecEditFileDescription,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Описание файла',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
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
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }

                setStateForDialog(() {
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

  void removeFile(QuestionFile file) {
    _files.remove(file);
  }
}
