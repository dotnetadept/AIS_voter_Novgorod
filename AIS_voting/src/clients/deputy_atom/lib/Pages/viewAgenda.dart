import 'dart:convert' show json;
import 'package:ais_model/ais_model.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../State/AppState.dart';

class ViewAgendaPage extends StatefulWidget {
  ViewAgendaPage({Key key}) : super(key: key);

  @override
  _ViewAgendaPageState createState() => _ViewAgendaPageState();
}

class _ViewAgendaPageState extends State<ViewAgendaPage> {
  ScrollController _questionsTableScrollController;
  ScrollController _questionFilesTableScrollController;

  Question _selectedQuestion;
  QuestionFile _selectedQuestionFile;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();

    _questionsTableScrollController = ScrollController(
        initialScrollOffset: AppState().getAgendaScrollPosition() ?? 0.0,
        keepScrollOffset: true);
    _questionsTableScrollController.addListener(scrollPosition);
    _questionFilesTableScrollController = new ScrollController();

    if (AppState().getCurrentDocument() != null) {
      if (AppState().canUserNavigate()) {
        Provider.of<WebSocketConnection>(context, listen: false)
            .navigateToPage('/viewDocument');
      }
    }

    setSelectedQuestion(AppState().getCurrentQuestion() ??
        AppState().getCurrentMeeting().agenda.questions.first);

    if (_selectedQuestion ==
        AppState().getCurrentMeeting().agenda.questions.first) {
      _tabIndex = 0;
    } else if (_selectedQuestion == null) {
      _tabIndex = 1;
    } else if (_selectedQuestion != null) {
      _tabIndex = 2;
    }

    if (AppState().getAgendaDocument() != null) {
      _tabIndex = 1;
    } else {
      AppState().setCurrentQuestion(_selectedQuestion);
    }
  }

  scrollPosition() async {
    AppState().setAgendaScrollPosition(
        _questionsTableScrollController.position.pixels);
  }

  void setSelectedQuestion(Question question) {
    _selectedQuestion = question;
    _selectedQuestion.files.sort((a, b) => a.id.compareTo(b.id));
  }

  void onAskWord() {
    if (AppState().getAskWordStatus()) {
      Provider.of<WebSocketConnection>(context, listen: false)
          .sendMessage('ПРОШУ СЛОВА СБРОС');
    } else {
      Provider.of<WebSocketConnection>(context, listen: false)
          .sendMessage('ПРОШУ СЛОВА');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.white,
    );
  }

  Widget body() {
    if (AppState().getCurrentMeeting() == null) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: leftPanel(),
        ),
        Container(width: 2, color: Colors.lightBlue),
        Container(
          width: AppState().getSettings().storeboardSettings.width.toDouble(),
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget leftPanel() {
    final connection = Provider.of<WebSocketConnection>(context, listen: false);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppState().getCurrentUser() == null
                              ? 'Гость'
                              : AppState().getCurrentUser().toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: AppState()
                                      .getSettings()
                                      .managerSchemeSettings
                                      .deputyFontSize
                                      .toDouble() *
                                  (2 / 3)),
                        ),
                      ),
                      AppState().getServerState().systemState ==
                                  SystemState.Stream &&
                              AppState().getServerState().streamControl ==
                                  'user'
                          ? TextButton(
                              onPressed: () {
                                connection.navigateToPage('/viewStream');
                                return;
                              },
                              child: Text('Стрим'))
                          : Container(),
                      connection.getClientType() == 'guest'
                          ? Container()
                          : Tooltip(
                              message: AppState().getIsRegistred()
                                  ? 'Зарегистрирован'
                                  : 'Не зарегистрирован',
                              child: Icon(Icons.people,
                                  color: Color(AppState().getIsRegistred()
                                      ? AppState()
                                          .getSettings()
                                          .palletteSettings
                                          .iconDocumentsDownloadedColor
                                      : AppState()
                                          .getSettings()
                                          .palletteSettings
                                          .iconDocumentsNotDownloadedColor))),
                      Icon(Icons.file_present,
                          color: Color(AppState().getIsLoadingInProgress()
                              ? Colors.yellow.value
                              : AppState().getIsDocumentsDownloaded()
                                  ? AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .iconDocumentsDownloadedColor
                                  : AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .iconDocumentsNotDownloadedColor)),
                      !connection.getIsManualLogin
                          ? Container()
                          : Tooltip(
                              message: 'Выйти',
                              child: TextButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.zero,
                                  ),
                                  shape: MaterialStateProperty.all(
                                    CircleBorder(
                                        side: BorderSide(
                                            color: Colors.transparent)),
                                  ),
                                ),
                                onPressed: () {
                                  Provider.of<WebSocketConnection>(context,
                                          listen: false)
                                      .onUserExit();
                                },
                                child: Icon(
                                  Icons.exit_to_app,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            color: Colors.black12,
            child: _tabIndex == 0
                ? getAgendaTab()
                : _tabIndex == 1
                    ? getQuestionsTab()
                    : _tabIndex == 2
                        ? getQuestionDescriptionTab()
                        : Container(),
          ),
        ),
      ],
    );
  }

  Widget getQuestionsTab() {
    return Column(
      children: [
        getHeader('Повестка пленарного заседания'),
        Container(
          height: MediaQuery.of(context).size.height - 197,
          child: getQuestionsList(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedQuestion =
                      AppState().getCurrentMeeting().agenda.questions.first;
                  _selectedQuestion.files.sort((a, b) => a.id.compareTo(b.id));
                  AppState().setCurrentQuestion(_selectedQuestion);
                  AppState().setAgendaDocument(null);
                  _tabIndex = 0;
                });
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(250, 50),
                ),
              ),
              child: Text('К регламентным вопросам'),
            ),
          ),
        ),
      ],
    );
  }

  Widget getAgendaTab() {
    setSelectedQuestion(AppState().getCurrentMeeting().agenda.questions.first);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
          child: Row(children: [
            Expanded(
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
              ),
              child: TextButton(
                onPressed: () {
                  if (AppState().canUserNavigate()) {
                    setState(() {
                      AppState().setCurrentQuestion(null);
                      AppState().setAgendaDocument(new QuestionFile());

                      AppState().setCurrentPage('');
                      Provider.of<WebSocketConnection>(context, listen: false)
                          .navigateToPage('/viewAgenda');
                    });
                  }
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(500, 100),
                  ),
                ),
                child: Text(
                  'Повестка пленарного заседания',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
          ]),
        ),
        Expanded(
          child: Column(
            children: [
              getHeader('Регламентные вопросы'),
              getQuestionFilesList(),
              Container(
                height: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getQuestionDescriptionTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              getHeader(
                _selectedQuestion.toString(settings: AppState().getSettings()),
              ),
              getQuestionDescription(),
              Container(
                height: 15,
              ),
              getHeader('Файлы вопроса (${_selectedQuestion.files.length})'),
              getQuestionFilesList(),
              Container(
                height: 10,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Row(children: [
              Expanded(
                child: Container(),
              ),
              TextButton(
                onPressed: () {
                  if (AppState().canUserNavigate()) {
                    setState(() {
                      AppState().setAgendaDocument(new QuestionFile());
                      AppState().setCurrentQuestion(null);

                      AppState().setCurrentPage('');
                      Provider.of<WebSocketConnection>(context, listen: false)
                          .navigateToPage('/viewAgenda');
                    });
                  }
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(200, 50),
                  ),
                ),
                child: Text('К повестке'),
              ),
              Expanded(
                child: Container(),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget getHeader(String headerName) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            color: Colors.lightBlue,
            child: Text(
              headerName,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AppState()
                      .getSettings()
                      .managerSchemeSettings
                      .deputyCaptionFontSize
                      .toDouble()),
            ),
          ),
        ),
      ],
    );
  }

  Widget getQuestionsList() {
    if (!AppState()
        .getCurrentMeeting()
        .agenda
        .questions
        .any((element) => element.id == _selectedQuestion?.id)) {
      setSelectedQuestion(
          AppState().getCurrentMeeting().agenda.questions.first);
    }

    return Scrollbar(
      isAlwaysShown: true,
      controller: _questionsTableScrollController,
      child: ListView.builder(
        controller: _questionsTableScrollController,
        itemCount: AppState().getCurrentMeeting().agenda.questions.length,
        itemBuilder: (BuildContext context, int index) {
          // Special display for the first number
          if (index == 0) {
            return Container();
          }
          var element = AppState().getCurrentMeeting().agenda.questions[index];
          return InkWell(
            onTap: () {
              setState(() {
                setSelectedQuestion(element);
                AppState().setCurrentQuestion(_selectedQuestion);
                AppState().setAgendaDocument(null);
                _tabIndex = 2;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: IgnorePointer(
                            ignoring: true,
                            child: AgendaUtil.getQuestionDescriptionText(
                                element,
                                AppState()
                                    .getSettings()
                                    .managerSchemeSettings
                                    .deputyFontSize
                                    .toDouble(),
                                lineHeight: 1,
                                withQuestionNumber: true,
                                numberFontSize: AppState()
                                    .getSettings()
                                    .managerSchemeSettings
                                    .deputyNumberFontSize
                                    .toDouble(),
                                textAlign: TextAlign.justify,
                                maxLines: 60),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: AppState()
                            .getSettings()
                            .managerSchemeSettings
                            .deputyNumberFontSize
                            .toDouble() /
                        2,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getQuestionDescription() {
    return Container(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: AgendaUtil.getQuestionDescriptionText(
                  _selectedQuestion,
                  AppState()
                      .getSettings()
                      .managerSchemeSettings
                      .deputyFontSize
                      .toDouble(),
                  lineHeight: 1,
                  maxLines: 60,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ]),
    );
  }

  Widget getQuestionFilesList() {
    return Scrollbar(
      isAlwaysShown: true,
      controller: _questionFilesTableScrollController,
      child: SingleChildScrollView(
        controller: _questionFilesTableScrollController,
        child: Container(
          height: 310,
          // height: AppState().getSettings().managerSchemeSettings.deputyFilesListHeight.toDouble(),
          child: ListView.builder(
              itemCount: _selectedQuestion.files.length,
              itemBuilder: (BuildContext context, int index) {
                var element = _selectedQuestion.files[index];
                return InkWell(
                  onTap: () {
                    viewFile(element);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey,
                            width: 1,
                            style: BorderStyle.solid),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 42.285,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(children: [
                                  IgnorePointer(
                                    ignoring: true,
                                    child: Text(
                                      element.description,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      softWrap: true,
                                      style: TextStyle(fontSize: 18),
                                      // fontSize: AppState().getSettings().managerSchemeSettings.deputyFontSize.toDouble()),
                                    ),
                                  ),
                                ]),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.event_note,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  Future<void> viewFile(QuestionFile file) async {
    if (AppState().canUserNavigate()) {
      setState(() {
        _selectedQuestionFile = file;

        AppState().setCurrentDocument(_selectedQuestionFile);
      });

      Provider.of<WebSocketConnection>(context, listen: false)
          .navigateToPage('/viewDocument');
    }
  }

  Widget rightPanel() {
    Provider.of<AppState>(context, listen: true);
    final connection = Provider.of<WebSocketConnection>(context, listen: false);
    var isSmallView = MediaQuery.of(context).size.height <= 750;
    var emblemHeight = MediaQuery.of(context).size.height -
        AppState().getSettings().storeboardSettings.height -
        200;

    print('Screen height:' + MediaQuery.of(context).size.height.toString());
    print('Screen width:' + MediaQuery.of(context).size.width.toString());

    emblemHeight = emblemHeight > 0 ? emblemHeight : 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.blue[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: MediaQuery.of(context).size.height -
                      AppState().getSettings().storeboardSettings.height -
                      200,
                  child: Container(
                    child: isSmallView
                        ? Image(image: AssetImage('assets/images/emblem.png'))
                        : Image(image: AssetImage('assets/images/emblem.png')),
                  ),
                ),
                Expanded(child: Container()),
                connection.getClientType() != 'deputy' ||
                        !AppState().getIsRegistred()
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppState().getAskWordStatus()
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 5,
                            ),
                          ),
                          child: TextButton(
                            autofocus: true,
                            style: ButtonStyle(
                              minimumSize:
                                  MaterialStateProperty.all(Size(350, 100)),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                            ),
                            onPressed: () => {onAskWord()},
                            child: Container(
                              color: AppState().getAskWordStatus()
                                  ? Color(AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .askWordColor)
                                  : Colors.blue,
                              height: 100,
                              width: 350,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  AppState().getAskWordStatus()
                                      ? 'ОТКАЗАТЬСЯ ОТ ВЫСТУПЛЕНИЯ'
                                      : 'ПРОШУ СЛОВА',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppState().getAskWordStatus()
                                          ? 20
                                          : 30,
                                      color: Color(AppState()
                                          .getSettings()
                                          .palletteSettings
                                          .buttonTextColor)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                connection.getClientType() != 'guest'
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(AppState()
                                  .getSettings()
                                  .palletteSettings
                                  .buttonTextColor),
                              width: 5,
                            ),
                          ),
                          child: TextButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(0)),
                              minimumSize:
                                  MaterialStateProperty.all(Size(350, 100)),
                            ),
                            onPressed: () => {
                              Provider.of<WebSocketConnection>(context,
                                      listen: false)
                                  .onUserExit()
                            },
                            child: Text(
                              'ВЫЙТИ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                                color: Color(AppState()
                                    .getSettings()
                                    .palletteSettings
                                    .buttonTextColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
        StoreboardWidget(
          serverState: AppState().getServerState(),
          meeting: AppState().getCurrentMeeting(),
          question: AppState().getCurrentMeeting().agenda.questions.firstWhere(
              (element) =>
                  element.id ==
                  json.decode(
                      AppState().getServerState().params)['selectedQuestion'],
              orElse: () => null),
          settings: AppState().getSettings(),
          timeOffset: AppState().getTimeOffset(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _questionsTableScrollController.removeListener(() {
      scrollPosition();
    });
    _questionsTableScrollController.dispose();
    _questionFilesTableScrollController.dispose();

    super.dispose();
  }
}
