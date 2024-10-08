import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../Providers/WebSocketConnection.dart';

class HistoryDialog {
  BuildContext _context;

  late List<Meeting> _meetings;
  late List<MeetingSession> _meetingSessions;
  late List<QuestionSession> _questionSessions;

  MeetingSession? _selectedMeetingSession;
  int _timeOffset;

  late ScrollController _historyMeetingTableScrollController;
  late ScrollController _historySessionTableScrollController;

  var _tecSearch = TextEditingController();
  var _fnSearch = FocusNode();
  String _searchExpression = '';

  List<MeetingSession> _filteredMeetingSessions = <MeetingSession>[];
  List<QuestionSession> _filteredQuestionSessions = <QuestionSession>[];

  bool _isDataLoadStarted = false;
  bool _isDataLoadCompleted = false;

  void processSearch(String value, Function? setStateForDialog) {
    _searchExpression = value.trim();

    _filteredMeetingSessions = _meetingSessions.where((ms) {
      return getMeetingSessionText(ms)
          .toUpperCase()
          .contains(_searchExpression.toUpperCase());
    }).toList();

    if (_selectedMeetingSession != null) {
      _filteredQuestionSessions = _questionSessions.where((qs) {
        var meeting = _meetings.firstWhere(
            (element) => element.id == _selectedMeetingSession!.meetingId);

        var question = meeting.agenda!.questions
            .firstWhereOrNull((q) => q.id == qs.questionId);

        return question
                .toString()
                .toUpperCase()
                .contains(_searchExpression.toUpperCase()) ||
            qs.contains(_searchExpression);
      }).toList();
    }

    if (setStateForDialog != null) {
      setStateForDialog(() {});
    }
  }

  HistoryDialog(
    this._context,
    this._timeOffset,
  ) {
    _historyMeetingTableScrollController = ScrollController();
    _historySessionTableScrollController = ScrollController();
  }

  void loadData(Function setStateForDialog) {
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/meetings"))
        .then((response) {
      _meetings = (json.decode(response.body) as List)
          .map((data) => Meeting.fromJson(data))
          .toList();
    }).then((value) => http
                .get(Uri.http(
                    ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                    "/meeting_sessions"))
                .then((response) {
              _meetingSessions = (json.decode(response.body) as List)
                  .map((data) => MeetingSession.fromJson(data))
                  .toList();
              _meetingSessions.sort((a, b) =>
                  -1 *
                  (a.startDate ?? TimeUtil.getDateTimeNow(_timeOffset))
                      .compareTo(
                          b.startDate ?? TimeUtil.getDateTimeNow(_timeOffset)));

              processSearch(_tecSearch.text, null);

              setStateForDialog(() {
                _isDataLoadCompleted = true;
              });
            }));
  }

  Future<void> openDialog() async {
    return showDialog<void>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setStateForDialog) {
            if (!_isDataLoadStarted) {
              _isDataLoadStarted = true;
              loadData(setStateForDialog);
            }

            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                      color: Colors.lightBlue,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(),
                          ),
                          Text(
                            'История голосований',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 28),
                          ),
                          Container(
                            width: 20,
                          ),
                          Icon(
                            Icons.history,
                            size: 36,
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 750,
                height: 600,
                child: !_isDataLoadCompleted
                    ? CommonWidgets().getLoadingStub()
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      10,
                                      _selectedMeetingSession == null ? 25 : 10,
                                      10,
                                      _selectedMeetingSession == null
                                          ? 25
                                          : 10),
                                  color: Colors.lightBlue,
                                  child: Row(
                                    children: [
                                      _selectedMeetingSession == null
                                          ? Container()
                                          : TextButton(
                                              style: ButtonStyle(
                                                shape: WidgetStateProperty.all(
                                                  CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .transparent)),
                                                ),
                                              ),
                                              child: Icon(Icons.arrow_back),
                                              onPressed: () {
                                                setStateForDialog(() {
                                                  _selectedMeetingSession =
                                                      null;

                                                  _tecSearch.clear();
                                                  processSearch(_tecSearch.text,
                                                      setStateForDialog);
                                                });
                                              },
                                            ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            _selectedMeetingSession == null
                                                ? 'Сессии заседаний'
                                                : 'Сессия: ' +
                                                    getMeetingSessionText(
                                                        _selectedMeetingSession!),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _selectedMeetingSession != null
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _tecSearch,
                                          focusNode: _fnSearch,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Поиск',
                                            suffixIcon: _tecSearch.text.isEmpty
                                                ? null
                                                : Tooltip(
                                                    message: 'Очистить поиск',
                                                    child: IconButton(
                                                      onPressed: () {
                                                        setStateForDialog(() {
                                                          _tecSearch.clear();
                                                          processSearch(
                                                              _tecSearch.text,
                                                              setStateForDialog);
                                                        });
                                                      },
                                                      icon: Icon(Icons.clear),
                                                    ),
                                                  ),
                                          ),
                                          onSubmitted: (value) {
                                            _fnSearch.requestFocus();
                                            processSearch(
                                                value, setStateForDialog);
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                      ),
                                      Tooltip(
                                        message: 'Поиск',
                                        child: IconButton(
                                          onPressed: () {
                                            processSearch(_tecSearch.text,
                                                setStateForDialog);
                                          },
                                          icon: Icon(Icons.search),
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                ),
                          Expanded(
                            child: _selectedMeetingSession == null
                                ? getHistoryMeetingTable(setStateForDialog)
                                : getHistorySessionTable(setStateForDialog),
                          ),
                          Container(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(),
                              ),
                              TextButton(
                                child: Row(children: [
                                  Text('Отмена',
                                      style: TextStyle(fontSize: 20)),
                                  Container(
                                    width: 10,
                                  ),
                                  Icon(Icons.close),
                                ]),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
              ),
            );
          });
        });
  }

  Widget getHistoryMeetingTable(Function setStateForDialog) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _historyMeetingTableScrollController,
      child: ListView.builder(
          controller: _historyMeetingTableScrollController,
          itemCount: _filteredMeetingSessions.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () async {
                var questionSessionsResponse = await http.get(Uri.http(
                    ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                    "/questionsessions/${_filteredMeetingSessions[index].id}"));
                _questionSessions =
                    (json.decode(questionSessionsResponse.body) as List)
                        .map((data) => QuestionSession.fromJson(data))
                        .toList();

                _questionSessions
                    .sort((a, b) => a.startDate.compareTo(b.startDate));

                _selectedMeetingSession = _filteredMeetingSessions[index];

                _tecSearch.clear();
                processSearch(_tecSearch.text, setStateForDialog);
              },
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: Row(
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
                                getMeetingSessionText(
                                    _filteredMeetingSessions[index]),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ]),
                        ),
                        Container(
                          width: 10,
                        ),
                        Icon(
                          Icons.arrow_forward,
                        ),
                        Container(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget getHistorySessionTable(Function setStateForDialog) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _historySessionTableScrollController,
      child: ListView.builder(
          controller: _historySessionTableScrollController,
          itemCount: _filteredQuestionSessions.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: Row(
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
                                getQuestionSessionText(
                                    _filteredQuestionSessions[index]),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ]),
                        ),
                        Container(
                          width: 10,
                        ),
                        Tooltip(
                          message: 'Установить общие результаты',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            child: Icon(
                              Icons.monitor,
                            ),
                            onPressed: () {
                              setHistory(_selectedMeetingSession!,
                                  _filteredQuestionSessions[index], false);
                              setStateForDialog(() {});
                            },
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Tooltip(
                          message: 'Установить поименно',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            child: Icon(
                              Icons.list,
                            ),
                            onPressed: () {
                              setHistory(_selectedMeetingSession!,
                                  _filteredQuestionSessions[index], true);
                              setStateForDialog(() {});
                            },
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  void setHistory(MeetingSession meetingSession,
      QuestionSession questionSession, bool isDetailed) async {
    var meeting = _meetings
        .firstWhereOrNull((element) => element.id == meetingSession.meetingId);
    var question = meeting!.agenda!.questions.firstWhereOrNull(
        (element) => element.id == questionSession.questionId);
    var decisions = <String, String>{};

    // find current registration session
    var registrationSessionsResponse = await http.get(Uri.http(
        ServerConnection.getHttpServerUrl(GlobalConfiguration()),
        "/registrationsessions/${meeting.id}"));

    var registrationSessions =
        (json.decode(registrationSessionsResponse.body) as List)
            .map((data) => RegistrationSession.fromJson(data))
            .toList();

    var currentRegistrationSessions = <RegistrationSession>[];
    for (var j = 0; j < registrationSessions.length; j++) {
      if ((registrationSessions[j].startDate?.microsecondsSinceEpoch ??
                  TimeUtil.getDateTimeNow(_timeOffset)
                      .microsecondsSinceEpoch) >=
              (meetingSession.startDate?.microsecondsSinceEpoch ??
                  TimeUtil.getDateTimeNow(_timeOffset)
                      .microsecondsSinceEpoch) &&
          (registrationSessions[j].endDate?.microsecondsSinceEpoch ??
                  TimeUtil.getDateTimeNow(_timeOffset)
                      .microsecondsSinceEpoch) <=
              (meetingSession.endDate?.microsecondsSinceEpoch ??
                  TimeUtil.getDateTimeNow(_timeOffset).microsecondsSinceEpoch))
        currentRegistrationSessions.add(registrationSessions[j]);
    }
    var registrationSession = currentRegistrationSessions.firstWhereOrNull(
        (element) =>
            (element.endDate?.microsecondsSinceEpoch ??
                TimeUtil.getDateTimeNow(_timeOffset).microsecondsSinceEpoch) <=
            (questionSession.endDate?.microsecondsSinceEpoch ??
                TimeUtil.getDateTimeNow(_timeOffset).microsecondsSinceEpoch));

    var resultResponce = await http.get(Uri.http(
        ServerConnection.getHttpServerUrl(GlobalConfiguration()),
        "/result/${questionSession.id}"));
    var questionSessionResults = (json.decode(resultResponce.body) as List)
        .map((data) => Result.fromJson(data))
        .toList();

    var voters = meeting.group!.groupUsers
        .map<User>((row) => row.user)
        .toList(growable: false);

    for (var voter in voters) {
      var decision = questionSessionResults
          .firstWhereOrNull((element) => element.userId == voter.id);
      decisions.putIfAbsent(
        voter.getShortName(),
        () => decision == null ? 'н/д' : decision.result,
      );
    }

    var isQuorumSuccess =
        questionSession.usersCountRegistred >= meeting.group!.quorumCount;
    var isVotingSuccess = questionSession.usersCountVotedYes >=
        questionSession.usersCountForSuccess;

    var isManagerDecides = false;

    // check is manager vote was casting vote
    if (meeting.group!.isManagerCastingVote &&
        (DecisionModeHelper.getEnumValue(questionSession.decision) ==
            DecisionMode.MajorityOfRegistredMembers) &&
        (questionSession.usersCountVotedYes ==
            questionSession.usersCountVotedNo) &&
        (questionSession.usersCountVotedYes ==
            questionSession.usersCountForSuccess)) {
      var managerDecision = questionSessionResults.firstWhereOrNull(
          (element) => element.userId == questionSession.managerId);

      if (managerDecision != null && managerDecision.result == 'ПРОТИВ') {
        isVotingSuccess = false;
        isManagerDecides = true;
      }
      if (managerDecision != null && managerDecision.result == 'ЗА') {
        isVotingSuccess = true;
        isManagerDecides = true;
      }
    }

    var questionName = meeting.toString() +
        ' ' +
        DateFormat('dd.MM.yy').format(
            (meetingSession.startDate ?? TimeUtil.getDateTimeNow(_timeOffset))
                .toLocal()) +
        ' ' +
        question.toString() +
        ' ' +
        DateFormat('HH:mm').format(questionSession.startDate.toLocal()) +
        '-' +
        DateFormat('HH:mm').format(
            (questionSession.endDate ?? TimeUtil.getDateTimeNow(_timeOffset))
                .toLocal());

    VotingHistory votingHistory = VotingHistory(
        questionName,
        isQuorumSuccess,
        isVotingSuccess,
        isManagerDecides,
        questionSession.usersCountVoted,
        questionSession.usersCountVotedYes,
        questionSession.usersCountVotedNo,
        questionSession.usersCountVotedIndiffirent,
        questionSession.usersCountForSuccess,
        questionSession.usersCountForSuccessDisplay,
        isDetailed,
        decisions);
    Provider.of<WebSocketConnection>(_context, listen: false)
        .setHistory(votingHistory);
  }

  String getMeetingSessionText(MeetingSession session) {
    var meeting = _meetings
        .firstWhereOrNull((element) => element.id == session.meetingId);

    if (session.endDate == null && session.startDate == null) {
      return meeting.toString();
    }

    if (session.endDate == null) {
      return meeting.toString() +
          ' (' +
          DateFormat('dd.MM.yyyy HH:mm').format(
              (session.startDate ?? TimeUtil.getDateTimeNow(_timeOffset))
                  .toLocal()) +
          ')';
    }

    return meeting.toString() +
        ' (' +
        DateFormat('dd.MM.yyyy HH:mm').format(
            (session.startDate ?? TimeUtil.getDateTimeNow(_timeOffset))
                .toLocal()) +
        ' - ' +
        DateFormat('dd.MM.yyyy HH:mm').format(
            (session.endDate ?? TimeUtil.getDateTimeNow(_timeOffset))
                .toLocal()) +
        ')';
  }

  String getQuestionSessionText(QuestionSession questionSession) {
    var meetingSession = _meetingSessions.firstWhereOrNull(
        (element) => element.id == questionSession.meetingSessionId);
    var meeting = _meetings
        .firstWhereOrNull((element) => element.id == meetingSession?.meetingId);

    var question = meeting!.agenda!.questions.firstWhereOrNull(
        (element) => element.id == questionSession.questionId);

    if (question == null) {
      return '';
    }

    return question.toString() +
        ' (' +
        DateFormat('dd.MM.yyyy HH:mm')
            .format(questionSession.startDate.toLocal()) +
        ' - ' +
        DateFormat('dd.MM.yyyy HH:mm').format(
            (questionSession.endDate ?? TimeUtil.getDateTimeNow(_timeOffset))
                .toLocal()) +
        ')';
  }
}
