import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:http/http.dart' as http;
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import '../Providers/WebSocketConnection.dart';
import 'meeting.dart';
import '../Controls/controls.dart';

class MeetingsPage extends StatefulWidget {
  final Settings settings;
  final int timeOffset;
  final Meeting selectedMeeting;

  MeetingsPage(this.settings, this.timeOffset, this.selectedMeeting, {Key key})
      : super(key: key);

  @override
  _MeetingsPageState createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  List<Meeting> _meetings;
  List<MeetingSession> _meetingSessions;
  List<VotingMode> _votingModes;
  bool _isLoadingComplete = false;

  static const int sortName = 0;
  static const int sortStartDate = 1;
  static const int sortEndDate = 2;
  bool _isAscending = true;
  int _sortType = sortName;

  var _tecSearch = TextEditingController();
  var _fnSearch = FocusNode();
  String _searchExpression = '';
  List<Meeting> _filteredMeetings = <Meeting>[];

  @override
  void initState() {
    super.initState();

    loadMeetings();
  }

  void loadMeetings({bool sortInternal = false}) {
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/meetings"))
        .then((response) => {
              setState(() {
                _meetings = (json.decode(response.body) as List)
                    .map((data) => Meeting.fromJson(data))
                    .toList();
              })
            })
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/meeting_sessions"))
            .then((response) => {
                  setState(() {
                    _meetingSessions = (json.decode(response.body) as List)
                        .map((data) => MeetingSession.fromJson(data))
                        .toList();
                    processSearch('');
                  })
                }))
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/voting_modes"))
            .then((response) => {
                  setState(() {
                    _votingModes = (json.decode(response.body) as List)
                        .map((data) => VotingMode.fromJson(data))
                        .toList();
                    if (_votingModes.length > 0) {
                      _votingModes
                          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
                    }
                  })
                }))
        .then((value) {
      if (sortInternal) {
        sortMeetingsInternal();
      } else {
        sortMeetings(_sortType);
      }

      _isLoadingComplete = true;
    });
  }

  void _addNewItem() {
    _navigateMeetingPage(-1);
  }

  void _navigateMeetingPage(int index) {
    var meeting = index == -1
        ? Meeting(
            name: '',
            description:
                widget.settings.storeboardSettings.meetingDescriptionTemplate,
            lastUpdated: TimeUtil.getDateTimeNow(widget.timeOffset),
          )
        : _filteredMeetings[index];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MeetingPage(
                meeting: meeting,
                timeOffset: widget.timeOffset))).then((value) {
      _tecSearch.text = '';
      loadMeetings(sortInternal: true);
    });
  }

  Future<void> restartMeeting(int index) async {
    var meeting = _filteredMeetings[index];
    meeting.status = 'Ожидание';

    // close existing meetingSessions
    for (var session in _meetingSessions) {
      if (session.meetingId == meeting.id) {
        var shouldUpdate = false;

        if (session.startDate == null) {
          shouldUpdate = true;
          session.startDate = DateTime.now();
          session.endDate = DateTime.now();
        }

        if (session.endDate == null) {
          shouldUpdate = true;
          session.endDate = DateTime.now();
        }

        if (shouldUpdate) {
          await http.put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/meeting_sessions/${meeting.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(session.toJson()));
        }
      }
    }

    var connection = Provider.of<WebSocketConnection>(context, listen: false);

    if (widget.selectedMeeting?.id == meeting.id) {
      // deselect meeting if it was selected
      connection.setSystemStatus(
          SystemState.MeetingCompleted,
          json.encode({
            'meeting_id': meeting.id,
          }));
    }

    // restart meeting
    await http.put(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/meetings/${meeting.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(meeting.toJson()));

    loadMeetings(sortInternal: true);
  }

  void sortMeetings(int sortType) {
    _sortType = sortType;
    _isAscending = !_isAscending;

    sortMeetingsInternal();
  }

  void sortMeetingsInternal() {
    if (_sortType == sortName) {
      _meetings.sort((a, b) {
        return a.name.compareTo(b.name) * (_isAscending ? 1 : -1);
      });
    }
    if (_sortType == sortStartDate) {
      _meetings.sort((a, b) {
        var meetingSessionsA = _meetingSessions
            .where((element) => element.meetingId == a.id)
            .toList();
        MeetingSession lastSessionA;
        if (meetingSessionsA.length > 0) {
          meetingSessionsA.sort((a, b) => a.id.compareTo(b.id));
          lastSessionA = meetingSessionsA.last;
        }

        var meetingSessionsB = _meetingSessions
            .where((element) => element.meetingId == b.id)
            .toList();
        MeetingSession lastSessionB;
        if (meetingSessionsB.length > 0) {
          meetingSessionsB.sort((a, b) => a.id.compareTo(b.id));
          lastSessionB = meetingSessionsB.last;
        }

        return (lastSessionA?.startDate ?? DateTime.utc(-271821, 04, 20))
                .compareTo(
                    lastSessionB?.startDate ?? DateTime.utc(-271821, 04, 20)) *
            (_isAscending ? 1 : -1);
      });
    }

    if (_sortType == sortEndDate) {
      _meetings.sort((a, b) {
        var meetingSessionsA = _meetingSessions
            .where((element) => element.meetingId == a.id)
            .toList();
        MeetingSession lastSessionA;
        if (meetingSessionsA.length > 0) {
          meetingSessionsA.sort((a, b) => a.id.compareTo(b.id));
          lastSessionA = meetingSessionsA.last;
        }

        var meetingSessionsB = _meetingSessions
            .where((element) => element.meetingId == b.id)
            .toList();
        MeetingSession lastSessionB;
        if (meetingSessionsB.length > 0) {
          meetingSessionsB.sort((a, b) => a.id.compareTo(b.id));
          lastSessionB = meetingSessionsB.last;
        }

        return (lastSessionA?.endDate ?? DateTime.utc(-271821, 04, 20))
                .compareTo(
                    lastSessionB?.endDate ?? DateTime.utc(-271821, 04, 20)) *
            (_isAscending ? 1 : -1);
      });
    }

    processSearch(_searchExpression);
    setState(() {});
  }

  void removeMeeting(int index) {
    var meeting = _filteredMeetings[index];
    var meetingId = meeting.id;

    http.delete(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/meetings/$meetingId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).then((value) => loadMeetings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Заседания'),
        centerTitle: true,
        actions: <Widget>[
          Tooltip(
            message: 'Добавить',
            child: TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
              ),
              onPressed: _addNewItem,
              child: Icon(Icons.add),
            ),
          ),
          Container(
            width: 20,
          ),
        ],
      ),
      body: _isLoadingComplete
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
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
                                        setState(() {
                                          _tecSearch.clear();
                                          processSearch(_tecSearch.text);
                                        });
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                  ),
                          ),
                          onSubmitted: (value) {
                            _fnSearch.requestFocus();
                            processSearch(value);
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
                            processSearch(_tecSearch.text);
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
                _getMeetingsTable(),
              ],
            )
          : CommonWidgets().getLoadingStub(),
    );
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _filteredMeetings = _meetings
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }

  Widget _getMeetingsTable() {
    return Container(
      child: HorizontalDataTable(
        verticalScrollbarStyle: ScrollbarStyle(
          isAlwaysShown: true,
        ),
        leftHandSideColumnWidth: 0,
        rightHandSideColumnWidth: MediaQuery.of(context).size.width,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: TableHelper().generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: _filteredMeetings.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
      ),
      height: MediaQuery.of(context).size.height - 126,
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      Container(
        height: 0.0,
        width: 0,
      ),
      Container(
        color: Colors.grey[350],
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  overlayColor: MaterialStateProperty.all(Colors.black12),
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                ),
                child: Container(
                  child: TableHelper().getTitleItemWidget(
                      'Название' +
                          (_sortType == sortName
                              ? (_isAscending ? '↓' : '↑')
                              : ''),
                      null),
                  height: 56,
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  _isAscending = !_isAscending;
                  sortMeetings(sortName);
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Повестка', 5),
            TableHelper().getTitleItemWidget('Группа', 5),
            Expanded(
              flex: 5,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  overlayColor: MaterialStateProperty.all(Colors.black12),
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                ),
                child: TableHelper().getTitleItemWidget(
                    (_sortType == sortStartDate
                            ? (_isAscending ? '↓' : '↑')
                            : '') +
                        'Дата начала',
                    null),
                onPressed: () {
                  sortMeetings(sortStartDate);
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  overlayColor: MaterialStateProperty.all(Colors.black12),
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                ),
                child: TableHelper().getTitleItemWidget(
                    (_sortType == sortEndDate
                            ? (_isAscending ? '↓' : '↑')
                            : '') +
                        'Дата окончания',
                    null),
                onPressed: () {
                  sortMeetings(sortEndDate);
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Последнее изменение', 5),
            TableHelper().getTitleItemWidget('Статус', 5),
            Container(
              child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
              width: 217,
              height: 56,
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              alignment: Alignment.centerLeft,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    var meetingSessions = _meetingSessions
        .where((element) => element.meetingId == _filteredMeetings[index].id)
        .toList();
    var lastSession;
    if (meetingSessions.length > 0) {
      meetingSessions.sort((a, b) => a.id.compareTo(b.id));
      lastSession = meetingSessions.last;
    }

    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            child: Text(_filteredMeetings[index].name),
            height: 52,
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(_filteredMeetings[index].agenda?.name ?? ''),
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(_filteredMeetings[index].group?.name ?? ''),
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: lastSession?.startDate == null
                ? Container()
                : Text(DateFormat('dd.MM.yyyy').format(lastSession.startDate)),
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: lastSession?.endDate == null
                ? Container()
                : Text(DateFormat('dd.MM.yyyy').format(lastSession.endDate)),
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(DateFormat('dd.MM.yyyy HH:mm:ss')
                .format(_filteredMeetings[index].lastUpdated.toLocal())),
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(_filteredMeetings[index].status),
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Container(
          width: 217,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Tooltip(
                message: 'Протокол заседания',
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.black12),
                    shape: MaterialStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  child: Icon(Icons.list_alt, color: Colors.blue),
                  onPressed: () {
                    _getMeetingReport(index);
                  },
                ),
              ),
              _filteredMeetings[index].status == 'Ожидание' &&
                      meetingSessions.length == 0
                  ? Tooltip(
                      message: 'Редактировать',
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          shape: MaterialStateProperty.all(
                            CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        child: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _navigateMeetingPage(index);
                        },
                      ),
                    )
                  : Expanded(
                      child: Container(),
                    ),
              _filteredMeetings[index].status != 'Ожидание'
                  ? Tooltip(
                      message: 'Разблокировать',
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          shape: MaterialStateProperty.all(
                            CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        child: Icon(Icons.refresh, color: Colors.blue),
                        onPressed: () async {
                          await restartMeeting(index);
                        },
                      ),
                    )
                  : Expanded(
                      child: Container(),
                    ),
              _filteredMeetings[index].status == 'Ожидание' ||
                      _filteredMeetings[index].status == 'Завершено'
                  ? Tooltip(
                      message: 'Удалить',
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          shape: MaterialStateProperty.all(
                            CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        child: Icon(Icons.delete, color: Colors.black87),
                        onPressed: () async {
                          var noButtonPressed = false;
                          var title = 'Удалить заседание';

                          await Utility().showYesNoDialog(
                            context,
                            title: title,
                            message: TextSpan(
                              text:
                                  'Вы уверены, что хотите ${title.toLowerCase()}?',
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
                            return;
                          }

                          removeMeeting(index);
                        },
                      ),
                    )
                  : Container(),
              Container(
                width: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Yaroslavl
  void _getMeetingReport(int index) async {
    var isReportCompleted = false;
    var meeting = _filteredMeetings[index];
    var reportDirectory =
        widget.settings.questionListSettings.reportsFolderPath +
            '/' +
            meeting.name;

    try {
      var registrationSessionsResponse = await http.get(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/registrationsessions/${meeting.id}"),
      );

      var registrationSessions =
          (json.decode(registrationSessionsResponse.body) as List)
              .map((data) => RegistrationSession.fromJson(data))
              .toList();

      var usersResponse = await http.get(
        Uri.http(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"),
      );
      var users = (json.decode(usersResponse.body) as List)
          .map((data) => User.fromJson(data))
          .toList();

      // delete previous reports directory
      if (await Directory(reportDirectory).exists()) {
        await Directory(reportDirectory).delete(recursive: true);
      }
      // create new report directory
      await Directory(reportDirectory).create();

      // Generate meeting session reports
      var meetingSessions = _meetingSessions
          .where((element) => element.meetingId == _filteredMeetings[index].id)
          .toList();

      for (var i = 0; i < meetingSessions.length; i++) {
        var currentRegistrationSessions = <RegistrationSession>[];
        for (var j = 0; j < registrationSessions.length; j++) {
          if (registrationSessions[j].startDate.microsecondsSinceEpoch >
                  meetingSessions[i].startDate.microsecondsSinceEpoch &&
              registrationSessions[j].endDate.microsecondsSinceEpoch <
                  (meetingSessions[i].endDate?.microsecondsSinceEpoch ??
                      TimeUtil.getDateTimeNow(widget.timeOffset)
                          .microsecondsSinceEpoch))
            currentRegistrationSessions.add(registrationSessions[j]);
        }

        var questionSessionsResponse = await http.get(
          Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
              "/questionsessions/${meetingSessions[i].id}"),
        );
        var questionSessions =
            (json.decode(questionSessionsResponse.body) as List)
                .map((data) => QuestionSession.fromJson(data))
                .toList();

        for (int j = 0; j < questionSessions.length; j++) {
          var registrationSession = currentRegistrationSessions.firstWhere(
              (element) =>
                  element.endDate.microsecondsSinceEpoch <
                  questionSessions[j].endDate.microsecondsSinceEpoch,
              orElse: () => null);

          var question = meeting.agenda.questions.firstWhere(
              (element) => element.id == questionSessions[j].questionId,
              orElse: () => null);
          var votingMode = _votingModes.firstWhere(
              (element) => element.id == questionSessions[j].votingModeId,
              orElse: () => null);

          if (registrationSession != null && question != null) {
            var reportText = <String>[];
            var sessionEndDate = meetingSessions[i].endDate?.toLocal() ??
                TimeUtil.getDateTimeNow(widget.timeOffset);

            var meetingNumber = meeting.name.split(' ').first;

            reportText.add('${meeting.group.name}');
            reportText.add(
                '${DateFormat('HH:mm dd.MM.yyyy').format(sessionEndDate)}');
            reportText.add('\n');
            reportText.add('ПРОТОКОЛ № $j');
            reportText.add('счётной комиссии о поименном голосовании');
            reportText.add('\n');
            reportText.add('Процедурное голосование.');
            reportText.add('${AgendaUtil.getQuestionDescription(question)}');

            reportText.add(
                'Установленное число депутатов \t\t ${meeting.group.lawUsersCount}');
            reportText.add(
                'Число избранных депутатов на 30.05.2023 \t ${meeting.group.chosenCount}');
            reportText.add(
                'Кворум для начала заседания \t\t\t ${meeting.group.quorumCount}');

            reportText.add(registrationSession.registrations.length >=
                    meeting.group.quorumCount
                ? 'Кворум есть'
                : 'Кворум нет');

            List<String> votedYesNames = <String>[];
            List<String> votedNoNames = <String>[];
            List<String> votedIndifferentNames = <String>[];

            for (var groupUser in meeting.group.groupUsers) {
              var user = users.firstWhere(
                  (element) => element.id == groupUser.user.id,
                  orElse: () => null);
              var result = questionSessions[j].results.firstWhere(
                  (element) => element.userId == groupUser.user.id,
                  orElse: () => null);

              if (user == null || result == null) {
                continue;
              }

              if (result.result == 'ЗА') {
                votedYesNames.add(user.getFullName());
              } else if (result.result == 'ПРОТИВ') {
                votedNoNames.add(user.getFullName());
              } else if (result.result == 'ВОЗДЕРЖАЛСЯ') {
                votedIndifferentNames.add(user.getFullName());
              }
            }
            reportText.add('\n');
            reportText.add('Проголосовали «ЗА» \t\t\t ${votedYesNames.length}');
            reportText.addAll(votedYesNames);
            reportText.add('\n');
            reportText
                .add('Проголосовали «ПРОТИВ» \t\t ${votedNoNames.length}');
            reportText.addAll(votedNoNames);
            reportText.add('\n');
            reportText
                .add('ВОЗДЕРЖАЛИСЬ \t\t\t\t ${votedIndifferentNames.length}');
            reportText.addAll(votedIndifferentNames);
            reportText.add('\n');
            reportText.add(
                'Всего проголосовало \t\t\t ${questionSessions[j].results.length}');
            reportText.add(
                'Для принятия решения необходимо \t ${questionSessions[j].usersCountForSuccessDisplay}');

            reportText.add(questionSessions[j].usersCountVotedYes >=
                    questionSessions[j].usersCountForSuccess
                ? 'РЕШЕНИЕ ПРИНЯТО'
                : 'РЕШЕНИЕ НЕ ПРИНЯТО');

            var managerGroupUser = meeting.group.groupUsers.firstWhere(
                (element) => element.isManager == true,
                orElse: () => null);
            var managerUser = users.firstWhere(
                (element) => element.id == managerGroupUser.user.id,
                orElse: () => null);
            reportText.add(
                'Председатель счётной комиссии \t\t\t ${managerUser.getShortName()}');

            // save report
            final file = reportDirectory +
                '/Протокол_${j}_${meeting.name}_${DateFormat('HH:mm').format(sessionEndDate)}.txt';
            await File(file).writeAsString(reportText.join('\r\n'));
          }
        }

        isReportCompleted = true;
      }
    } catch (exc) {
      Utility().showMessageOkDialog(context,
          title: 'Ошибка экспорта протокола',
          message: TextSpan(
            text:
                'В ходе экспорта протокола возникла ошибка: ${exc.toString()}',
          ),
          okButtonText: 'Ок');
    } finally {
      if (isReportCompleted == true) {
        Utility().showMessageOkDialog(context,
            title: 'Экспорт протокола',
            message: TextSpan(
              text:
                  'Экспорт протокола успешно завершен.\r\nДиректория отчета: $reportDirectory',
            ),
            okButtonText: 'Ок');
      }
    }
  }

  // // Adygea
  // void _getMeetingReport(int index) async {
  //   var isReportCompleted = false;
  //   var meeting = _filteredMeetings[index];
  //   var reportDirectory =
  //       widget.settings.questionListSettings.reportsFolderPath +
  //           '/' +
  //           meeting.name;

  //   try {
  //     var registrationSessionsResponse = await http.get(
  //       Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //           "/registrationsessions/${meeting.id}"),
  //     );

  //     var registrationSessions =
  //         (json.decode(registrationSessionsResponse.body) as List)
  //             .map((data) => RegistrationSession.fromJson(data))
  //             .toList();

  //     var usersResponse = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"));
  //     var users = (json.decode(usersResponse.body) as List)
  //         .map((data) => User.fromJson(data))
  //         .toList();

  //     // delete previous reports directory
  //     if (await Directory(reportDirectory).exists()) {
  //       await Directory(reportDirectory).delete(recursive: true);
  //     }
  //     // create new report directory
  //     await Directory(reportDirectory).create();

  //     // Generate meeting session reports
  //     var meetingSessions = _meetingSessions
  //         .where((element) => element.meetingId == _filteredMeetings[index].id)
  //         .toList();

  //     for (var i = 0; i < meetingSessions.length; i++) {
  //       var currentRegistrationSessions = <RegistrationSession>[];
  //       for (var j = 0; j < registrationSessions.length; j++) {
  //         if (registrationSessions[j].startDate.microsecondsSinceEpoch >
  //                 meetingSessions[i].startDate.microsecondsSinceEpoch &&
  //             registrationSessions[j].endDate.microsecondsSinceEpoch <
  //                 (meetingSessions[i].endDate?.microsecondsSinceEpoch ??
  //                     TimeUtil.getDateTimeNow(widget.timeOffset)
  //                         .microsecondsSinceEpoch))
  //           currentRegistrationSessions.add(registrationSessions[j]);
  //       }

  //       var questionSessionsResponse = await http.get(
  //         Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //             "/questionsessions/${meetingSessions[i].id}"),
  //       );
  //       var questionSessions =
  //           (json.decode(questionSessionsResponse.body) as List)
  //               .map((data) => QuestionSession.fromJson(data))
  //               .toList();

  //       for (int j = 0; j < questionSessions.length; j++) {
  //         var registrationSession = currentRegistrationSessions.firstWhere(
  //             (element) =>
  //                 element.endDate.microsecondsSinceEpoch <
  //                 questionSessions[j].endDate.microsecondsSinceEpoch,
  //             orElse: () => null);

  //         var question = meeting.agenda.questions.firstWhere(
  //             (element) => element.id == questionSessions[j].questionId,
  //             orElse: () => null);
  //         var votingMode = _votingModes.firstWhere(
  //             (element) => element.id == questionSessions[j].votingModeId,
  //             orElse: () => null);

  //         if (registrationSession != null && question != null) {
  //           var reportText = <String>[];
  //           var sessionEndDate = meetingSessions[i].endDate.toLocal() ??
  //               TimeUtil.getDateTimeNow(widget.timeOffset);

  //           var meetingNumber = meeting.name.split(' ').first;

  //           reportText.add('-${j}-');
  //           reportText.add('ПРОТОКОЛ № ${j}');
  //           reportText.add('голосования на ${meetingNumber} заседании');
  //           reportText.add('Государственного Совета-Хасэ Республики Адыгея');
  //           reportText.add('\r\n');
  //           reportText.add('ПРИНЯТИЕ ПОВЕСТКИ ДНЯ ЗА ОСНОВУ');
  //           reportText.add('по вопросу:');
  //           reportText.add('${question.name}');

  //           reportText.add('\r\n');
  //           reportText.add(
  //               'Время ${DateFormat('HH:mm').format(questionSessions[j].startDate.toLocal())}. Дата ${DateFormat('dd.MM.yyyy').format(questionSessions[j].startDate.toLocal())}');
  //           reportText.add('Вид голосования: ${votingMode.name.toUpperCase()}');

  //           reportText.add('\r\n');
  //           reportText.add(
  //               'Зарегистрированно: ${registrationSession.registrations.length}');
  //           reportText.add(
  //               'По доверенности: ${questionSessions[j].results.where((element) => element.proxyId != null).length}');
  //           reportText.add('\r\n');

  //           var votingItem = <String>[
  //             'За \t\t ${questionSessions[j].usersCountVotedYes}\t${((100 * questionSessions[j].usersCountVotedYes) / meeting.group.chosenCount).toStringAsFixed(1)}%',
  //             'Против \t ${questionSessions[j].usersCountVotedNo}\t${((100 * questionSessions[j].usersCountVotedNo) / meeting.group.chosenCount).toStringAsFixed(1)}%',
  //             'Воздержались \t ${questionSessions[j].usersCountVotedIndiffirent}\t${((100 * questionSessions[j].usersCountVotedIndiffirent) / meeting.group.chosenCount).toStringAsFixed(1)}%',
  //           ];
  //           reportText.addAll(votingItem);
  //           reportText.add('\r\n');

  //           var votedYesNames = '';
  //           var votedNoNames = '';
  //           var votedIndifferentNames = '';
  //           var noVotedNames = '';
  //           for (var groupUser in meeting.group.groupUsers) {
  //             var user = users.firstWhere(
  //                 (element) => element.id == groupUser.user.id,
  //                 orElse: () => null);
  //             var result = questionSessions[j].results.firstWhere(
  //                 (element) => element.userId == groupUser.user.id,
  //                 orElse: () => null);

  //             if (result?.result == 'ЗА') {
  //               votedYesNames += votedYesNames.isEmpty ? '' : ', ';
  //               votedYesNames += user?.getShortName();
  //             } else if (result?.result == 'ПРОТИВ') {
  //               votedNoNames += votedNoNames.isEmpty ? '' : ', ';
  //               votedNoNames += user?.getShortName();
  //             } else if (result?.result == 'ВОЗДЕРЖАЛСЯ') {
  //               votedIndifferentNames +=
  //                   votedIndifferentNames.isEmpty ? '' : ', ';
  //               votedIndifferentNames += user?.getShortName();
  //             } else {
  //               noVotedNames += noVotedNames.isEmpty ? '' : ', ';
  //               noVotedNames += user?.getShortName();
  //             }
  //           }
  //           var namedItem = <String>[
  //             'За: $votedYesNames',
  //             'Против: $votedNoNames',
  //             '',
  //             'Воздержались: $votedIndifferentNames',
  //             '',
  //             'Не голосовали: $noVotedNames',
  //           ];
  //           reportText.addAll(namedItem);
  //           reportText.add('\r\n');
  //           reportText.add('Голосовало ${questionSessions[j].results.length}');
  //           reportText.add(
  //               'Не голосовало ${meeting.group.chosenCount - questionSessions[j].results.length}');

  //           reportText.add('\r\n');

  //           reportText.add(questionSessions[j].usersCountVotedYes >=
  //                   questionSessions[j].usersCountForSuccess
  //               ? 'Решение: ПРИНЯТО'
  //               : 'Решение: НЕ ПРИНЯТО');

  //           var footer = <String>[
  //             '',
  //             'Итоги подведены на основе данных электронной системы ведения заседаний.',
  //             '',
  //             widget.settings.reportSettings.reportFooter,
  //           ];

  //           reportText.addAll(footer);

  //           // save report
  //           final file = reportDirectory +
  //               '/Протокол_${j}_${meeting.name}_${DateFormat('HH:mm').format(sessionEndDate)}.txt';
  //           await File(file).writeAsString(reportText.join('\r\n'));
  //         }
  //       }

  //       isReportCompleted = true;
  //     }
  //   } catch (exc) {
  //     Utility().showMessageOkDialog(context,
  //         title: 'Ошибка экспорта протокола',
  //         message: TextSpan(
  //           text:
  //               'В ходе экспорта протокола возникла ошибка: ${exc.toString()}',
  //         ),
  //         okButtonText: 'Ок');
  //   } finally {
  //     if (isReportCompleted == true) {
  //       Utility().showMessageOkDialog(context,
  //           title: 'Экспорт протокола',
  //           message: TextSpan(
  //             text:
  //                 'Экспорт протокола успешно завершен.\r\nДиректория отчета: $reportDirectory',
  //           ),
  //           okButtonText: 'Ок');
  //     }
  //   }
  // }

  // void _getMeetingReport(int index) async {
  //   var isReportCompleted = false;
  //   var meeting = _filteredMeetings[index];
  //   var reportDirectory =
  //       widget.settings.questionListSettings.reportsFolderPath +
  //           '/' +
  //           meeting.name;

  //   try {
  //     var registrationSessionsResponse = await http.get(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
  //             "/registrationsessions/${meeting.id}");

  //     var registrationSessions =
  //         (json.decode(registrationSessionsResponse.body) as List)
  //             .map((data) => RegistrationSession.fromJson(data))
  //             .toList();

  //     var usersResponse = await http.get(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()) + "/users");
  //     var users = (json.decode(usersResponse.body) as List)
  //         .map((data) => User.fromJson(data))
  //         .toList();

  //     // delete previous reports directory
  //     if (await Directory(reportDirectory).exists()) {
  //       await Directory(reportDirectory).delete(recursive: true);
  //     }
  //     // create new report directory
  //     await Directory(reportDirectory).create();

  //     var managerGroupUser = meeting.group.groupUsers.firstWhere(
  //         (element) => element.isManager == true,
  //         orElse: () => null);
  //     var managerUser = users.firstWhere(
  //         (element) => element.id == managerGroupUser.user.id,
  //         orElse: () => null);

  //     // Generate meeting session reports
  //     var meetingSessions = _meetingSessions
  //         .where((element) => element.meetingId == _filteredMeetings[index].id)
  //         .toList();

  //     for (var i = 0; i < meetingSessions.length; i++) {
  //       var reportCommon = <String>[];
  //       var reportNamed = <String>[];

  //       var sessionStartDate = meetingSessions[i].startDate.toLocal() ??
  //           TimeUtil.getDateTimeNow(widget.timeOffset);
  //       var sessionEndDate = meetingSessions[i].endDate.toLocal() ??
  //           TimeUtil.getDateTimeNow(widget.timeOffset);

  //       var header = <String>[
  //         DateFormat('dd.MM.yyyy').format(sessionStartDate),
  //         DateFormat('HH:mm').format(sessionStartDate),
  //         meeting.name,
  //         'Председатель: ${managerUser.getShortName(isInverted: true)}',
  //         getReportSeparator(),
  //       ];
  //       reportCommon.addAll(header);
  //       reportNamed.addAll(header);

  //       var currentRegistrationSessions = <RegistrationSession>[];
  //       for (var j = 0; j < registrationSessions.length; j++) {
  //         if (registrationSessions[j].startDate.microsecondsSinceEpoch >
  //                 meetingSessions[i].startDate.microsecondsSinceEpoch &&
  //             registrationSessions[j].endDate.microsecondsSinceEpoch <
  //                 (meetingSessions[i].endDate?.microsecondsSinceEpoch ??
  //                     TimeUtil.getDateTimeNow(widget.timeOffset)
  //                         .microsecondsSinceEpoch))
  //           currentRegistrationSessions.add(registrationSessions[j]);
  //       }

  //       var questionSessionsResponse = await http.get(
  //           ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
  //               "/questionsessions/${meetingSessions[i].id}");
  //       var questionSessions =
  //           (json.decode(questionSessionsResponse.body) as List)
  //               .map((data) => QuestionSession.fromJson(data))
  //               .toList();

  //       Question previousQuestion;
  //       for (int j = 0; j < questionSessions.length; j++) {
  //         var registrationSession = currentRegistrationSessions.firstWhere(
  //             (element) =>
  //                 element.endDate.microsecondsSinceEpoch <
  //                 questionSessions[j].endDate.microsecondsSinceEpoch,
  //             orElse: () => null);

  //         var question = meeting.agenda.questions.firstWhere(
  //             (element) => element.id == questionSessions[j].questionId,
  //             orElse: () => null);
  //         var votingMode = _votingModes.firstWhere(
  //             (element) => element.id == questionSessions[j].votingModeId,
  //             orElse: () => null);

  //         if (registrationSession != null && question != null) {
  //           if (previousQuestion != question) {
  //             var descriptionItem = <String>[
  //               DateFormat('HH:mm')
  //                       .format(questionSessions[j].startDate.toLocal()) +
  //                   ' Обсуждается ${question.toString()}',
  //               question.getReportDescription(),
  //               getReportSeparator(),
  //             ];
  //             reportCommon.addAll(descriptionItem);
  //             reportNamed.addAll(descriptionItem);
  //           }
  //           previousQuestion = question;

  //           var votingItem = <String>[
  //             DateFormat('HH:mm')
  //                     .format(questionSessions[j].startDate.toLocal()) +
  //                 ' Открытое голосование ${question.toString()}',
  //             votingMode.name,
  //             questionSessions[j].decision,
  //             ' ВСЕГО - ${meeting.group.chosenCount}',
  //             ' ПРИСУТСТВУЕТ - ${registrationSession.registrations.length}',
  //             ' ГОЛОСОВАЛО - ${questionSessions[j].results.length}',
  //             'ЗА - ${questionSessions[j].usersCountVotedYes} ' +
  //                 'ПРОТИВ - ${questionSessions[j].usersCountVotedNo} ' +
  //                 'ВОЗД - ${questionSessions[j].usersCountVotedIndiffirent}',
  //             questionSessions[j].usersCountVotedYes >=
  //                     questionSessions[j].usersCountForSuccess
  //                 ? 'Решение принято'
  //                 : 'Решение не принято',
  //           ];
  //           reportCommon.addAll(votingItem);
  //           reportNamed.addAll(votingItem);

  //           var votedYesNames = '';
  //           var votedNoNames = '';
  //           var votedIndifferentNames = '';
  //           var noVotedNames = '';
  //           for (var groupUser in meeting.group.groupUsers) {
  //             var user = users.firstWhere(
  //                 (element) => element.id == groupUser.user.id,
  //                 orElse: () => null);
  //             var result = questionSessions[j].results.firstWhere(
  //                 (element) => element.userId == groupUser.user.id,
  //                 orElse: () => null);

  //             if (result?.result == 'ЗА') {
  //               votedYesNames += votedYesNames.isEmpty ? '' : ', ';
  //               votedYesNames += user?.getShortName();
  //             } else if (result?.result == 'ПРОТИВ') {
  //               votedNoNames += votedNoNames.isEmpty ? '' : ', ';
  //               votedNoNames += user?.getShortName();
  //             } else if (result?.result == 'ВОЗДЕРЖАЛСЯ') {
  //               votedIndifferentNames +=
  //                   votedIndifferentNames.isEmpty ? '' : ', ';
  //               votedIndifferentNames += user?.getShortName();
  //             } else {
  //               noVotedNames += noVotedNames.isEmpty ? '' : ', ';
  //               noVotedNames += user?.getShortName();
  //             }
  //           }

  //           var namedItem = <String>[
  //             'За:\r\n\r\n$votedYesNames',
  //             '\r\n',
  //             'Против:\r\n\r\n$votedNoNames',
  //             '\r\n',
  //             'Воздержались:\r\n\r\n$votedIndifferentNames',
  //             '\r\n',
  //             'Не голосовали:\r\n\r\n$noVotedNames',
  //           ];
  //           reportNamed.addAll(namedItem);

  //           reportCommon.add(getReportSeparator());
  //           reportNamed.add(getReportSeparator());
  //         }
  //       }

  //       var footer = <String>[
  //         DateFormat('dd.MM.yyyy HH:mm').format(sessionStartDate) +
  //             ' ${meeting.name} ' +
  //             'закрыто',
  //         'Председатель Ивановской областной Думы \t\t' +
  //             managerUser.getShortName(isInverted: true),
  //       ];
  //       reportCommon.addAll(footer);
  //       reportNamed.addAll(footer);

  //       // save report
  //       final fileCommon = reportDirectory +
  //           '/Протокол_${meeting.name}_${DateFormat('HH:mm').format(sessionEndDate)}.txt';
  //       await File(fileCommon).writeAsString(reportCommon.join('\r\n'));

  //       // save report
  //       final fileNamed = reportDirectory +
  //           '/Протокол_поименно_${meeting.name}_${DateFormat('HH:mm').format(sessionEndDate)}.txt';
  //       await File(fileNamed).writeAsString(reportNamed.join('\r\n'));

  //       isReportCompleted = true;
  //     }
  //   } catch (exc) {
  //     Utility().showMessageOkDialog(context,
  //         title: 'Ошибка экспорта протокола',
  //         message: TextSpan(
  //           text:
  //               'В ходе экспорта протокола возникла ошибка: ${exc.toString()}',
  //         ),
  //         okButtonText: 'Ок');
  //   } finally {
  //     if (isReportCompleted == true) {
  //       Utility().showMessageOkDialog(context,
  //           title: 'Экспорт протокола',
  //           message: TextSpan(
  //             text:
  //                 'Экспорт протокола успешно завершен.\r\nДиректория отчета: $reportDirectory',
  //           ),
  //           okButtonText: 'Ок');
  //     }
  //   }
  // }

  String getReportSeparator() {
    return '--------------------------------------';
  }
}
