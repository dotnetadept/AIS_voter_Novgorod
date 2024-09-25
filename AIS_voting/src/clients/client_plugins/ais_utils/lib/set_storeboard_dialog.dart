import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';

import 'model_widgets.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:ais_utils/ais_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:select2dot1/select2dot1.dart';

class SetStoreboardDialog {
  final BuildContext _context;
  final Settings _settings;
  final int _timeOffset;
  final ServerState _serverState;
  final Meeting _meeting;
  final Group _group;
  final bool _isOperatorView;
  final List<ais.Interval> _intervals;

  ais.Interval? _selectedInterval;
  bool? _autoEnd;

  String? _terminalId;
  String? _name;
  late List<StoreboardTemplate> _storeboardTemplates;
  StoreboardTemplate? _selectedStoreboardTemplate;
  StoreboardTemplate? _editStoreboardTemplate;
  StoreboardTemplate? _setStoreboardTemplate;

  GlobalKey<FormState> _formKeySetCustomText = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeySetSpeaker = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeySetBreak = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeyEditTemplate = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeySetTemplate = GlobalKey<FormState>();

  TextEditingController _tecSetStoreboardCaption = TextEditingController();
  late String _captionWidthLabel;
  late bool _captionWidthCorrect;
  TextEditingController _tecSetStoreboardText = TextEditingController();
  late String _textWidthLabel;
  late bool _textWidthCorrect;

  String? _speakerPlace;
  late List<String> _placesForSpeaker;
  String _speakerType = 'Выступление:';
  TextEditingController _tecSpeakerTime = TextEditingController();

  TextEditingController _tecBreak = TextEditingController();
  late DateTime _break;

  late SelectDataController _selectDataController;
  late List<SingleCategoryModel> _exampleData;

  int _currentTabIndex = 0;
  bool _wasError = false;

  late Function _setStateForDialog;

  final Function(
          SpeakerSession speakerSession, Signal startSignal, Signal endSignal)
      _setCurrentSpeaker;
  final Function(StoreboardState state, String params) _setStoreboardState;
  final Function(String terminalID, bool isOn) _setSpeaker;
  final Function() _setFlushNavigation;
  final Function() _setFlushStoreboard;
  final Function(ais.Interval? selectedInterval) _setSelectedInterval;
  final Function(bool? autoEnd) _setAutoEnd;
  final Function(String) _addGuestAskWord;
  final Function(String) _removeGuestAskWord;
  final Function(int) _addUserAskWord;
  final Function(int) _removeUserAskWord;

  bool _isMicActive = false;
  bool _isMicWaiting = false;
  bool _isBlockMicButton = false;
  Map<StoreboardTemplate, TextEditingController> _templateNameControllers =
      new Map<StoreboardTemplate, TextEditingController>();
  Map<StoreboardTemplateItem, TextEditingController> _defaultTextControllers =
      new Map<StoreboardTemplateItem, TextEditingController>();
  Map<StoreboardTemplateItem, TextEditingController> _fontSizeControllers =
      new Map<StoreboardTemplateItem, TextEditingController>();

  Map<StoreboardTemplateItem, TextEditingController> _previewControllers =
      new Map<StoreboardTemplateItem, TextEditingController>();

  SetStoreboardDialog(
      this._context,
      this._serverState,
      this._timeOffset,
      this._settings,
      this._meeting,
      this._group,
      this._intervals,
      this._selectedInterval,
      this._autoEnd,
      this._terminalId,
      this._name,
      this._isOperatorView,
      this._setCurrentSpeaker,
      this._setSpeaker,
      this._setFlushNavigation,
      this._setFlushStoreboard,
      this._setStoreboardState,
      this._setSelectedInterval,
      this._setAutoEnd,
      this._addGuestAskWord,
      this._removeGuestAskWord,
      this._addUserAskWord,
      this._removeUserAskWord) {
    if (_serverState.storeboardParams != null) {
      _tecSetStoreboardCaption.text =
          json.decode(_serverState.storeboardParams!)['caption'];
      _tecSetStoreboardText.text =
          json.decode(_serverState.storeboardParams!)['text'];
    }

    checkCaptionWidth(_tecSetStoreboardCaption.text);
    checkTextHeight(_tecSetStoreboardText.text);

    _placesForSpeaker = List.from(_group.workplaces.tribuneNames);

    if (_terminalId != null) {
      int? speakerId = _serverState.usersTerminals[_terminalId];
      GuestPlace? guest = _serverState.guestsPlaces
          .firstWhereOrNull((element) => element.terminalId == _terminalId);

      if (speakerId != null) {
        _placesForSpeaker.insert(0, 'С места');
        User speaker = _group.groupUsers
            .firstWhere((element) => element.user.id == speakerId)
            .user;
        _name = speaker.getFullName();
      } else if (guest != null) {
        _placesForSpeaker.insert(0, 'С места');
      } else {
        _speakerPlace = getTribuneNameByTerminalId(_terminalId);
      }

      _currentTabIndex = 1;
    }
    if (_name != null) {
      _currentTabIndex = 1;
    }

    if (_placesForSpeaker.length == 0) {
      _placesForSpeaker.add('');
    }

    if (_speakerPlace == null) {
      _speakerPlace = _placesForSpeaker[0];
    }

    _tecSpeakerTime.addListener(() {
      if (_setStateForDialog != null) {
        _setStateForDialog(() {
          if (isAutoEndWidgetDisabled()) {
            _autoEnd = false;
            _setAutoEnd(_autoEnd);
          }
        });
      }
    });

    _tecSpeakerTime.text = _selectedInterval == null
        ? '0'
        : _selectedInterval!.duration.toString();

    _break = roundMinutes(
        TimeUtil.getDateTimeNow(_timeOffset)
            .add(Duration(seconds: _settings.storeboardSettings.breakInterval)),
        5);
    _tecBreak.text = DateFormat('HH:mm').format(_break);

    if (_serverState.storeboardState == StoreboardState.Break) {
      _break =
          DateTime.parse(json.decode(_serverState.storeboardParams!)['break']);
      _currentTabIndex = 2;
    }

    updateMics(_serverState.activeMics, _serverState.waitingMics);

    generateSpeakersList();
  }

  void generateSpeakersList() {
    var selected = null;
    var guestList = <SingleItemCategoryModel>[];
    var guests = (_group.guests ?? '').split(',').toList();
    guests.sort((a, b) => a.compareTo(b));
    for (int i = 0; i < guests.length; i++) {
      guestList.add(
        SingleItemCategoryModel(
          nameSingleItem: guests[i],
          avatarSingleItem: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
          ),
        ),
      );

      if (guests[i].isNotEmpty && guests[i] == _name) {
        selected = guestList.last;
      }
    }

    var deputyList = <SingleItemCategoryModel>[];
    for (int i = 0; i < _group.groupUsers.length; i++) {
      deputyList.add(
        SingleItemCategoryModel(
          nameSingleItem: _group.groupUsers[i].user.getFullName(),
          avatarSingleItem: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
          ),
        ),
      );

      if (_group.groupUsers[i].user.getFullName().isNotEmpty &&
          _group.groupUsers[i].user.getFullName() == _name) {
        selected = deputyList.last;
      }
    }

    _exampleData = [
      SingleCategoryModel(
        nameCategory: 'Депутаты',
        singleItemCategoryList: deputyList,
      ),
      SingleCategoryModel(
        nameCategory: 'Гости',
        singleItemCategoryList: guestList,
      ),
    ];

    _selectDataController = SelectDataController(
      data: _exampleData,
      isMultiSelect: false,
      initSelected: <SingleItemCategoryModel>[selected],
    );
  }

  String? getTerminalIdByTribyneName(String tribuneName) {
    for (var i = 0; i < _group.workplaces.tribuneNames.length; i++) {
      if (_group.workplaces.tribuneNames[i] == tribuneName) {
        return _group.workplaces.tribuneTerminalIds[i];
      }
    }

    return null;
  }

  String? getTribuneNameByTerminalId(String? terminalId) {
    for (var i = 0; i < _group.workplaces.tribuneTerminalIds.length; i++) {
      if (_group.workplaces.tribuneTerminalIds[i] == terminalId) {
        return _group.workplaces.tribuneNames[i];
      }
    }
    return null;
  }

  void update(Map<String, String> activeMics, List<int> waitingMics) {
    _setStateForDialog(() {
      updateMics(activeMics, waitingMics);
    });
  }

  void updateMics(Map<String, String> activeMics, List<int> waitingMics) {
    String? terminalId = _terminalId;

    if (_speakerPlace != null &&
        _group.workplaces.tribuneNames.contains(_speakerPlace)) {
      terminalId = getTerminalIdByTribyneName(_speakerPlace!);
    }

    _isMicActive =
        activeMics.entries.any((element) => element.key == terminalId);

    var parts = <int>[];
    if (terminalId != null) {
      parts = terminalId.split(',').map((e) => int.parse(e)).toList();
    }

    _isMicWaiting = waitingMics.any((element) => parts.contains(element));
  }

  DateTime roundMinutes(DateTime d, int roundInterval) {
    for (int i = 0; i <= (60 / roundInterval).ceil(); i++) {
      if (d.minute <= i * roundInterval) {
        return d.add(Duration(
            milliseconds: -d.millisecond,
            microseconds: -d.microsecond,
            seconds: -d.second,
            minutes: i * roundInterval - d.minute));
      }
    }

    return d;
  }

  Future<void> loadData() async {
    await http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/storeboardtemplates"))
        .then((response) {
      _storeboardTemplates = (json.decode(response.body) as List)
          .map((data) => StoreboardTemplate.fromJson(data))
          .toList();
      _selectedStoreboardTemplate = _storeboardTemplates.first;
    });
  }

  Future<void> openDialog() async {
    await loadData();
    return showDialog<void>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateForDialog) {
              _setStateForDialog = setStateForDialog;
              return AlertDialog(
                title: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                        color: Colors.lightBlue,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Установить табло',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                content: DefaultTabController(
                  length: 4,
                  initialIndex: _currentTabIndex,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 100,
                        width: 800,
                        color: Colors.lightBlueAccent,
                        child: TabBar(
                          onTap: (index) {
                            setStateForDialog(() {
                              _currentTabIndex = index;
                            });
                          },
                          tabs: [
                            Tab(
                              icon: Icon(
                                Icons.add_to_queue,
                                color: _serverState.storeboardState ==
                                        StoreboardState.CustomText
                                    ? Colors.greenAccent
                                    : Colors.white,
                              ),
                              text: 'Произвольный текст',
                            ),
                            Tab(
                              icon: Icon(
                                Icons.speaker,
                                color: _serverState.storeboardState ==
                                        StoreboardState.Speaker
                                    ? Colors.greenAccent
                                    : Colors.white,
                              ),
                              text: 'Выступление',
                            ),
                            Tab(
                              icon: Icon(
                                Icons.update,
                                color: _serverState.storeboardState ==
                                        StoreboardState.Break
                                    ? Colors.greenAccent
                                    : Colors.white,
                              ),
                              text: 'Перерыв',
                            ),
                            Tab(
                              icon: Icon(
                                Icons.folder,
                                color: _serverState.storeboardState ==
                                        StoreboardState.Template
                                    ? Colors.greenAccent
                                    : Colors.white,
                              ),
                              text: 'Шаблон',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 800,
                        height: 450,
                        child: TabBarView(
                          children: [
                            setCustomText(setStateForDialog),
                            setSpeaker(context, setStateForDialog),
                            setBreak(context, setStateForDialog),
                            setFromTemplate(context, setStateForDialog),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 20, 20),
                                  child: TextButton(
                                    child: Text('Вопрос',
                                        style: TextStyle(fontSize: 20)),
                                    onPressed: _serverState.systemState ==
                                            SystemState.QuestionVoting
                                        ? null
                                        : () {
                                            _setFlushStoreboard();
                                            Navigator.of(context).pop();
                                          },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
                                  child: TextButton(
                                    child: Text('Очистить',
                                        style: TextStyle(fontSize: 20)),
                                    onPressed: () {
                                      clearCurrentTab();
                                      setStateForDialog(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(55, 0, 20, 20),
                                child: TextButton(
                                  child: Text('Закрыть',
                                      style: TextStyle(fontSize: 20)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                      return _editStoreboardTemplate != null
                                          ? Colors.black12
                                          : Colors.blue;
                                    }),
                                  ),
                                  child: Text('Установить',
                                      style: TextStyle(fontSize: 20)),
                                  onPressed: _editStoreboardTemplate != null
                                      ? null
                                      : () async {
                                          await setStoreboard(context);
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Padding(
                      //         padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      //         child: TextButton(
                      //           child: Text('Добавить в очередь',
                      //               style: TextStyle(fontSize: 20)),
                      //           onPressed: () async {
                      //             setStateForDialog(() {
                      //               _wasError = _selectDataController
                      //                       .selectedList.length ==
                      //                   0;
                      //             });
                      //             if (!_formKeySetSpeaker.currentState
                      //                     .validate() ||
                      //                 _wasError) {
                      //               return;
                      //             }

                      //             if (GroupUtil.isTerminalGuest(
                      //                 _serverState, _terminalId)) {
                      //               await _addGuestAskWord(_selectDataController
                      //                   .selectedList.first.nameSingleItem);
                      //             } else {
                      //               var userId = _serverState
                      //                   .usersTerminals[_terminalId];

                      //               if (userId != null &&
                      //                   _serverState.terminalsOnline
                      //                       .contains(_terminalId)) {
                      //                 await _addUserAskWord(userId);
                      //               }
                      //             }

                      //             setStateForDialog(() {});
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Padding(
                      //         padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
                      //         child: TextButton(
                      //           child: Text('Исключить из очереди',
                      //               style: TextStyle(fontSize: 20)),
                      //           onPressed: () async {
                      //             setStateForDialog(() {
                      //               _wasError = _selectDataController
                      //                       .selectedList.length ==
                      //                   0;
                      //             });
                      //             if (!_formKeySetSpeaker.currentState
                      //                     .validate() ||
                      //                 _wasError) {
                      //               return;
                      //             }
                      //             if (GroupUtil.isTerminalGuest(
                      //                 _serverState, _terminalId)) {
                      //               await _removeGuestAskWord(
                      //                   _selectDataController
                      //                       .selectedList.first.nameSingleItem);
                      //             } else {
                      //               var userId = _serverState
                      //                   .usersTerminals[_terminalId];

                      //               if (userId != null &&
                      //                   _serverState.terminalsOnline
                      //                       .contains(_terminalId)) {
                      //                 await _removeUserAskWord(userId);
                      //               }
                      //             }
                      //             setStateForDialog(() {});
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ],
              );
            },
          );
        });
  }

  Future<void> setStoreboard(BuildContext context) async {
    if (_currentTabIndex == 0) {
      if (_formKeySetCustomText.currentState?.validate() == false) {
        return;
      }

      _setStoreboardState(
          StoreboardState.CustomText,
          json.encode({
            'caption': _tecSetStoreboardCaption.text,
            'text': _tecSetStoreboardText.text,
          }));
    }
    if (_currentTabIndex == 1) {
      _setStateForDialog(() {
        _wasError = _selectDataController.selectedList.length == 0;
      });
      if (_formKeySetSpeaker.currentState?.validate() == false || _wasError) {
        return;
      }
      var seconds = 0;
      if (int.tryParse(_tecSpeakerTime.text) != null) {
        seconds = int.tryParse(_tecSpeakerTime.text)!;
      }

      if (_speakerPlace != null &&
          _group.workplaces.tribuneNames.contains(_speakerPlace)) {
        _terminalId = getTerminalIdByTribyneName(_speakerPlace!)!;
      }

      var speakerSession = SpeakerSession();

      speakerSession.terminalId = _terminalId ?? "000";
      speakerSession.type = _speakerType;
      speakerSession.name =
          _selectDataController.selectedList.first.nameSingleItem;
      speakerSession.interval = seconds;
      speakerSession.autoEnd = _autoEnd == true;
      _setCurrentSpeaker(speakerSession, _selectedInterval!.startSignal!,
          _selectedInterval!.endSignal!);
    }

    if (_currentTabIndex == 2) {
      if (_formKeySetBreak.currentState!.validate() == false) {
        return;
      }

      _setStoreboardState(
          StoreboardState.Break,
          json.encode({
            'break': _break.toIso8601String(),
          }));
    }

    if (_currentTabIndex == 3) {
      if (_setStoreboardTemplate != null) {
        if (!(_formKeySetTemplate?.currentState?.validate() ?? true)) {
          return;
        }

        _setStoreboardState(
            StoreboardState.Template,
            json.encode(
              _setStoreboardTemplate!.toJson(),
            ));
      } else {
        if (_selectedStoreboardTemplate == null) {
          await Utility().showMessageOkDialog(_context,
              title: 'Отсутствует выбранный шаблон',
              message: TextSpan(
                text:
                    'Выберите шаблон для установки из списка доступных шаблонов',
              ),
              okButtonText: 'Ок');

          return;
        }
        _setStoreboardState(
          StoreboardState.Template,
          json.encode(
            _selectedStoreboardTemplate?.toJson(),
          ),
        );
      }
    }
  }

  void clearCurrentTab() {
    if (_currentTabIndex == 0) {
      _tecSetStoreboardCaption.text = '';
      _tecSetStoreboardText.text = '';
    }
    if (_currentTabIndex == 1) {
      _selectDataController.selectedList.clear();
      _tecSpeakerTime.text = '0';

      _autoEnd = false;
      _setAutoEnd(_autoEnd);
    }

    if (_currentTabIndex == 2) {
      _tecBreak.text = '';
    }
  }

  Widget setCustomText(Function setStateForDialog) {
    return Form(
      key: _formKeySetCustomText,
      child: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Container(
              height: 20,
            ),
            Container(
              width: 800,
              child: TextFormField(
                autofocus: true,
                controller: _tecSetStoreboardCaption,
                expands: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Заголовок',
                ),
                validator: (value) {
                  if (value?.isEmpty == true &&
                      _tecSetStoreboardText.text.isEmpty) {
                    return 'Введите текст или заголовок';
                  }
                  if (!_captionWidthCorrect) {
                    return 'Превышена ширина экрана табло';
                  }
                  return null;
                },
                onChanged: (value) {
                  checkCaptionWidth(value);
                  setStateForDialog(() {});
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Tooltip(
                  message: 'Используемая ширина экрана, пикс.',
                  child: Text(_captionWidthLabel,
                      style: TextStyle(
                          fontSize: 12,
                          color: _captionWidthCorrect
                              ? Colors.green
                              : Colors.red)),
                ),
              ],
            ),
            Container(
              height: 20,
            ),
            Container(
              width: 800,
              height: 250,
              child: TextFormField(
                controller: _tecSetStoreboardText,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Текст',
                ),
                validator: (value) {
                  if (value?.isEmpty == true &&
                      _tecSetStoreboardCaption.text.isEmpty) {
                    return 'Введите текст или заголовок';
                  }
                  if (!_textWidthCorrect) {
                    return 'Превышено допустимое количество строк табло';
                  }
                  return null;
                },
                onChanged: (value) {
                  checkTextHeight(value);
                  setStateForDialog(() {});
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Tooltip(
                  message: 'Используемое количество строк, шт.',
                  child: Text(_textWidthLabel,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              _textWidthCorrect ? Colors.green : Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void checkCaptionWidth(String value) {
    int actualWidth = StoreboardTextUtils(_settings)
        .textSize(value, TextStyle(fontSize: 18))
        .width
        .ceil();

    int maxWidth = _settings.storeboardSettings.getContentWidth();
    _captionWidthCorrect = actualWidth <= maxWidth;
    _captionWidthLabel = '$actualWidth/$maxWidth';
  }

  void checkTextHeight(String value) {
    int maxLines = 11;
    int currentLines =
        StoreboardTextUtils(_settings).textLinesCount(value, maxLines);
    _textWidthLabel = '$currentLines/$maxLines';
    _textWidthCorrect =
        !StoreboardTextUtils(_settings).isExceedsLinesCount(value, maxLines);
  }

  Widget setSpeaker(BuildContext context, Function setStateForDialog) {
    var terminalId = _terminalId;

    if (_speakerPlace != null &&
        _group.workplaces.tribuneNames.contains(_speakerPlace)) {
      terminalId = getTerminalIdByTribyneName(_speakerPlace!)!;
    }

    var micButtonText =
        _isMicActive ? 'Отключить микрофон' : 'Включить микрофон';
    if (_isMicWaiting) {
      micButtonText = 'Микрофон ожидает';
    }

    Color micColor = Colors.black;
    if (_isMicWaiting) {
      micColor = Colors.green;
    }
    if (_isMicActive) {
      micColor = Colors.red;
    }

    bool _isControlSound = _isOperatorView
        ? _settings.operatorSchemeSettings.controlSound
        : _settings.managerSchemeSettings.controlSound;

    return Form(
      key: _formKeySetSpeaker,
      child: Column(
        children: [
          Expanded(
            child: Container(),
          ),
          Container(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Место выступления:'),
                ),
              ),
              Container(
                width: 20,
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 150,
                      ),
                      child: getDropDownForPlaces(setStateForDialog),
                    ),
                    Container(
                      width: 20,
                    ),
                    !_isControlSound
                        ? Container()
                        : Tooltip(
                            message: terminalId == null
                                ? 'Отсуствует ид терминала'
                                : micButtonText,
                            child: TextButton(
                              child: Row(children: [
                                Text(
                                  micButtonText,
                                  style:
                                      TextStyle(fontSize: 18, color: micColor),
                                ),
                                Container(
                                  width: 20,
                                ),
                                _isBlockMicButton
                                    ? SizedBox(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        height: 18.0,
                                        width: 18.0,
                                      )
                                    : Icon(
                                        Icons.mic,
                                        color: micColor,
                                        size: 18.0,
                                      )
                              ]),
                              onPressed: terminalId == null
                                  ? null
                                  : _isBlockMicButton
                                      ? null
                                      : () {
                                          _setSpeaker(
                                              terminalId!, !_isMicActive);
                                          setStateForDialog(() {
                                            _isBlockMicButton = true;
                                          });
                                          Timer(Duration(seconds: 1), () {
                                            setStateForDialog(() {
                                              _isBlockMicButton = false;
                                            });
                                          });
                                        },
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Тип выступления:'),
                ),
              ),
              Container(
                width: 20,
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 150,
                        maxWidth: 150,
                      ),
                      child: getDropDownForSpeakerType(setStateForDialog),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 20,
          ),
          Select2dot1(
            selectDataController: _selectDataController,
            selectEmptyInfoSettings: SelectEmptyInfoSettings(
                text: 'Выберите выступающего',
                textStyle:
                    TextStyle(color: _wasError ? Colors.red : Colors.grey)),
            selectSingleSettings: SelectSingleSettings(
                textStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                avatarMaxWidth: 0.0),
            searchBarOverlaySettings: SearchBarOverlaySettings(
              textFieldDecorationFocus: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                hintText: 'Поиск',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
              ),
              textFieldDecorationNoFocus: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                hintText: 'Поиск',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
              ),
            ),
            searchEmptyInfoOverlaySettings:
                SearchEmptyInfoOverlaySettings(text: 'Не найдено'),
          ),
          Container(
            height: 30,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tecSpeakerTime,
                            maxLines: null,
                            expands: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Время на выступление, с.',
                            ),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  int.tryParse(value) == null) {
                                return 'Введите целое число';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: 5,
                        ),
                        Tooltip(
                          message: 'Сбросить время на выступление',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () {
                              _setStateForDialog(() {
                                _autoEnd = false;
                                _setAutoEnd(_autoEnd);
                                _tecSpeakerTime.text = '0';
                              });
                            },
                            child: Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                    getAutoEndWidget(),
                  ],
                ),
              ),
              Container(
                width: 10,
              ),
              Expanded(
                child: Column(
                  children: [
                    getIntervalPanel(),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget getIntervalPanel() {
    return Wrap(
      spacing: 15.0,
      runSpacing: 10,
      children: List<Widget>.generate(
        _intervals.length,
        (int index) {
          return ChoiceChip(
            label: Text(_intervals[index].name),
            selected: _selectedInterval == _intervals[index],
            selectedColor: Colors.blue,
            onSelected: (bool selected) {
              _setStateForDialog(() {
                if (selected == true) {
                  _selectedInterval = _intervals[index];
                } else {
                  _selectedInterval = null;
                }

                _tecSpeakerTime.text = _selectedInterval == null
                    ? '0'
                    : _selectedInterval!.duration.toString();

                _setSelectedInterval(_selectedInterval);

                if (_selectedInterval != null) {
                  _autoEnd = _selectedInterval!.isAutoEnd;
                }
              });
            },
          );
        },
      ).toList(),
    );
  }

  bool isAutoEndWidgetDisabled() {
    return _tecSpeakerTime.text == null ||
        _tecSpeakerTime.text.isEmpty ||
        int.tryParse(_tecSpeakerTime.text) == null ||
        int.tryParse(_tecSpeakerTime.text) == 0;
  }

  Widget getAutoEndWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [
          Checkbox(
            value: _autoEnd,
            onChanged: isAutoEndWidgetDisabled()
                ? null
                : (bool? value) {
                    _setStateForDialog(() {
                      _autoEnd = value;
                      _setAutoEnd(_autoEnd);
                    });

                    saveSettings(_settings);
                  },
          ),
          Container(
            width: 10,
          ),
          Text(
            'Авт. ВЫКЛ.',
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  void saveSettings(Settings settings) {
    http.put(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/settings/${settings.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(settings.toJson()));
  }

  Widget getDropDownForPlaces(Function setStateForDialog) {
    return DropdownButton<String>(
      value: _speakerPlace,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setStateForDialog(() {
          _speakerPlace = newValue;
        });
      },
      items: _placesForSpeaker.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  Widget getDropDownForSpeakerType(Function setStateForDialog) {
    return DropdownButton<String>(
      value: _speakerType,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setStateForDialog(() {
          _speakerType = newValue ?? 'Выступление:';
        });
      },
      items: <String>['Выступление:', 'Докладчик:', 'Содокладчик:', 'ФИО:']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  Widget setBreak(BuildContext context, Function setStateForDialog) {
    return Form(
      key: _formKeySetBreak,
      child: Column(
        children: [
          Expanded(
            child: Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(),
              ),
              Text(
                'ПЕРЕРЫВ ДО ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 200,
                child: TextFormField(
                  readOnly: true,
                  controller: _tecBreak,
                  expands: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'До',
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Введите окончание перерыва';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                width: 10,
              ),
              Tooltip(
                message: 'Изменить окончание перерыва',
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  onPressed: () async {
                    var timeOfDay = await showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay(hour: _break.hour, minute: _break.minute),
                    );

                    if (timeOfDay == null) {
                      return;
                    }

                    var now = TimeUtil.getDateTimeNow(_timeOffset);

                    setStateForDialog(() {
                      _break = DateTime(now.year, now.month, now.day,
                          timeOfDay.hour, timeOfDay.minute);
                      _tecBreak.text = DateFormat('HH:mm').format(_break);
                    });
                  },
                  child: Icon(Icons.edit),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Container(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              SizedBox(
                height: 50,
                width: 135,
                child: Tooltip(
                  message: 'Сброс навигации всех клиентов на экран повестки',
                  child: TextButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          EdgeInsets.fromLTRB(10, 0, 10, 0)),
                    ),
                    onPressed: () async {
                      var noButtonPressed = false;
                      var title = 'Сбросить навигацию всех клиентов';

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

                      _setFlushNavigation();
                    },
                    child: Row(
                      children: [
                        Text(
                          'Повестка',
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Icon(Icons.home),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: Container())
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget setFromTemplate(BuildContext context, Function setStateForDialog) {
    Widget tabContent;
    if (_editStoreboardTemplate != null) {
      tabContent = editTemplate(context, setStateForDialog);
    } else if (_setStoreboardTemplate != null) {
      tabContent = setTemplate(context, setStateForDialog);
    } else {
      tabContent = getTemplatesTable(context, setStateForDialog);
    }

    return SingleChildScrollView(child: tabContent);
  }

  Widget editTemplate(BuildContext context, Function setStateForDialog) {
    TextEditingController controllerTemplateName;
    if (!_templateNameControllers.containsKey(_editStoreboardTemplate)) {
      controllerTemplateName =
          TextEditingController(text: _editStoreboardTemplate!.name);
      _templateNameControllers.putIfAbsent(
          _editStoreboardTemplate!, () => controllerTemplateName);
    } else {
      controllerTemplateName =
          _templateNameControllers[_editStoreboardTemplate]!;
    }

    List<Widget> templateItems = <Widget>[];

    for (int i = 0; i < _editStoreboardTemplate!.items.length; i++) {
      templateItems.add(getTemplateItem(
          _editStoreboardTemplate!.items[i], setStateForDialog));
      templateItems.add(
        Container(
          height: 20,
        ),
      );
    }

    return Form(
      key: _formKeyEditTemplate,
      child: Column(
        children: [
          Container(
            width: 800,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            color: Colors.lightBlue,
            child: Row(
              children: [
                Tooltip(
                  message: 'Назад',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      setStateForDialog(() {
                        _editStoreboardTemplate = null;
                      });
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Container(
                  width: 20,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      _editStoreboardTemplate?.id == null
                          ? 'Создание нового шаблона'
                          : 'Редактирование шаблона: ' +
                              _editStoreboardTemplate!.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                  ),
                ),
                Container(
                  width: 20,
                ),
                Tooltip(
                  message: 'Сохранить шаблон',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      saveTemplate(setStateForDialog);
                    },
                    child: Icon(Icons.save),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 800,
            child: TextFormField(
              controller: controllerTemplateName,
              expands: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Наименование шаблона',
              ),
              validator: (value) {
                if (value?.isEmpty == true &&
                    controllerTemplateName.text.isEmpty) {
                  return 'Введите наименование шаблона';
                }
                return null;
              },
              onChanged: (value) {
                setStateForDialog(() {
                  _editStoreboardTemplate!.name = value;
                });
              },
            ),
          ),
          Container(
            height: 20,
          ),
          Column(
            children: templateItems,
          ),
          Container(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                width: 224,
                child: TextButton(
                  onPressed: () {
                    addTemplateItem(_editStoreboardTemplate!);
                    setStateForDialog(() {});
                  },
                  child: Row(
                    children: [
                      Text('Добавить блок текста'),
                      Container(
                        width: 10,
                      ),
                      Icon(Icons.add),
                    ],
                  ),
                ),
              ),
              Container(
                width: 20,
              ),
              TextButton(
                onPressed: () {
                  saveTemplate(setStateForDialog);
                },
                child: Row(
                  children: [
                    Text(
                      'Сохранить шаблон',
                    ),
                    Container(
                      width: 10,
                    ),
                    Icon(Icons.save),
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Container(
            height: 10,
          ),
        ],
      ),
    );
  }

  void addTemplateItem(StoreboardTemplate template) {
    var newItem = StoreboardTemplateItem();
    newItem.order = template.items.length;
    template.items.add(newItem);
  }

  void saveTemplate(Function setStateForDialog) {
    if (_formKeyEditTemplate.currentState?.validate() == null) {
      return;
    }

    if (_editStoreboardTemplate?.id == null) {
      http
          .post(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/storeboardtemplates'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(_editStoreboardTemplate?.toJson()))
          .then((value) {
        setStateForDialog(() {
          loadData();
          _editStoreboardTemplate = null;
        });
      });
    } else {
      var id = _editStoreboardTemplate?.id;
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/storeboardtemplates/$id'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(_editStoreboardTemplate?.toJson()))
          .then((value) {
        setStateForDialog(() {
          loadData();
          _editStoreboardTemplate = null;
        });
      });
    }
  }

  Widget getTemplateItem(
      StoreboardTemplateItem item, Function setStateForDialog) {
    TextEditingController controllerDefaultText;
    if (!_defaultTextControllers.containsKey(item)) {
      controllerDefaultText = TextEditingController(text: item.text);
      _defaultTextControllers.putIfAbsent(item, () => controllerDefaultText);
    } else {
      controllerDefaultText = _defaultTextControllers[item]!;
    }
    TextEditingController controllerFontSize;
    if (!_fontSizeControllers.containsKey(item)) {
      controllerFontSize =
          TextEditingController(text: item.fontSize.toString());
      _fontSizeControllers.putIfAbsent(item, () => controllerFontSize);
    } else {
      controllerFontSize = _fontSizeControllers[item]!;
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        border: Border.all(
          color: Color(_settings.palletteSettings.cellBorderColor),
          width: _settings.operatorSchemeSettings.cellBorder.toDouble(),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextField(
            controller: controllerDefaultText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Текст блока',
            ),
            onChanged: (value) {
              setStateForDialog(() {
                item.text = value;
              });
            },
          ),
          Container(
            height: 10,
          ),
          TextField(
            controller: controllerFontSize,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Размер шрифта',
            ),
            onChanged: (value) {
              setStateForDialog(() {
                item.fontSize = int.tryParse(value) ?? 14;
              });
            },
          ),
          Container(
            height: 10,
          ),
          Row(children: [
            Expanded(child: Container()),
            Text('Выравнивание:'),
            Container(
              width: 10,
            ),
            DropdownButton<String>(
              value: item.align,
              icon: Icon(Icons.arrow_downward),
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              onChanged: (String? value) {
                setStateForDialog(() {
                  item.align = value ?? 'По левому краю';
                });
              },
              items: <String>['По левому краю', 'По центру', 'По правому краю']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(child: Container()),
          ]),
          Row(children: [
            Expanded(child: Container()),
            Text('Стиль:'),
            Container(
              width: 10,
            ),
            DropdownButton<String>(
              value: item.weight,
              icon: Icon(Icons.arrow_downward),
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              onChanged: (String? value) {
                setStateForDialog(() {
                  item.weight = value ?? 'Обычный';
                });
              },
              items: <String>['Обычный', 'Жирный']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(child: Container()),
          ]),
        ],
      ),
    );
  }

  Widget getTemplateSetItem(
      StoreboardTemplateItem item, Function setStateForDialog) {
    TextEditingController controller;
    if (!_previewControllers.containsKey(item)) {
      controller = TextEditingController(text: item.text);
      _previewControllers.putIfAbsent(item, () => controller);
    } else {
      controller = _previewControllers[item]!;
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Текст блока',
      ),
      onChanged: (value) {
        setStateForDialog(() {
          item.text = value;
        });
      },
    );
  }

  Widget setTemplate(BuildContext context, Function setStateForDialog) {
    List<Widget> templateItems = <Widget>[];

    for (int i = 0; i < _setStoreboardTemplate!.items.length; i++) {
      templateItems.add(getTemplateSetItem(
          _setStoreboardTemplate!.items[i], setStateForDialog));
      templateItems.add(
        Container(
          height: 20,
        ),
      );
    }

    var prewievServerState = ServerState();
    prewievServerState.storeboardState = StoreboardState.Template;
    prewievServerState.storeboardParams =
        jsonEncode(_setStoreboardTemplate?.toJson());

    return Form(
      key: _formKeySetTemplate,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  color: Colors.lightBlue,
                  child: Row(
                    children: [
                      Tooltip(
                        message: 'Назад',
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () {
                            setStateForDialog(() {
                              _setStoreboardTemplate = null;
                            });
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                      Container(
                        width: 20,
                      ),
                      Text(
                        'Предпросмотр шаблона: ' + _setStoreboardTemplate!.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: templateItems,
          ),
          Container(
            height: 20,
          ),
          StoreboardWidget(
            serverState: prewievServerState,
            settings: _settings,
            timeOffset: _timeOffset,
            meeting: _meeting,
            votingModes: [],
            users: [],
          ),
        ],
      ),
    );
  }

  Widget getTemplatesTable(BuildContext context, Function setStateForDialog) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowHeight: 80,
        showCheckboxColumn: false,
        headingRowColor: WidgetStateProperty.all(Colors.lightBlueAccent),
        dataRowColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.3);
          }

          return null;
        }),
        columns: [
          DataColumn(
            label: Row(
              children: [
                Text(
                  'Шаблон',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
                Container(
                  width: 620,
                  child: Container(),
                ),
                Tooltip(
                  message: 'Добавить шаблон',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      setStateForDialog(() {
                        _editStoreboardTemplate = StoreboardTemplate();
                      });
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
        rows: _storeboardTemplates
            .map(
              (element) => DataRow(
                selected: element == _selectedStoreboardTemplate,
                onSelectChanged: (value) {
                  setStateForDialog(() {
                    _selectedStoreboardTemplate = element;
                  });
                },
                cells: <DataCell>[
                  DataCell(
                    Row(children: [
                      Expanded(
                        child: Text(element.name),
                      ),
                      Tooltip(
                        message: 'Предпросмотр',
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () {
                            setStateForDialog(() {
                              _setStoreboardTemplate = element;
                            });
                          },
                          child: Icon(Icons.monitor),
                        ),
                      ),
                      Tooltip(
                        message: 'Изменить шаблон',
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () {
                            setStateForDialog(() {
                              _editStoreboardTemplate = element;
                            });
                          },
                          child: Icon(Icons.edit),
                        ),
                      ),
                      Tooltip(
                        message: 'Удалить шаблон',
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.transparent),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.black),
                            overlayColor:
                                WidgetStateProperty.all(Colors.black12),
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () async {
                            var noButtonPressed = false;
                            var title = 'Удалить шаблон табло';

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

                            await http.delete(
                                Uri.http(
                                    ServerConnection.getHttpServerUrl(
                                        GlobalConfiguration()),
                                    '/storeboardtemplates/${element.id}'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                }).then((response) {
                              _storeboardTemplates.remove(element);
                              setStateForDialog(() {});
                            }).catchError((e) {
                              Utility().showMessageOkDialog(context,
                                  title: 'Ошибка',
                                  message: TextSpan(
                                    text:
                                        'В ходе удаления шаблона табло ${element.name} возникла ошибка: $e',
                                  ),
                                  okButtonText: 'Ок');
                            });
                          },
                          child: Icon(Icons.delete),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
