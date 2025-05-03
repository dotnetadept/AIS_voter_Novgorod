import 'dart:convert';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/widgets.dart';
import 'package:operator_panel/Dialogs/initialvotes_dialog.dart';

import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../Providers/AppState.dart';
import '../Providers/WebSocketConnection.dart';
import 'package:ais_model/ais_model.dart' as ais;

import '../Utility/report_helper.dart';

class VotingDialog {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _tecInterval;
  late TextEditingController _tecTempAskWordQueueInterval;

  ScrollController _votingOptionsScrollController = ScrollController();
  ScrollController _votingDecisionsScrollController = ScrollController();
  ScrollController _proxyTableScrollController = ScrollController();

  BuildContext _context;
  Settings _settings;

  Meeting? _selectedMeeting;
  late Question _lockedQuestion;
  List<VotingMode> _votingModes;
  VotingMode _selectedVotingMode;
  DecisionMode _selectedDecisionMode;
  late int _selectedSuccessValue;
  late WebSocketConnection _connection;

  bool _isVotingStarted = false;
  bool _isAskQueueStarted = false;
  late ais.Interval _interval;
  late ais.Interval _tempAskWordQueueInterval;

  List<Proxy> _proxies;
  Map<String, String> _initialChoices = Map<String, String>();
  bool _isInitialChoisesSet = false;

  VotingDialog(
    this._context,
    this._settings,
    this._selectedMeeting,
    this._lockedQuestion,
    this._votingModes,
    this._selectedVotingMode,
    this._selectedDecisionMode,
    this._proxies,
  ) {
    _connection = Provider.of<WebSocketConnection>(_context, listen: false);
    var serverState = Provider.of<WebSocketConnection>(_context, listen: false)
        .getServerState;

    _interval = AppState().getIntervals().firstWhere((element) =>
        element.id == _settings.intervalsSettings.defaultVotingIntervalId);
    _tempAskWordQueueInterval = AppState().getIntervals().firstWhere(
        (element) =>
            element.id ==
            _settings.intervalsSettings.defaultAskWordQueueIntervalId);
    _isAskQueueStarted = serverState.systemState == SystemState.AskWordQueue;
    _tecInterval = TextEditingController(text: _interval.duration.toString());
    _tecTempAskWordQueueInterval = TextEditingController(
        text: _tempAskWordQueueInterval.duration.toString());
  }

  Future<void> openDialog() async {
    return showAlignedDialog<void>(
        context: _context,
        barrierDismissible: false,
        barrierColor: Colors.black12,
        offset: Offset(-_settings.storeboardSettings.width / 2, 0),
        targetAnchor: Alignment.centerRight,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateForDialog) {
              AppState().refreshDialog = ((f) {
                var serverState =
                    Provider.of<WebSocketConnection>(_context, listen: false)
                        .getServerState;
                _isVotingStarted =
                    serverState.systemState == SystemState.QuestionVoting;
                _isAskQueueStarted =
                    serverState.systemState == SystemState.AskWordQueue;
                int selectedQuestionId =
                    json.decode(serverState.params)['selectedQuestion'];
                _lockedQuestion = _selectedMeeting!.agenda!.questions
                    .firstWhere((element) => element.id == selectedQuestionId);
                setStateForDialog(f);
              });

              bool isQuestionNavigationDisabled =
                  _connection.getServerState.systemState ==
                      SystemState.QuestionVoting;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _settings.storeboardSettings.width.toDouble(),
                  minWidth: _settings.storeboardSettings.width.toDouble(),
                  maxHeight:
                      1080 - _settings.storeboardSettings.height.toDouble(),
                  minHeight:
                      1080 - _settings.storeboardSettings.height.toDouble(),
                ),
                child: AlertDialog(
                  insetPadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  titlePadding: EdgeInsets.all(0),
                  actionsPadding: EdgeInsets.all(10),
                  title: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          color: Colors.lightBlue,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Tooltip(
                                message: 'Показать предыдущий вопрос',
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        isQuestionNavigationDisabled
                                            ? WidgetStateProperty.all(
                                                Colors.black26)
                                            : WidgetStateProperty.all(
                                                Colors.blueAccent),
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  child: Icon(Icons.navigate_before),
                                  onPressed: isQuestionNavigationDisabled
                                      ? null
                                      : () {
                                          var nextQuestionIndex =
                                              _selectedMeeting!
                                                      .agenda!.questions
                                                      .indexOf(
                                                          _lockedQuestion) -
                                                  1;

                                          if (nextQuestionIndex >= 0) {
                                            _connection.setSystemStatus(
                                                SystemState.QuestionLocked,
                                                json.encode({
                                                  'question_id':
                                                      _selectedMeeting!
                                                          .agenda!
                                                          .questions[
                                                              nextQuestionIndex]
                                                          .id,
                                                }));
                                          }
                                        },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Голосование: \r\n${_lockedQuestion.toString()}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: 'Показать вопрос',
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        isQuestionNavigationDisabled
                                            ? WidgetStateProperty.all(
                                                Colors.black26)
                                            : WidgetStateProperty.all(
                                                Colors.blueAccent),
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  child: Icon(Icons.remove_red_eye),
                                  onPressed: isQuestionNavigationDisabled
                                      ? null
                                      : () {
                                          _connection.setSystemStatus(
                                              SystemState.QuestionLocked,
                                              json.encode({
                                                'question_id':
                                                    _lockedQuestion.id,
                                              }));
                                        },
                                ),
                              ),
                              Tooltip(
                                message: 'Показать результаты поименно',
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: _connection
                                                .getServerState.systemState !=
                                            SystemState.QuestionVotingComplete
                                        ? WidgetStateProperty.all(
                                            Colors.black26)
                                        : WidgetStateProperty.all(
                                            Colors.blueAccent),
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.list,
                                    color: _connection
                                            .getServerState.isDetailsStoreboard
                                        ? Colors.red
                                        : Colors.white,
                                  ),
                                  onPressed:
                                      _connection.getServerState.systemState !=
                                              SystemState.QuestionVotingComplete
                                          ? null
                                          : () {
                                              _connection.setDetailsResult(
                                                  !_connection.getServerState
                                                      .isDetailsStoreboard);

                                              setStateForDialog(() {});
                                            },
                                ),
                              ),
                              Tooltip(
                                message: 'Показать следующий вопрос',
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        isQuestionNavigationDisabled
                                            ? WidgetStateProperty.all(
                                                Colors.black26)
                                            : WidgetStateProperty.all(
                                                Colors.blueAccent),
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  child: Icon(Icons.navigate_next),
                                  onPressed: isQuestionNavigationDisabled
                                      ? null
                                      : () {
                                          var nextQuestionIndex =
                                              _selectedMeeting!
                                                      .agenda!.questions
                                                      .indexOf(
                                                          _lockedQuestion) +
                                                  1;

                                          if (nextQuestionIndex <
                                              _selectedMeeting!
                                                  .agenda!.questions.length) {
                                            _connection.setSystemStatus(
                                                SystemState.QuestionLocked,
                                                json.encode({
                                                  'question_id':
                                                      _selectedMeeting!
                                                          .agenda!
                                                          .questions[
                                                              nextQuestionIndex]
                                                          .id,
                                                }));
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AgendaUtil.getQuestionDescriptionText(
                          _lockedQuestion,
                          16,
                          showHiddenSections: true,
                        ),
                        Row(
                          children: [
                            getMeetingRegimSelector((value) {
                              _settings.votingSettings.votingRegim = value;
                            }, _settings.votingSettings.votingRegim,
                                setStateForDialog),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                        Container(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: TextFormField(
                                  controller: _tecInterval,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Время голосования, с:',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите время голосования';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Введите целое число';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            (!_settings.deputySettings.useTempAskWordQueue)
                                ? Container()
                                : Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 0, 10),
                                      child: TextFormField(
                                        controller:
                                            _tecTempAskWordQueueInterval,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText:
                                              'Время записи в очередь, с:',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Введите время записи в очередь';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Введите целое число';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 10,
                                child: Column(
                                  children: [
                                    getVotingModesHeader(),
                                    Expanded(
                                      child: getVotingModes(setStateForDialog),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 18,
                                child: Column(
                                  children: [
                                    getDecisionModesHeader(),
                                    Expanded(
                                      child:
                                          getDecisionModes(setStateForDialog),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 14, 10),
                                child: TextButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Закрыть',
                                        style: TextStyle(fontSize: 23),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              _settings.deputySettings.useTempAskWordQueue
                                  ? !_isAskQueueStarted
                                      ? Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 13, 10),
                                          child: TextButton(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Очередь',
                                                  style:
                                                      TextStyle(fontSize: 23),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              if (_formKey.currentState
                                                      ?.validate() !=
                                                  true) {
                                                return;
                                              }

                                              var interval = int.tryParse(
                                                  _tecTempAskWordQueueInterval
                                                      .text);

                                              _connection.getWsChannel.sink
                                                  .add(json.encode({
                                                'systemState': EnumToString
                                                    .convertToString(SystemState
                                                        .AskWordQueue),
                                                'params': json.encode({
                                                  'question_id':
                                                      _lockedQuestion!.id,
                                                  'askwordqueue_interval':
                                                      interval,
                                                  'voting_mode_id':
                                                      _selectedVotingMode.id,
                                                  'voting_decision':
                                                      DecisionModeHelper
                                                          .getStringValue(
                                                              _selectedDecisionMode),
                                                  'startSignal': json.encode(
                                                      _tempAskWordQueueInterval
                                                          .startSignal),
                                                  'endSignal': json.encode(
                                                      _tempAskWordQueueInterval
                                                          .endSignal),
                                                  'autoEnd':
                                                      _tempAskWordQueueInterval
                                                          .isAutoEnd,
                                                }),
                                              }));

                                              setStateForDialog(() {
                                                _isAskQueueStarted = true;
                                              });
                                            },
                                          ),
                                        )
                                      : Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 13, 10),
                                          child: TextButton(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Остановить',
                                                  style:
                                                      TextStyle(fontSize: 23),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              _connection.setSystemStatus(
                                                  SystemState
                                                      .AskWordQueueCompleted,
                                                  json.encode({
                                                    'question_id':
                                                        _lockedQuestion!.id,
                                                  }));

                                              setStateForDialog(() {
                                                _isAskQueueStarted = false;
                                              });
                                            },
                                          ),
                                        )
                                  : Container(),
                            ],
                          ),
                        ),
                        _isVotingStarted
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: TextButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Завершить голосование',
                                        style: TextStyle(fontSize: 23),
                                      ),
                                      Container(width: 4),
                                      Icon(
                                        Icons.touch_app,
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    _connection.setSystemStatus(
                                        SystemState.QuestionVotingComplete,
                                        json.encode({
                                          'question_id': _lockedQuestion!.id,
                                        }));

                                    _initialChoices.clear();
                                    _isInitialChoisesSet = false;

                                    setStateForDialog(() {
                                      _isVotingStarted = false;
                                    });
                                  },
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 10),
                                child: TextButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Начать голосование',
                                        style: TextStyle(fontSize: 23),
                                      ),
                                      Container(width: 28),
                                      Icon(Icons.touch_app),
                                    ],
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() !=
                                        true) {
                                      return;
                                    }

                                    _connection.setClearDecisions();

                                    await InitialVotesDialog(
                                      context,
                                      _settings,
                                      _selectedMeeting,
                                      _lockedQuestion,
                                      _proxies,
                                      Map<String, String>.from(_initialChoices),
                                      setInitialChoices,
                                    ).openDialog();

                                    var interval =
                                        int.tryParse(_tecInterval.text);

                                    _connection.getWsChannel.sink
                                        .add(json.encode({
                                      'systemState':
                                          EnumToString.convertToString(
                                              SystemState.QuestionVoting),
                                      'params': json.encode({
                                        'question_id': _lockedQuestion!.id,
                                        'voting_interval': interval,
                                        'voting_mode_id':
                                            _selectedVotingMode.id,
                                        'voting_decision':
                                            DecisionModeHelper.getStringValue(
                                                _selectedDecisionMode),
                                        'voting_regim': _settings
                                            .votingSettings.votingRegim,
                                        'success_count': _selectedSuccessValue,
                                        'startSignal':
                                            json.encode(_interval.startSignal),
                                        'endSignal':
                                            json.encode(_interval.endSignal),
                                        'autoEnd': _interval.isAutoEnd,
                                        'initial_choices':
                                            json.encode(_initialChoices),
                                      }),
                                    }));

                                    setStateForDialog(() {
                                      _isVotingStarted = true;
                                    });
                                  },
                                ),
                              ),
                      ],
                    ),
                    // getInitialChoisesButton(
                    //   context,
                    //   setStateForDialog,
                    // ),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget getMeetingRegimSelector(
    void setValue(String value),
    String interval,
    Function setState,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: Row(
        children: [
          Text('Вид голосования:'),
          Container(
            width: 20,
          ),
          DropdownButton<String>(
            value: interval,
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
                  setValue(newValue);
                });
              }
            },
            items: <String>['Поименное', 'Тайное']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget getInitialChoisesButton(BuildContext context, Function setState) {
  //   return TextButton(
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Tooltip(
  //           message: _isInitialChoisesSet
  //               ? 'Предварительное голосование: есть'
  //               : 'Предварительное голосование: нет',
  //           child: Row(
  //             children: [
  //               Text(
  //                 'Предварительное голосование',
  //                 style: TextStyle(fontSize: 23),
  //               ),
  //               Container(
  //                 width: 10,
  //               ),
  //               Icon(
  //                 Icons.touch_app,
  //                 color: _isInitialChoisesSet ? Colors.green : Colors.white,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //     onPressed:
  //         _connection.getServerState.systemState == SystemState.QuestionVoting
  //             ? null
  //             : () {
  //                 InitialVotesDialog(
  //                   context,
  //                   _settings,
  //                   _selectedMeeting,
  //                   _lockedQuestion,
  //                   _proxies,
  //                   Map<String, String>.from(_initialChoices),
  //                   setInitialChoices,
  //                 ).openDialog().then((e) {
  //                   setState(() {});
  //                 });
  //               },
  //   );
  // }

  void setInitialChoices(Map<String, String> initalChoices) {
    _initialChoices = initalChoices;
    _isInitialChoisesSet = true;
  }

  Widget getVotingModesHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            padding: EdgeInsets.fromLTRB(10, 3, 10, 0),
            height: 65,
            color: Colors.lightBlue,
            child: Text(
              'Режимы голосования',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget getVotingModes(Function setStateForDialog) {
    if (_votingModes == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _votingOptionsScrollController,
        child: SingleChildScrollView(
          controller: _votingOptionsScrollController,
          child: DataTable(
            headingRowHeight: 0,
            columnSpacing: 0,
            horizontalMargin: 10,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                label: Container(),
              ),
            ],
            rows: _votingModes
                .map(
                  ((element) => DataRow(
                        color: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (element == _selectedVotingMode) {
                            return Theme.of(_context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3);
                          }
                          return Colors.transparent;
                        }),
                        cells: <DataCell>[
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  // constraints: BoxConstraints(
                                  //     minWidth: 260, maxWidth: 260),
                                  child: Wrap(
                                    children: [
                                      Text(element.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        selected: element == _selectedVotingMode,
                        onSelectChanged: (bool? value) {
                          if (value == true) {
                            setStateForDialog(() {
                              _selectedVotingMode = element;
                              _selectedDecisionMode =
                                  DecisionModeHelper.getEnumValue(
                                      _selectedVotingMode.defaultDecision);
                            });
                          }
                        },
                      )),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget getDecisionModesHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            color: Colors.lightBlue,
            child: Text(
              'Принятие решения',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget getDecisionModes(Function setStateForVotingDialog) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _votingDecisionsScrollController,
      child: SingleChildScrollView(
        controller: _votingDecisionsScrollController,
        child: Column(
          children: <Widget>[
            getDecisionModeItem(
                setStateForVotingDialog, DecisionMode.MajorityOfLawMembers),
            getDecisionModeItem(
                setStateForVotingDialog, DecisionMode.TwoThirdsOfLawMembers),
            getDecisionModeItem(
                setStateForVotingDialog, DecisionMode.OneThirdsOfLawMembers),
            getDecisionModeItem(
                setStateForVotingDialog, DecisionMode.MajorityOfChosenMembers),
            getDecisionModeItem(
                setStateForVotingDialog, DecisionMode.TwoThirdsOfChosenMembers),
            getDecisionModeItem(
                setStateForVotingDialog, DecisionMode.OneThirdsOfChosenMembers),
            getDecisionModeItem(setStateForVotingDialog,
                DecisionMode.MajorityOfRegistredMembers),
            getDecisionModeItem(setStateForVotingDialog,
                DecisionMode.TwoThirdsOfRegistredMembers),
            getDecisionModeItem(setStateForVotingDialog,
                DecisionMode.OneThirdsOfRegistredMembers),
          ],
        ),
      ),
    );
  }

  Widget getDecisionModeItem(
      Function setStateForVotingDialog, DecisionMode mode) {
    if (!_selectedVotingMode.includedDecisions
        .contains(DecisionModeHelper.getStringValue(mode) + ';')) {
      return Container();
    }

    var successValue = DecisionModeHelper.getSuccuessValue(
        mode,
        _selectedMeeting!.group!,
        _connection.getServerState.usersRegistered,
        false);
    if (mode == _selectedDecisionMode) {
      setStateForVotingDialog(() {
        _selectedSuccessValue = successValue;
      });
    }

    return RadioListTile<DecisionMode>(
      title: Text('${DecisionModeHelper.getStringValue(mode)} ($successValue)'),
      value: mode,
      contentPadding: EdgeInsets.all(1),
      groupValue: _selectedDecisionMode,
      onChanged: (DecisionMode? value) {
        if (value != null) {
          setStateForVotingDialog(() {
            _selectedDecisionMode = value;
            _selectedSuccessValue = successValue;
          });
        }
      },
    );
  }
}
