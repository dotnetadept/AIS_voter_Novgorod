import 'dart:convert';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../Providers/AppState.dart';
import '../Providers/WebSocketConnection.dart';
import 'package:ais_model/ais_model.dart' as ais;

class InitialVotesDialog {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BuildContext _context;
  Settings _settings;

  Meeting? _selectedMeeting;
  Question? _lockedQuestion;

  ScrollController _proxyTableScrollController = ScrollController();
  List<Proxy> _proxies;
  late Proxy _managerProxy;
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
    _managerProxy =
        _proxies.firstWhere((element) => element.proxy?.id == managerId);
  }

  Future<void> openDialog() async {
    return showAlignedDialog<void>(
        context: _context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        offset: Offset(-1020, 20),
        targetAnchor: Alignment.centerRight,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateForDialog) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 705,
                  minWidth: 705,
                  maxHeight: 620,
                  minHeight: 620,
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
                              'Голосование оператором: ${_lockedQuestion.toString()}',
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
                                padding: EdgeInsets.fromLTRB(5, 0, 14, 10),
                                child: TextButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Закрыть',
                                        style: TextStyle(fontSize: 24),
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
                                padding: EdgeInsets.fromLTRB(5, 0, 14, 10),
                                child: TextButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Установить',
                                        style: TextStyle(fontSize: 24),
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
    return Scrollbar(
      thumbVisibility: true,
      controller: _proxyTableScrollController,
      child: Container(
        height: 200,
        width: 600,
        child: ListView.builder(
            controller: _proxyTableScrollController,
            itemCount: _managerProxy.subjects.length,
            itemBuilder: (BuildContext context, int index) {
              var user = _managerProxy.subjects[index].user;
              var userId = user.id.toString();

              return Container(
                height: 60,
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                alignment: Alignment.centerLeft,
                color: _initialChoices[userId] == 'ЗА'
                    ? Color(_settings.palletteSettings.voteYesColor)
                    : _initialChoices[userId] == 'ПРОТИВ'
                        ? Color(_settings.palletteSettings.voteNoColor)
                        : _initialChoices[userId] == 'ВОЗДЕРЖАЛСЯ'
                            ? Color(
                                _settings.palletteSettings.voteIndifferentColor)
                            : Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 10,
                    ),
                    Container(
                      constraints: BoxConstraints(minWidth: 260, maxWidth: 260),
                      child: Wrap(
                        children: [
                          Text(
                            user.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
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
                      width: 5,
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
                      width: 5,
                    ),
                    TextButton(
                      child: Text('ВОЗДЕРЖАЛСЯ'),
                      onPressed: () {
                        if (_initialChoices.containsKey(userId)) {
                          _initialChoices[userId] = 'ВОЗДЕРЖАЛСЯ';
                        } else {
                          _initialChoices
                              .addAll(<String, String>{userId: 'ВОЗДЕРЖАЛСЯ'});
                        }
                        setStateForDialog(() {});
                      },
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
