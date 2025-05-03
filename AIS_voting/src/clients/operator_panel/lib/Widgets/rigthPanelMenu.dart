import 'dart:convert';

import 'package:ais_model/ais_model.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:ais_utils/dialogs.dart';
import 'package:ais_utils/set_storeboard_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Dialogs/question_list_change_dialog.dart';
import '../Dialogs/registration_dialog.dart';
import '../Providers/AppState.dart';
import '../Providers/WebSocketConnection.dart';

class RightPanelMenu extends StatefulWidget {
  final Settings settings;
  final Meeting? selectedMeeting;
  final Question? lockedQuestion;
  final Question? selectedQuestion;
  final List<User> users;
  final int timeOffset;

  final void Function(ais.Interval? interval) setInterval;
  final void Function(bool? autoEnd) setAutoEnd;
  final void Function(String) addGuestAskWord;
  final void Function(String) removeGuestAskWord;
  final void Function(int) addUserAskWord;
  final void Function(int) removeUserAskWord;

  RightPanelMenu({
    Key? key,
    required this.settings,
    required this.selectedMeeting,
    required this.lockedQuestion,
    required this.selectedQuestion,
    required this.users,
    required this.timeOffset,
    required this.setInterval,
    required this.setAutoEnd,
    required this.addGuestAskWord,
    required this.removeGuestAskWord,
    required this.addUserAskWord,
    required this.removeUserAskWord,
  }) : super(key: key);

  @override
  _RightPanelMenuState createState() => _RightPanelMenuState();
}

class _RightPanelMenuState extends State<RightPanelMenu> {
  late WebSocketConnection _connection;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _connection = Provider.of<WebSocketConnection>(context, listen: true);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          color: Colors.lightBlueAccent.withOpacity(0.3),
          child: Row(
            children: [
              Expanded(child: Container()),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: PopupMenuButton(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.table_rows,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                  offset: Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'users') {
                      AppState().navigateUsersPage();
                    }
                    if (value == 'groups') {
                      AppState().navigateGroupsPage();
                    }
                    if (value == 'proxies') {
                      AppState().navigateProxiesPage();
                    }
                    if (value == 'agendas') {
                      AppState().navigateAgendasPage();
                    }
                    if (value == 'meetings') {
                      AppState().navigateMeetingsPage();
                    }
                    if (value == 'history') {
                      AppState().navigateHistoryPage();
                    }
                  },
                  tooltip: 'Объекты',
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'users',
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(Icons.account_box),
                          ),
                          Text('Пользователи'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'groups',
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(Icons.group),
                          ),
                          Text('Группы'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'proxies',
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(Icons.groups),
                          ),
                          Text('Доверенности'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'agendas',
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(Icons.event_note),
                          ),
                          Text('Повестки'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'meetings',
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(Icons.pan_tool),
                          ),
                          Text('Заседания'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                            child: Icon(Icons.history),
                          ),
                          Text('История'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Container(
                width: 40,
                height: 40,
                child: Tooltip(
                  message: 'Настройки',
                  child: TextButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      foregroundColor: WidgetStateProperty.all(Colors.blue),
                      overlayColor: WidgetStateProperty.all(Colors.black12),
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: AppState().navigateSettingsPage,
                    child: Icon(
                      Icons.settings,
                      size: 32,
                    ),
                  ),
                ),
              ),
              widget.selectedMeeting != null &&
                      widget.selectedMeeting!.status == 'Подготовка'
                  ? Expanded(child: Container())
                  : Container(),
              widget.selectedMeeting != null &&
                      widget.selectedMeeting!.status == 'Подготовка'
                  ? Container(
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: 'Остановить подготовку',
                        child: TextButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.blue),
                            overlayColor:
                                WidgetStateProperty.all(Colors.black12),
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () {
                            onPreparationCancel(context);
                          },
                          child: Icon(
                            Icons.stop,
                            size: 36,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              widget.selectedMeeting != null &&
                      (widget.selectedMeeting!.status == 'Подготовка' ||
                          SystemStateHelper.isStarted(
                              _connection.getServerState.systemState))
                  ? Expanded(child: Container())
                  : Container(),
              widget.selectedMeeting != null &&
                      (widget.selectedMeeting!.status == 'Подготовка' ||
                          SystemStateHelper.isStarted(
                              _connection.getServerState.systemState))
                  ? Container(
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: !SystemStateHelper.isStarted(
                                _connection.getServerState.systemState)
                            ? 'Начать заседание'
                            : 'Завершить заседание',
                        child: TextButton(
                          style: ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.blue),
                            overlayColor:
                                WidgetStateProperty.all(Colors.black12),
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(
                                color: Colors.transparent,
                              )),
                            ),
                          ),
                          onPressed: () {
                            onMeetingStart(context);
                          },
                          child: Icon(
                            !SystemStateHelper.isStarted(
                                    _connection.getServerState.systemState)
                                ? Icons.play_arrow
                                : Icons.stop,
                            size: 36,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              widget.selectedMeeting == null ||
                      widget.selectedMeeting!.status != 'Ожидание'
                  ? Container()
                  : Expanded(child: Container()),
              widget.selectedMeeting == null ||
                      widget.selectedMeeting!.status != 'Ожидание'
                  ? Container()
                  : Container(
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: 'Начать подготовку',
                        child: TextButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.blue),
                            overlayColor:
                                WidgetStateProperty.all(Colors.black12),
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          child: Icon(
                            Icons.done_all,
                            size: 32,
                          ),
                          onPressed: () {
                            _onMeetingPreparationStarted(context);
                          },
                        ),
                      ),
                    ),
              widget.selectedMeeting == null
                  ? Container()
                  : Expanded(child: Container()),
              widget.selectedMeeting == null
                  ? Container()
                  : Container(
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: 'Загрузить документы',
                        child: TextButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.blue),
                            overlayColor:
                                WidgetStateProperty.all(Colors.black12),
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: AppState().onLoadDocuments,
                          child: Icon(
                            Icons.drive_folder_upload,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
              widget.selectedMeeting == null
                  ? Container()
                  : Expanded(child: Container()),
              widget.selectedMeeting == null
                  ? Container()
                  : Container(
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: 'Изменить список вопросов',
                        child: TextButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.blue),
                            overlayColor:
                                WidgetStateProperty.all(Colors.black12),
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: _onQuestionListChange,
                          child: RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              Icons.list,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
              widget.selectedMeeting == null
                  ? Container()
                  : Expanded(child: Container()),
              widget.selectedMeeting == null
                  ? Container()
                  : Container(
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: 'Настройка текста табло',
                        child: TextButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.all(3)),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                            foregroundColor:
                                _connection.getServerState.storeboardState !=
                                            null &&
                                        _connection.getServerState
                                                .storeboardState !=
                                            StoreboardState.None
                                    ? WidgetStateProperty.all(Colors.green)
                                    : WidgetStateProperty.all(Colors.blue),
                            overlayColor:
                                WidgetStateProperty.all(Colors.black12),
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: _onSetStoreboard,
                          child: Icon(
                            Icons.monitor,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
              Expanded(child: Container()),
              Container(
                width: 40,
                height: 40,
                child: Tooltip(
                  message: 'Начать трансляцию',
                  child: TextButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.all(3)),
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: AppState().onStartStream,
                    child: Icon(
                      Icons.video_call,
                      size: 32,
                      color: _connection.getServerState.isStreamStarted ||
                              _connection.getServerState.playSound ==
                                  widget.settings.signalsSettings.hymnStart ||
                              _connection.getServerState.playSound ==
                                  widget.settings.signalsSettings.hymnEnd
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: widget.selectedMeeting == null ? 10 : 1,
                child: Container(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            widget.selectedMeeting != null &&
                    _connection.getServerState.systemState !=
                        SystemState.Registration
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                      child: Tooltip(
                        message:
                            'Регистрация: ${_connection.getServerState.isRegistrationCompleted ? "есть" : "нет"}',
                        child: TextButton(
                          style: ButtonStyle(
                            fixedSize: WidgetStateProperty.all(Size(
                                (widget.settings.storeboardSettings.width - 30)
                                    .toDouble(),
                                54)),
                          ),
                          onPressed: _startRegistration,
                          child: Row(
                            children: [
                              //Expanded(child: Container()),
                              Text(
                                'Регистрация',
                                style: TextStyle(fontSize: 24),
                              ),
                              Expanded(child: Container()),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.touch_app,
                                  size: 28,
                                  color: _connection.getServerState
                                          .isRegistrationCompleted
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            _connection.getServerState.systemState != SystemState.Registration
                ? Container()
                : Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                      child: TextButton(
                        style: ButtonStyle(
                          fixedSize: WidgetStateProperty.all(Size(
                              (widget.settings.storeboardSettings.width - 30)
                                  .toDouble(),
                              52)),
                        ),
                        onPressed: () => {_endRegistration()},
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            Text(
                              'Завершить регистрацию',
                              style: TextStyle(fontSize: 23),
                            ),
                            Expanded(flex: 10, child: Container()),
                            Icon(
                              Icons.touch_app,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  Future<void> onPreparationCancel(BuildContext context) async {
    var noButtonPressed = false;

    await Utility().showYesNoDialog(
      context,
      title: 'Остановить подготовку',
      message: TextSpan(
        text: 'Вы уверены, что хотите остановить подготовку?',
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

    _connection.setSystemStatus(
        SystemState.MeetingPreparationComplete,
        json.encode({
          'meeting_id': widget.selectedMeeting!.id,
        }));

    setState(() {
      widget.selectedMeeting!.status = 'Ожидание';
    });
  }

  void _onMeetingPreparationStarted(BuildContext context) async {
    var noButtonPressed = false;
    var title = 'Начать подготовку';

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
      return;
    }
    _connection.setSystemStatus(
        SystemState.MeetingPreparation,
        json.encode({
          'meeting_id': widget.selectedMeeting!.id,
        }));
  }

  void _startRegistration() {
    if (widget.selectedMeeting == null) {
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
            text: 'Отсутствует начатое заседание',
          ),
          okButtonText: 'Ок');
      return;
    }

    RegistrationDialog(
      context,
      widget.settings,
    ).openDialog();
  }

  void _endRegistration() {
    _connection.setSystemStatus(
        SystemState.RegistrationComplete,
        json.encode({
          'meeting_id': widget.selectedMeeting!.id,
        }));
  }

  void _onQuestionListChange() {
    QuestionListChangeDialog(context, widget.selectedMeeting!,
            widget.lockedQuestion, widget.settings, widget.users)
        .openDialog()
        .then((value) => setState(() {}));
  }

  void _onSetStoreboard() {
    SetStoreboardDialog(
      context,
      _connection.getServerState,
      widget.timeOffset,
      widget.settings,
      widget.selectedMeeting!,
      widget.selectedMeeting!.group!,
      AppState().getIntervals().where((element) => element.isActive).toList(),
      AppState().getSelectedInterval(),
      AppState().getAutoEnd(),
      null,
      null,
      true,
      _connection.setCurrentSpeaker,
      _connection.setSpeaker,
      _connection.setFlushNavigation,
      onFlushStoreboard,
      _connection.setStoreboardStatus,
      widget.setInterval,
      widget.setAutoEnd,
      widget.addGuestAskWord,
      widget.removeGuestAskWord,
      widget.addUserAskWord,
      widget.removeUserAskWord,
    ).openDialog();
  }

  void onFlushStoreboard() {
    if (widget.lockedQuestion != null) {
      _connection.setSystemStatus(
          SystemState.QuestionLocked,
          json.encode({
            'question_id': widget.lockedQuestion!.id,
          }));
    } else if (widget.selectedMeeting != null) {
      _connection.setStoreboardStatus(StoreboardState.None, null);
    }
  }

  Future<void> onMeetingStart(BuildContext context) async {
    var noButtonPressed = false;
    var title =
        !SystemStateHelper.isStarted(_connection.getServerState.systemState)
            ? 'Начать заседание'
            : 'Завершить заседание';

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
      return;
    }

    if (SystemStateHelper.isStarted(_connection.getServerState.systemState)) {
      _connection.setSystemStatus(
          SystemState.MeetingCompleted,
          json.encode({
            'meeting_id': widget.selectedMeeting!.id,
          }));
    } else {
      _connection.setSystemStatus(
          SystemState.MeetingStarted,
          json.encode({
            'meeting_id': widget.selectedMeeting!.id,
          }));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
