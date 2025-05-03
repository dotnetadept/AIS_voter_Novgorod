import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';

class InitialVotesDialog {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BuildContext _context;
  Settings _settings;

  Meeting? _selectedMeeting;
  Question? _lockedQuestion;

  ScrollController _proxyTableScrollController = ScrollController();
  List<Proxy> _proxies;
  Proxy? _managerProxy;
  Map<String, String> _initialChoices;
  Function(Map<String, String>) _setIntialChoices;

  InitialVotesDialog(
    this._context,
    this._settings,
    this._selectedMeeting,
    this._lockedQuestion,
    this._proxies,
    this._initialChoices,
    this._setIntialChoices,
  ) {
    var managerId = _selectedMeeting!.group!.groupUsers
        .firstWhereOrNull((element) => element.isManager == true)
        ?.user
        .id;
    _managerProxy = _proxies.firstWhereOrNull((element) =>
        element.proxy?.id == managerId &&
        element.isActive == true &&
        element.isInitialVotes == true);
  }

  Future<void> openDialog() async {
    return showAlignedDialog<void>(
        context: _context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        offset: Offset(-_settings.storeboardSettings.width / 2, 0),
        targetAnchor: Alignment.centerRight,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateForDialog) {
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
                  titlePadding: EdgeInsets.all(10),
                  actionsPadding: EdgeInsets.all(10),
                  title: Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                            color: Colors.lightBlue,
                            alignment: Alignment.center,
                            child: Text(
                              'Предварительное голосование: \r\n ${_lockedQuestion.toString()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: getProxyTable(setStateForDialog),
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
                                        'Назад',
                                        style: TextStyle(fontSize: 23),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                                child: TextButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Продолжить',
                                        style: TextStyle(fontSize: 23),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    _setIntialChoices(_initialChoices);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget getProxyTable(Function setStateForDialog) {
    if (_managerProxy == null) {
      return Container();
    }

    return Scrollbar(
      thumbVisibility: true,
      controller: _proxyTableScrollController,
      child: Container(
        width: 720,
        child: ListView.builder(
            controller: _proxyTableScrollController,
            itemCount: _managerProxy!.subjects.length,
            itemBuilder: (BuildContext context, int index) {
              var user = _managerProxy!.subjects[index].user;
              var userId = user.id.toString();

              return Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: _initialChoices[userId] == 'ЗА'
                      ? Color(_settings.palletteSettings.voteYesColor)
                      : _initialChoices[userId] == 'ПРОТИВ'
                          ? Color(_settings.palletteSettings.voteNoColor)
                          : _initialChoices[userId] == 'ВОЗДЕРЖАЛСЯ'
                              ? Color(_settings
                                  .palletteSettings.voteIndifferentColor)
                              : Colors.transparent,
                ),
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Wrap(
                      children: [
                        Text(
                          user.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        TextButton(
                          child: Text('ЗА'),
                          onPressed: () {
                            if (_initialChoices.containsKey(userId)) {
                              _initialChoices[userId] = 'ЗА';
                            } else {
                              _initialChoices
                                  .addAll(<String, String>{userId: 'ЗА'});
                            }
                            setStateForDialog(() {});
                          },
                        ),
                        Container(
                          width: 15,
                        ),
                        TextButton(
                          child: Text('ПРОТИВ'),
                          onPressed: () {
                            if (_initialChoices.containsKey(userId)) {
                              _initialChoices[userId] = 'ПРОТИВ';
                            } else {
                              _initialChoices
                                  .addAll(<String, String>{userId: 'ПРОТИВ'});
                            }
                            setStateForDialog(() {});
                          },
                        ),
                        Container(
                          width: 15,
                        ),
                        TextButton(
                          child: Text('ВОЗДЕРЖАЛСЯ'),
                          onPressed: () {
                            if (_initialChoices.containsKey(userId)) {
                              _initialChoices[userId] = 'ВОЗДЕРЖАЛСЯ';
                            } else {
                              _initialChoices.addAll(
                                  <String, String>{userId: 'ВОЗДЕРЖАЛСЯ'});
                            }
                            setStateForDialog(() {});
                          },
                        ),
                        Container(
                          width: 15,
                        ),
                        TextButton(
                          child: Text('СБРОС'),
                          onPressed: () {
                            if (_initialChoices.containsKey(userId)) {
                              _initialChoices.remove(userId);
                            }
                            setStateForDialog(() {});
                          },
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
