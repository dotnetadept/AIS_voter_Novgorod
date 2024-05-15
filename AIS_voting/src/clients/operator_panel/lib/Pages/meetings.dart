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
import '../Utility/report_helper.dart';
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
  int _sortType = sortStartDate;

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
                  onPressed: () async {
                    await ReportHelper().getMeetingReport(
                        context,
                        _filteredMeetings[index],
                        widget.settings,
                        widget.timeOffset,
                        _votingModes);
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
}
