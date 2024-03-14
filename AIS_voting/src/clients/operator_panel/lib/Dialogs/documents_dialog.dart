import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:provider/provider.dart';

import '../Providers/WebSocketConnection.dart';

class DocumentsDialog {
  BuildContext _context;
  Settings _settings;
  Meeting _selectedMeeting;
  List<User> _users;

  bool _isSelectAll = false;
  WebSocketConnection _connection;
  Map<String, bool> _sendDocuments = {};

  List<String> _filteredTerminals;
  String _filter = 'deputy';

  ScrollController _documentsTableScrollController;

  DocumentsDialog(
    this._context,
    this._settings,
    this._selectedMeeting,
    this._users,
  ) {
    _documentsTableScrollController = ScrollController();
  }

  Future<void> openDialog() async {
    return showDialog<void>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setStateForDialog) {
            _connection =
                Provider.of<WebSocketConnection>(context, listen: true);
            var isLoadingInProgress = json.decode(
                    _connection.getServerState.params)['isLoadingDocuments'] ==
                true;
            var isDocumentsLoaded =
                _connection.getServerState.terminalsWithDocuments ==
                    getTerminalsOnline();

            filterTerminals(null);

            return AlertDialog(
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    color: Colors.lightBlue,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Text(
                              'Загрузка документов',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 28),
                            ),
                            Container(
                              width: 20,
                            ),
                            isLoadingInProgress
                                ? Tooltip(
                                    message: 'Идет загрузка',
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : isDocumentsLoaded
                                    ? Tooltip(
                                        message: 'Документы загружены',
                                        child: Icon(
                                          Icons.file_present,
                                          color: Color(_settings
                                              .palletteSettings
                                              .iconDocumentsDownloadedColor),
                                          size: 36,
                                        ),
                                      )
                                    : Tooltip(
                                        message: 'Документы не загружены',
                                        child: Icon(
                                          Icons.file_present,
                                          color: Color(_settings
                                              .palletteSettings
                                              .iconDocumentsNotDownloadedColor),
                                          size: 36,
                                        ),
                                      ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    color: Colors.blueGrey,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Депутатов онлайн: ',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              getTerminalListCounter(getDeputyOnline()),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: Container()),
                              Text(
                                'Гостей онлайн: ',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              getTerminalListCounter(getGuestOnline()),
                              Expanded(child: Container()),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: Container()),
                              Text(
                                'Дистанционно: ',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              getTerminalListCounter(getRemoteOnline()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 750,
                height: 400,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                color: Colors.lightBlue,
                                child: Row(
                                  children: [
                                    Tooltip(
                                      message: 'Выделить все',
                                      child: Checkbox(
                                          value: _isSelectAll,
                                          onChanged: (value) {
                                            setStateForDialog(() {
                                              _isSelectAll = value;

                                              for (var i = 0;
                                                  i < _filteredTerminals.length;
                                                  i++) {
                                                _sendDocuments[
                                                        _filteredTerminals[i]] =
                                                    value;
                                              }
                                            });
                                          }),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Терминалы онлайн',
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    getFilterButton(
                                        Icons.monitor,
                                        'Нет документов',
                                        'online',
                                        setStateForDialog),
                                    Container(
                                      width: 10,
                                    ),
                                    getFilterButton(Icons.widgets, 'На схеме',
                                        'scheme', setStateForDialog),
                                    Container(
                                      width: 10,
                                    ),
                                    getFilterButton(Icons.person, 'Депутаты',
                                        'deputy', setStateForDialog),
                                    Container(
                                      width: 10,
                                    ),
                                    getFilterButton(Icons.perm_identity,
                                        'Гости', 'guest', setStateForDialog),
                                    Container(
                                      width: 10,
                                    ),
                                    getFilterButton(Icons.lan, 'Дистанционно',
                                        'remote', setStateForDialog),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        isLoadingInProgress
                            ? Container(height: 66, color: Colors.black12)
                            : Container(height: 0),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          getDocumentsTable(setStateForDialog),
                          isLoadingInProgress
                              ? Container(color: Colors.black12)
                              : Container(height: 0),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        TextButton(
                          child: Row(children: [
                            Text('Закрыть', style: TextStyle(fontSize: 20)),
                            Container(
                              width: 10,
                            ),
                            Icon(Icons.close),
                          ]),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Container(
                          width: 20,
                        ),
                        TextButton(
                          child: Row(children: [
                            Text(
                                isLoadingInProgress
                                    ? 'Остановить'
                                    : 'Загрузить',
                                style: TextStyle(fontSize: 20)),
                            Container(
                              width: 10,
                            ),
                            isLoadingInProgress
                                ? Icon(Icons.stop)
                                : Icon(Icons.drive_folder_upload),
                          ]),
                          onPressed: () {
                            isLoadingInProgress
                                ? _connection.stopDownloadDocuments()
                                : onLoadDocuments();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget getTerminalListCounter(List<String> terminals) {
    var isTerminalsOk = getWithDocs(terminals).length == terminals.length;
    return Text(
      '${getWithDocs(terminals).length}/${terminals.length}',
      style: TextStyle(
        color: isTerminalsOk
            ? Color(_settings.palletteSettings.iconDocumentsDownloadedColor)
            : Color(_settings.palletteSettings.iconDocumentsNotDownloadedColor),
      ),
    );
  }

  Widget getFilterButton(
      IconData icon, String name, String filter, Function setStateForDialog) {
    return Tooltip(
      message: name,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: _filter == filter
              ? MaterialStateProperty.all(Colors.black87)
              : MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all(
            CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ),
        onPressed: () {
          _filter = filter;

          filterTerminals(setStateForDialog);
        },
        child: Icon(icon),
      ),
    );
  }

  void filterTerminals(Function setStateForDialog) {
    if (_filter == 'deputy') {
      _filteredTerminals = getDeputyOnline();
    } else if (_filter == 'guest') {
      _filteredTerminals = getGuestOnline();
    } else if (_filter == 'remote') {
      _filteredTerminals = getRemoteOnline();
    } else if (_filter == 'scheme') {
      _filteredTerminals = getTerminalsOnline()
          .where((element) => !getRemoteOnline().contains(element))
          .toList();
    } else if (_filter == 'online') {
      _filteredTerminals = getTerminalsOnline();
    }

    if (setStateForDialog != null) {
      setStateForDialog(() {});
    }
  }

  Widget getDocumentsTable(Function setStateForDialog) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _documentsTableScrollController,
      child: ListView.builder(
          controller: _documentsTableScrollController,
          itemCount: _filteredTerminals.length,
          itemBuilder: (BuildContext context, int index) {
            var terminalId = _filteredTerminals[index];
            User userOntrerminal;

            if (_connection.getServerState.usersTerminals
                .containsKey(terminalId)) {
              int userId =
                  _connection.getServerState.usersTerminals[terminalId];
              userOntrerminal = _users.firstWhere(
                (element) => element.id == userId,
                orElse: () => null,
              );
            }

            var isDocumentsLoading = _connection
                .getServerState.terminalsLoadingDocuments
                .contains(terminalId);
            var isDocumentsDownloaded = _connection
                .getServerState.terminalsWithDocuments
                .contains(terminalId);
            var isDocumentsError = _connection
                .getServerState.terminalsDocumentErrors.keys
                .contains(terminalId);

            // document icon
            Color documentsIconColor = Color(
                _settings.palletteSettings.iconDocumentsNotDownloadedColor);
            String documentsIconTooltip = 'Не загружены';

            if (isDocumentsLoading) {
              documentsIconColor = Colors.yellowAccent;
              documentsIconTooltip = 'Идет загрузка';
            }
            if (isDocumentsDownloaded) {
              documentsIconColor = Color(
                  _settings.palletteSettings.iconDocumentsDownloadedColor);
              documentsIconTooltip = 'Загружены';
            }
            if (isDocumentsError) {
              documentsIconColor = Colors.purple;
              documentsIconTooltip = 'Ошибка: ' +
                  _connection
                      .getServerState.terminalsDocumentErrors[terminalId];
            }

            var isGuest = !_connection.getServerState.usersTerminals
                .containsKey(terminalId);

            var isRemote = getRemoteOnline().contains(terminalId);

            return InkWell(
              onTap: () {
                if (terminalId != null) {
                  setStateForDialog(() {
                    _sendDocuments[terminalId] =
                        !(_sendDocuments[terminalId] ?? false);
                  });
                }
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
                        Tooltip(
                          message: 'Отправить документы',
                          child: Checkbox(
                              value: _sendDocuments[terminalId] ?? false,
                              onChanged: (value) {
                                if (!value) {
                                  _isSelectAll = false;
                                }
                                if (terminalId != null) {
                                  setStateForDialog(() {
                                    _sendDocuments[terminalId] = value;
                                  });
                                }
                              }),
                        ),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Wrap(children: [
                                IgnorePointer(
                                  ignoring: true,
                                  child: Text(
                                    terminalId,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                ),
                              ]),
                              Container(
                                width: 10,
                              ),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    IgnorePointer(
                                      ignoring: true,
                                      child: Text(
                                        userOntrerminal?.toString() ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tooltip(
                          message: isRemote ? "Удаленно" : "На схеме",
                          child: Icon(
                            isGuest ? Icons.lan : Icons.widgets,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Tooltip(
                          message: isGuest ? "Гость" : "Депутат",
                          child: Icon(
                            isGuest ? Icons.perm_identity : Icons.person,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Tooltip(
                          message: documentsIconTooltip,
                          child: Icon(
                            Icons.file_present,
                            color: documentsIconColor,
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

  void onLoadDocuments() {
    var terminals = <String>[];
    for (var sendItem in _sendDocuments.entries) {
      if (sendItem.value) {
        terminals.add(sendItem.key);
      }
    }

    _connection.initDocumentDownload(terminals);
  }

  List<String> getTerminalsOnline() {
    return _connection.getServerState.terminalsOnline;
  }

  List<String> getManagerTerminalOnline() {
    var managerId = GroupUtil().getManagerId(
        _selectedMeeting.group, _connection.getServerState.usersTerminals);

    var managerTerminals = _connection.getServerState.usersTerminals.entries
        .where((element) =>
            _connection.getServerState.terminalsOnline.contains(element.key) &&
            managerId == element.value)
        .map((e) => e.key)
        .toList();

    return managerTerminals;
  }

  List<String> getDeputyOnline() {
    return getTerminalsOnline()
        .where((terminalId) =>
            _connection.getServerState.usersTerminals.containsKey(terminalId))
        .where((terminalId) => !getManagerTerminalOnline().contains(terminalId))
        .toList();
  }

  List<String> getGuestOnline() {
    return getTerminalsOnline()
        .where((terminalId) => !getDeputyOnline().contains(terminalId))
        .where((terminalId) => !getManagerTerminalOnline().contains(terminalId))
        .toList();
  }

  List<String> getRemoteOnline() {
    return getTerminalsOnline()
        .where((terminalId) =>
            !(getManagerTerminalOnline().contains(terminalId) ||
                _selectedMeeting.group.workplaces.tribuneTerminalIds
                    .contains(terminalId) ||
                _selectedMeeting.group.workplaces.managementTerminalIds
                    .contains(terminalId) ||
                _selectedMeeting.group.workplaces.workplacesTerminalIds
                    .any((row) => row.any((place) => place == terminalId))))
        .toList();
  }

  List<String> getWithDocs(List<String> terminals) {
    return _connection.getServerState.terminalsWithDocuments
        .where((element) => terminals.contains(element))
        .toList();
  }
}
