import 'package:ais_model/ais_model.dart';
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import '../State/AppState.dart';

class ViewAgendaPage extends StatefulWidget {
  ViewAgendaPage({Key key}) : super(key: key);

  @override
  _ViewAgendaPageState createState() => _ViewAgendaPageState();
}

class _ViewAgendaPageState extends State<ViewAgendaPage> {
  ScrollController _meetingsTableScrollController;
  ScrollController _questionsTableScrollController;
  ScrollController _filesTableScrollController;

  Meeting _selectedMeeting;
  Question _selectedQuestion;
  int _tabIndex = 0;

  List<String> _extensions = <String>['.pptx', '.pdf', '.xlsx', '.docx'];

  @override
  void initState() {
    super.initState();

    _meetingsTableScrollController = ScrollController();
    _questionsTableScrollController = new ScrollController();
    _filesTableScrollController = new ScrollController();

    if (AppState().getSelectedMeeting() != null) {
      _selectedMeeting = AppState().getSelectedMeeting();
      _tabIndex = 1;
    }
    if (AppState().getSelectedQuestion() != null) {
      _selectedQuestion = AppState().getSelectedQuestion();
      _tabIndex = 2;
    }
  }

  void setSelectedMeeting(Meeting meeting) {
    _selectedMeeting = meeting;
    _selectedMeeting.agenda.questions
        .removeWhere((element) => element.orderNum == 0);
    _selectedMeeting.agenda.questions
        .sort((a, b) => a.orderNum.compareTo(b.orderNum));
    AppState().setSelectedMeeting(_selectedMeeting);
  }

  void setSelectedQuestion(Question question) {
    _selectedQuestion = question;
    _selectedQuestion.files.sort((a, b) => a.id.compareTo(b.id));
    AppState().setSelectedQuestion(_selectedQuestion);
  }

  Future<void> setSelectedFile(QuestionFile file) async {
    AppState().setSelectedQuestionFile(file);

    await Navigator.of(context).pushNamedAndRemoveUntil(
        '/viewDocument', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.white,
    );
  }

  Widget body() {
    if (AppState().getMeetings() == null || AppState().getSettings() == null) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: leftPanel(),
        ),
      ],
    );
  }

  Widget leftPanel() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: _tabIndex == 0
                ? getMeetingsTab()
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
        getHeader('${_selectedMeeting.name}'),
        Expanded(
          child: getQuestionsList(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _tabIndex = 0;
                });
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(250, 50),
                ),
              ),
              child: Text('Назад'),
            ),
          ),
        ),
      ],
    );
  }

  Widget getMeetingsTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            children: [
              getHeader('Заседания'),
              getMeetingsList(),
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                getHeader(
                  _selectedQuestion.toString(
                      settings: AppState().getSettings()),
                ),
                getQuestionDescription(),
                Container(
                  height: 15,
                ),
                getHeader('Файлы вопроса (${_selectedQuestion.files.length})'),
                getFilesList(),
                Container(
                  height: 10,
                ),
              ],
            ),
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
                  setState(() {
                    _tabIndex = 1;
                  });
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(250, 50),
                  ),
                ),
                child: Text('Назад'),
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
                  fontSize: 26),
            ),
          ),
        ),
      ],
    );
  }

  Widget getQuestionsList() {
    return Scrollbar(
      isAlwaysShown: false,
      controller: _questionsTableScrollController,
      child: ListView.builder(
        controller: _questionsTableScrollController,
        itemCount: _selectedMeeting.agenda.questions.length,
        itemBuilder: (BuildContext context, int index) {
          var element = _selectedMeeting.agenda.questions[index];
          return InkWell(
            onTap: () {
              setState(() {
                setSelectedQuestion(element);
                _tabIndex = 2;
              });
            },
            child: Column(
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
                      child: Container(
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
                  height: 10,
                ),
                Container(
                  height: 1,
                  color: Colors.black87,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getFilesList() {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      child: ListView.builder(
        controller: _filesTableScrollController,
        itemCount: _selectedQuestion.files.length,
        itemBuilder: (BuildContext context, int index) {
          var element = _selectedQuestion.files[index];
          var elementExtension = '';
          for (int i = 0; i < 4; i++) {
            if (index % 4 == i) {
              elementExtension = _extensions[i];
              break;
            }
          }
          return InkWell(
            onTap: () async {
              setSelectedFile(element);
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
                  Container(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        child: Wrap(children: [
                          IgnorePointer(
                            ignoring: true,
                            child: Text(
                              element.description + elementExtension,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(fontSize: 22),
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
                  Container(
                    height: 15,
                  ),
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
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                child: AgendaUtil.getQuestionDescriptionText(
                  _selectedQuestion,
                  22.0,
                  lineHeight: 1,
                  maxLines: 60,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ]),
    );
  }

  Widget getMeetingsList() {
    var waitingMeetings = AppState()
        .getMeetings()
        .where((element) => element.status == 'Ожидание')
        .toList();
    return Scrollbar(
      isAlwaysShown: false,
      controller: _meetingsTableScrollController,
      child: SingleChildScrollView(
        controller: _meetingsTableScrollController,
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: ListView.builder(
              itemCount: waitingMeetings.length,
              itemBuilder: (BuildContext context, int index) {
                var element = waitingMeetings[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      setSelectedMeeting(element);
                      _tabIndex = 1;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 15,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 10,
                            ),
                            Expanded(
                              child: IgnorePointer(
                                ignoring: true,
                                child: Text(
                                  element.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
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
                      Container(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _meetingsTableScrollController.dispose();
    _questionsTableScrollController.dispose();
    _filesTableScrollController.dispose();

    super.dispose();
  }
}
