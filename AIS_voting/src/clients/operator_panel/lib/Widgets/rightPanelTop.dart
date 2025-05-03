import 'dart:convert';

import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/agenda_util.dart';
import 'package:ais_utils/dialogs.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:operator_panel/Providers/AppState.dart';
import 'package:operator_panel/Widgets/rigthPanelMenu.dart';
import 'package:provider/provider.dart';

import '../Dialogs/voting_dialog.dart';
import '../Providers/WebSocketConnection.dart';
import 'package:ais_model/ais_model.dart' as ais;

class RightPanelTop extends StatefulWidget {
  final Settings settings;
  final List<Meeting> meetings;
  final Meeting? selectedMeeting;
  final Question? lockedQuestion;
  final Question? selectedQuestion;
  final List<VotingMode> votingModes;
  final List<User> users;
  final List<Proxy> proxies;

  final int timeOffset;
  final void Function(Meeting meeting) changeSelectedMeeting;
  final void Function(ais.Interval? interval) setInterval;
  final void Function(bool? autoEnd) setAutoEnd;
  final void Function(String) addGuestAskWord;
  final void Function(String) removeGuestAskWord;
  final void Function(int) addUserAskWord;
  final void Function(int) removeUserAskWord;

  RightPanelTop({
    Key? key,
    required this.settings,
    required this.users,
    required this.meetings,
    required this.selectedMeeting,
    required this.lockedQuestion,
    required this.selectedQuestion,
    required this.votingModes,
    required this.timeOffset,
    required this.changeSelectedMeeting,
    required this.setInterval,
    required this.setAutoEnd,
    required this.addGuestAskWord,
    required this.removeGuestAskWord,
    required this.addUserAskWord,
    required this.removeUserAskWord,
    required this.proxies,
  }) : super(key: key);

  @override
  _RightPanelTopState createState() => _RightPanelTopState();
}

class _RightPanelTopState extends State<RightPanelTop> {
  late WebSocketConnection _connection;
  ScrollController agendaViewScrollController = ScrollController();
  ScrollController questionDescriptionScrollController = ScrollController();
  late ScrollController agendaTableScrollController;

  Meeting? _selectedMeeting;
  late VotingMode _selectedVotingMode;
  late String _selectedDecision;
  Question? _selectedQuestion;

  @override
  void initState() {
    super.initState();

    _selectedMeeting = widget.selectedMeeting;
    _selectedQuestion = widget.selectedQuestion;
    _selectedVotingMode = widget.votingModes.firstWhere(
        (element) =>
            element.id == widget.settings.votingSettings.defaultVotingModeId,
        orElse: () {
      return widget.votingModes.first;
    });
    _selectedDecision = _selectedVotingMode.defaultDecision;

    var scrollPosition = 0.0;

    if (_selectedMeeting != null && widget.lockedQuestion != null) {
      scrollPosition = _selectedMeeting!.agenda!.questions.indexOf(
                  widget.selectedMeeting!.agenda!.questions.firstWhere(
                      (element) => element.id == widget.lockedQuestion?.id)) *
              45.0 -
          90;
    }

    if (scrollPosition < 0) {
      scrollPosition = 0.0;
    }

    agendaTableScrollController =
        ScrollController(initialScrollOffset: scrollPosition);
  }

  @override
  Widget build(BuildContext context) {
    _connection = Provider.of<WebSocketConnection>(context, listen: true);

    if (widget.selectedMeeting == null) {
      _selectedMeeting = null;
      _selectedQuestion = null;
    }

    return Expanded(
      child: Column(
        children: [
          Stack(
            children: <Widget>[
              RightPanelMenu(
                settings: widget.settings,
                users: widget.users,
                selectedMeeting: _selectedMeeting,
                lockedQuestion: widget.lockedQuestion,
                selectedQuestion: _selectedQuestion,
                timeOffset: widget.timeOffset,
                setInterval: widget.setInterval,
                setAutoEnd: widget.setAutoEnd,
                addGuestAskWord: widget.addGuestAskWord,
                removeGuestAskWord: widget.removeGuestAskWord,
                addUserAskWord: widget.addUserAskWord,
                removeUserAskWord: widget.removeUserAskWord,
              ),
              _connection.getServerState.systemState ==
                      SystemState.QuestionVoting
                  ? Container(
                      width:
                          widget.settings.storeboardSettings.width.toDouble(),
                      height: 119,
                      color: Colors.black12)
                  : Container(height: 0),
            ],
          ),
          Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: getMeetingSelector(),
              ),
              _connection.getServerState.systemState ==
                      SystemState.QuestionVoting
                  ? Container(
                      width:
                          widget.settings.storeboardSettings.width.toDouble(),
                      height: 68,
                      color: Colors.black12)
                  : Container(height: 0),
            ],
          ),
          Expanded(
            child: Stack(children: <Widget>[
              getAgendaView(),
              _connection.getServerState.systemState ==
                      SystemState.QuestionVoting
                  ? Container(color: Colors.black12)
                  : Container(height: 0),
            ]),
          ),
          Container(
            height: 152.0,
            child: Column(
              children: [
                Expanded(
                  child: Container(),
                ),
                getVotingButton(),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getMeetingSelector() {
    bool isEnabled = _selectedMeeting == null ||
        !(SystemStateHelper.isStarted(_connection.getServerState.systemState) ||
            SystemStateHelper.isPreparation(
                _connection.getServerState.systemState));
    return DropdownSearch<Meeting>(
      // mode: Mode.DIALOG,
      // showSearchBox: true,
      // showClearButton: true,
      items: (filter, infiniteScrollProps) => widget.meetings
          .where((element) => element.status == 'Ожидание')
          .toList(),
      // label: 'Заседание',
      // searchBoxDecoration: InputDecoration(fillColor: Colors.red),
      enabled: isEnabled,

      // dropDownButton: isEnabled ? null : Container(),
      // clearButton: isEnabled ? null : Container(),
      // popupTitle: Container(
      //     alignment: Alignment.center,
      //     color: Colors.blueAccent,
      //     padding: EdgeInsets.all(10),
      //     child: Text(
      //       'Заседания',
      //       style: TextStyle(
      //           fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      //     )),
      // hint: 'Выберите заседание',
      suffixProps: DropdownSuffixProps(
          clearButtonProps: ClearButtonProps(isVisible: isEnabled),
          dropdownButtonProps: DropdownButtonProps(isVisible: isEnabled)),
      selectedItem: widget.meetings
          .firstWhereOrNull((element) => element.id == _selectedMeeting?.id),
      onChanged: (value) {
        setState(() {
          if (value != null) {
            value.agenda!.questions
                .sort((a, b) => a.orderNum.compareTo(b.orderNum));
          }
          _selectedMeeting = value;
          if (_selectedMeeting != null) {
            _connection.setMeetingPreviev(_selectedMeeting!.id);
            if (_selectedMeeting!.agenda!.questions.length > 0) {
              _selectedMeeting!.agenda!.questions
                  .sort((a, b) => a.orderNum.compareTo(b.orderNum));
              _selectedQuestion = _selectedMeeting!.agenda!.questions.first;
            }
          }
        });

        widget.changeSelectedMeeting(_selectedMeeting!);
      },
      dropdownBuilder: meetingDropDownBuilder,
      popupProps: PopupProps.menu(
        itemBuilder: meetingPopupItemBuilder,
      ),
      compareFn: (item1, item2) {
        return item1 == item2;
      },
      //emptyBuilder: emptyBuilder,
    );
  }

  Widget meetingPopupItemBuilder(
      BuildContext context, Meeting item, bool isDisabled, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Text(
          item.toString(),
          style: TextStyle(fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
            ),
            Row(
              children: [
                Text('группа: ', style: TextStyle(fontWeight: FontWeight.w700)),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        item.group.toString(),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('повестка: ',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        item.agenda.toString(),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('статус: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        item.status,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget meetingDropDownBuilder(BuildContext context, Meeting? item) {
    return Container(
      child: (item == null)
          ? ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Заседание не выбрано"),
            )
          : ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Tooltip(
                  message: 'группа: ' +
                      item.group.toString() +
                      '\n' +
                      'повестка: ' +
                      item.agenda.toString() +
                      '\n' +
                      'статус: ' +
                      item.status,
                  child: Text(item.toString())),
            ),
    );
  }

  Widget emptyBuilder(BuildContext context, String? text) {
    return Center(child: Text('Нет подходящих заседаний'));
  }

  Widget getVotingModesSelector() {
    return DropdownButton<VotingMode>(
      value: _selectedVotingMode,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (VotingMode? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedVotingMode = newValue;
          });
        }
      },
      items: widget.votingModes
          .map<DropdownMenuItem<VotingMode>>((VotingMode value) {
        return DropdownMenuItem<VotingMode>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }

  Widget getDecisionModesSelector() {
    return DropdownButton<String>(
      value: _selectedDecision,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedDecision = newValue;
          });
        }
      },
      items: <String>[
        DecisionModeHelper.getStringValue(DecisionMode.MajorityOfLawMembers),
        DecisionModeHelper.getStringValue(DecisionMode.TwoThirdsOfLawMembers),
        DecisionModeHelper.getStringValue(DecisionMode.OneThirdsOfLawMembers),
        DecisionModeHelper.getStringValue(DecisionMode.MajorityOfChosenMembers),
        DecisionModeHelper.getStringValue(
            DecisionMode.TwoThirdsOfChosenMembers),
        DecisionModeHelper.getStringValue(
            DecisionMode.OneThirdsOfChosenMembers),
        DecisionModeHelper.getStringValue(
            DecisionMode.MajorityOfRegistredMembers),
        DecisionModeHelper.getStringValue(
            DecisionMode.TwoThirdsOfRegistredMembers),
        DecisionModeHelper.getStringValue(
            DecisionMode.OneThirdsOfRegistredMembers),
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  Widget getVotingView() {
    return Column(
      children: [
        getVotingModesSelector(),
        getDecisionModesSelector(),
      ],
    );
  }

  Widget getAgendaView() {
    return Scrollbar(
      thumbVisibility: true,
      controller: agendaViewScrollController,
      child: SingleChildScrollView(
        controller: agendaViewScrollController,
        child: Column(
          children: <Widget>[
            _selectedMeeting == null ? Container() : getAgendaTable(),
            _selectedMeeting == null
                ? Container()
                : getSelectedQuestionDescription(),
          ],
        ),
      ),
    );
  }

  Widget getAgendaTable() {
    bool isBigView = MediaQuery.of(context).size.height >= 1050;
    var agendaTableHeight = isBigView ? 279.0 : 141.0;
    var agendaTableScrollOffset = isBigView ? 90.0 : 45.0;

    if (_connection.getServerState.systemState == SystemState.QuestionVoting) {
      var index = _selectedMeeting!.agenda!.questions.indexOf(widget
          .selectedMeeting!.agenda!.questions
          .firstWhere((element) => element.id == widget.lockedQuestion!.id));
      var scrollPosition = 45.0 * index - agendaTableScrollOffset;
      if (scrollPosition < 0) {
        scrollPosition = 0;
      }

      // ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
      if (agendaTableScrollController.positions.length > 0) {
        if (scrollPosition >
            agendaTableScrollController.positions.first.maxScrollExtent) {
          scrollPosition =
              agendaTableScrollController.positions.first.maxScrollExtent;
        }
        if (agendaViewScrollController.positions.length > 0) {
          agendaViewScrollController.jumpTo(0.0);
        }
        agendaTableScrollController.jumpTo(scrollPosition);
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      constraints: BoxConstraints(
          minHeight: agendaTableHeight,
          minWidth: double.infinity,
          maxHeight: agendaTableHeight),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.green),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          controller: agendaTableScrollController,
          child: SingleChildScrollView(
            controller: agendaTableScrollController,
            child: DataTable(
              dataRowHeight: 45,
              headingRowHeight: 0,
              columnSpacing: 0,
              horizontalMargin: 10,
              showCheckboxColumn: false,
              columns: [
                DataColumn(label: Text('Повестка')),
              ],
              rows: _selectedMeeting!.agenda!.questions
                  .map(
                    ((element) => DataRow(
                          color: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (element.id == widget.lockedQuestion?.id) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3);
                            }
                            if (element == _selectedQuestion) {
                              return Colors.grey.withOpacity(0.3);
                            }
                            return Colors.transparent;
                          }),
                          cells: <DataCell>[
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        minWidth: 260, maxWidth: 260),
                                    child: Wrap(
                                      children: [
                                        Text(element.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: true),
                                      ],
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  !(SystemStateHelper.isStarted(_connection
                                          .getServerState.systemState))
                                      ? Container()
                                      : Tooltip(
                                          message: 'Показать',
                                          child: TextButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.black12),
                                              shape: WidgetStateProperty.all(
                                                CircleBorder(
                                                    side: BorderSide(
                                                        color: Colors
                                                            .transparent)),
                                              ),
                                              padding: WidgetStateProperty.all(
                                                  EdgeInsets.all(0)),
                                            ),
                                            onPressed: widget
                                                    .settings
                                                    .votingSettings
                                                    .isVotingFixed
                                                ? () {}
                                                : () {
                                                    lockQuestion(element);
                                                  },
                                            child: Icon(
                                              Icons.remove_red_eye,
                                              color: element.id ==
                                                      widget.lockedQuestion?.id
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                          selected: element == _selectedQuestion,
                          onSelectChanged: (bool? value) {
                            if (value == true) {
                              setSelectedQuestion(element);
                            }
                          },
                        )),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget getVotingButton() {
    return Column(
      children: [
        Row(
          children: [
            _connection.getServerState.systemState == SystemState.QuestionVoting
                ? Container()
                : Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all(Size(
                            (widget.settings.storeboardSettings.width - 20)
                                .toDouble(),
                            100)),
                      ),
                      onPressed: _startVoting,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              'Голосование',
                              softWrap: true,
                              style: TextStyle(fontSize: 32),
                              maxLines: 1,
                            ),
                          ),
                          Icon(
                            Icons.touch_app,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
            _connection.getServerState.systemState != SystemState.QuestionVoting
                ? Container()
                : Padding(
                    padding: EdgeInsets.all(10),
                    child: TextButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all(Size(
                            (widget.settings.storeboardSettings.width - 20)
                                .toDouble(),
                            100)),
                      ),
                      onPressed: () => {endVoting()},
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              children: [
                                AutoSizeText(
                                  'Завершить голосование',
                                  softWrap: true,
                                  style: TextStyle(fontSize: 28),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.touch_app,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  Widget getSelectedQuestionDescription() {
    var questionDescriptionHeight = 175.0;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      constraints: BoxConstraints(
          minHeight: questionDescriptionHeight,
          minWidth: double.infinity,
          maxHeight: questionDescriptionHeight),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 2, color: Colors.green),
            right: BorderSide(width: 2, color: Colors.green),
            bottom: BorderSide(width: 2, color: Colors.green),
          ),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          controller: questionDescriptionScrollController,
          child: SingleChildScrollView(
            controller: questionDescriptionScrollController,
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: _connection.getServerState.systemState ==
                      SystemState.QuestionVoting
                  ? getVotingResult()
                  : AgendaUtil.getQuestionDescriptionText(
                      _selectedQuestion,
                      14,
                      showHiddenSections: true,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getVotingResult() {
    var votedYes = _connection.getServerState.usersDecisions.values
        .where((element) => element == 'ЗА')
        .length;
    var votedNo = _connection.getServerState.usersDecisions.values
        .where((element) => element == 'ПРОТИВ')
        .length;
    var indifferentCount = _connection.getServerState.usersDecisions.values
        .where((element) => element == 'ВОЗДЕРЖАЛСЯ')
        .length;
    var totalVotes = _connection.getServerState.usersDecisions.values
        .where((element) => element != 'СБРОС')
        .length;

    if (widget.settings.votingSettings.isCountNotVotingAsIndifferent) {
      totalVotes = widget.selectedMeeting!.group!.groupUsers.length;
      indifferentCount = totalVotes - votedYes - votedNo;
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: getVotingResultLine('Присутствует',
              '${_connection.getServerState.usersRegistered.length}',
              fontSize: 16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 9, 0, 0),
          child: getVotingResultLine('Всего проголосовало', '$totalVotes',
              fontSize: 16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 9, 0, 0),
          child: getVotingResultLine('Для принятия решения необходимо',
              '${_connection.getServerState.questionSession!.usersCountForSuccessDisplay}',
              fontSize: 16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 9, 0, 0),
          child: getVotingResultLine('ЗА', '$votedYes', fontSize: 16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 9, 0, 0),
          child: getVotingResultLine('ПРОТИВ', '$votedNo', fontSize: 16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 9, 0, 0),
          child: getVotingResultLine('ВОЗДЕРЖАЛИСЬ', '$indifferentCount',
              fontSize: 16),
        ),
      ],
    );
  }

  Widget getVotingResultLine(String caption, String value,
      {double fontSize = 24}) {
    return Row(
      children: [
        Text(
          caption,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
        Expanded(child: Container()),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _startVoting() {
    if (_selectedMeeting == null) {
      Utility().showMessageOkDialog(context,
          title: 'Заседание не выбрано',
          message: TextSpan(
            text: 'Отсутствует начатое заседание',
          ),
          okButtonText: 'Ок');
      return;
    }
    if (!(SystemStateHelper.isStarted(
        _connection.getServerState.systemState))) {
      Utility().showMessageOkDialog(context,
          title: 'Заседание не начато',
          message: TextSpan(
            text: 'Текущее заседание не начато',
          ),
          okButtonText: 'Ок');
      return;
    }
    if (widget.votingModes.length == 0) {
      Utility().showMessageOkDialog(context,
          title: 'Отсутвуют режимы голосования',
          message: TextSpan(
            text: 'Добавьте режимы голосования в настройки голосования',
          ),
          okButtonText: 'Ок');
      return;
    }

    if (!_connection.getServerState.isRegistrationCompleted) {
      Utility().showMessageOkDialog(context,
          title: 'Необходима регистрация',
          message: TextSpan(
            text: 'Проведите регистрацию',
          ),
          okButtonText: 'Ок');
      return;
    }

    if (widget.lockedQuestion == null) {
      Utility().showMessageOkDialog(context,
          title: 'Вопрос не выбран',
          message: TextSpan(
            text: 'Выберите вопрос для голосования',
          ),
          okButtonText: 'Ок');
      return;
    }

    // fixed voting mode without voting window
    if (widget.settings.votingSettings.isVotingFixed) {
      var interval = AppState().getIntervals().firstWhere((element) =>
          element.id ==
          widget.settings.intervalsSettings.defaultVotingIntervalId);
      _connection.getWsChannel.sink.add(json.encode({
        'systemState': EnumToString.convertToString(SystemState.QuestionVoting),
        'params': json.encode({
          'question_id': widget.lockedQuestion!.id,
          'voting_interval': interval.duration,
          'startSignal': json.encode(interval.startSignal),
          'endSignal': json.encode(interval.endSignal),
          'autoEnd': interval.isAutoEnd,
          'voting_mode_id': _selectedVotingMode.id,
          'voting_decision': _selectedDecision,
          'success_count': DecisionModeHelper.getSuccuessValue(
              DecisionModeHelper.getEnumValue(_selectedDecision),
              _selectedMeeting!.group!,
              _connection.getServerState.usersRegistered,
              false)
        }),
      }));

      return;
    }

    setState(() {});

    VotingDialog(
            context,
            widget.settings,
            _selectedMeeting,
            widget.lockedQuestion!,
            widget.votingModes,
            _selectedVotingMode,
            DecisionModeHelper.getEnumValue(_selectedDecision),
            widget.proxies)
        .openDialog()
        .then((value) {
      AppState().refreshDialog = null;
    });
  }

  void endVoting() {
    _connection.setSystemStatus(
        SystemState.QuestionVotingComplete,
        json.encode({
          'question_id': widget.lockedQuestion!.id,
        }));
  }

  void lockQuestion(Question question) {
    _connection.setSystemStatus(
        SystemState.QuestionLocked,
        json.encode({
          'question_id': question.id,
        }));
  }

  void setSelectedQuestion(Question question) {
    setState(() {
      _selectedQuestion = question;
    });
  }

  @override
  void dispose() {
    agendaTableScrollController.dispose();
    agendaViewScrollController.dispose();
    questionDescriptionScrollController.dispose();

    super.dispose();
  }
}
