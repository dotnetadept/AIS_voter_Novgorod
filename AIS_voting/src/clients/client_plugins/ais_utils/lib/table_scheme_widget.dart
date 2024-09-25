import 'dart:async';
import 'package:ais_utils/ais_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'time_util.dart';

class TableSchemeWidget extends StatefulWidget {
  TableSchemeWidget({
    Key? key,
    required this.settings,
    required this.serverState,
    required this.group,
    required this.interval,
    required this.users,
    required this.isOperatorView,
    required this.timeOffset,
    required this.setRegistration,
    required this.undoRegistration,
    required this.setSpeaker,
    required this.removeAskWord,
    required this.setCurrentSpeaker,
    required this.setGuestSpeaker,
    this.removeGuestAskWord,
    required this.setTribuneSpeaker,
    required this.setUser,
    required this.setUserExit,
    required this.setTerminalReset,
    required this.setTerminalShutdown,
    required this.setTerminalScreenOff,
    required this.setTerminalScreenOn,
    this.addUserAskWord,
    required this.setResetAll,
    required this.setRefreshStreamAll,
    required this.setShutdownAll,
  }) : super(key: key);

  final Settings settings;
  final ServerState serverState;
  final Group group;
  final ais.Interval? interval;
  final List<User> users;
  final bool isOperatorView;
  final int timeOffset;

  final void Function(int) setRegistration;
  final void Function(int) undoRegistration;
  final void Function(String, bool) setSpeaker;
  final void Function(String, String) setCurrentSpeaker;
  final void Function(String) setGuestSpeaker;
  final void Function(int) removeAskWord;
  final void Function(String)? removeGuestAskWord;
  final void Function(String, String) setTribuneSpeaker;
  final void Function(String, int) setUser;
  final void Function(String) setUserExit;
  final void Function(String) setTerminalReset;
  final void Function(String) setTerminalShutdown;
  final void Function(String) setTerminalScreenOff;
  final void Function(String) setTerminalScreenOn;
  final Function(int)? addUserAskWord;
  final void Function() setResetAll;
  final void Function() setShutdownAll;
  final void Function() setRefreshStreamAll;

  @override
  _TableSchemeStateWidgetState createState() => _TableSchemeStateWidgetState();
}

class _TableSchemeStateWidgetState extends State<TableSchemeWidget> {
  bool _isSchemeInversed = false;
  bool _isShowTribune = false;
  bool _isControlSound = false;
  var _autoSizeGroup = AutoSizeGroup();
  late Timer _clockTimer;

  @override
  void initState() {
    _clockTimer = Timer.periodic(Duration(seconds: 1), (v) {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOperatorView) {
      _isControlSound = widget.settings.operatorSchemeSettings.controlSound;
      _isSchemeInversed = widget.settings.operatorSchemeSettings.inverseScheme;
      _isShowTribune = widget.settings.operatorSchemeSettings.showTribune;
    } else {
      _isControlSound = widget.settings.managerSchemeSettings.controlSound;
      _isSchemeInversed = widget.settings.managerSchemeSettings.inverseScheme;
      _isShowTribune = widget.settings.managerSchemeSettings.showTribune;
    }

    // if (_isSchemeInversed) {
    //   schemeParts = schemeParts.reversed.toList();
    // }

    // return Column(children: schemeParts);

    // sort users in group by name
    for (int i = 0; i < widget.group!.groupUsers.length; i++) {
      var user = widget.users.firstWhereOrNull(
          (element) => element.id == widget.group!.groupUsers[i].user.id);

      if (user != null) {
        widget.group!.groupUsers[i].user = user;
      }

      widget.group!.groupUsers
          .sort((a, b) => a.user.getFullName().compareTo(b.user.getFullName()));
    }

    return Expanded(
      child: leftPanel(),
    );
  }

  Widget leftPanel() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          getUnregistredTable(
                            'Незарегистрированные',
                            'Онлайн и карта не вставлена',
                            UsersFilterUtil.getUnregisterUserList(widget.users,
                                widget.group!, widget.serverState),
                          ),
                          getTable(
                            'Отсутствуют',
                            'Отсутствуют, карта не вставлена',
                            UsersFilterUtil.getAbsentUserList(widget.users,
                                widget.group!, widget.serverState),
                            Container(),
                          ),
                          getTable(
                            'Не голосовали',
                            'Не голосовали',
                            UsersFilterUtil.getNotVotedUserList(widget.users,
                                widget.group!, widget.serverState),
                            Container(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 5,
                    ),
                    Expanded(
                      flex: 3,
                      child: getGroupTable(
                        widget.group!,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 5,
              ),
              widget.isOperatorView
                  ? Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                getUsersAskWordTable(
                                  'Записавшиеся',
                                  'Записавшиеся',
                                  getAskwordUserList(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                getGuestsAskWordTable(
                                  'Записавшиеся гости',
                                  'Записавшиеся гости',
                                  widget.serverState.guestsAskSpeech,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                getMicsEnabledTable(
                                  'Включены микрофоны',
                                  'Включены микрофоны',
                                  getMicEnabledList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              widget.isOperatorView
                  ? Container(
                      width: 5,
                    )
                  : Container(),
            ],
          ),
        ),
        Container(
          height: 5,
        ),
      ],
    );
  }

  List<User> getAskwordUserList() {
    var usersAskingWord = <User>[];
    for (int i = 0; i < widget.serverState.usersAskSpeech.length; i++) {
      var foundUser = widget.users.firstWhereOrNull(
          (element) => element.id == widget.serverState.usersAskSpeech[i]);
      if (foundUser != null) {
        usersAskingWord.add(foundUser);
      }
    }

    return usersAskingWord;
  }

  Map<String, String> getMicEnabledList() {
    Map<String, String> usersMicEnabled = Map<String, String>();

    for (int micIndex = 0;
        micIndex < widget.serverState.activeMics.length;
        micIndex++) {
      var currentMic =
          widget.serverState.activeMics.entries.elementAt(micIndex);

      var userId = widget.serverState.usersTerminals[currentMic.key];
      var tribuneIndex =
          widget.group!.workplaces.tribuneTerminalIds.indexOf(currentMic.key);
      var guestPlace = widget.serverState.guestsPlaces
          .firstWhereOrNull((element) => element.terminalId == currentMic.key);

      if (userId != null) {
        usersMicEnabled.putIfAbsent(
          currentMic.key,
          () => widget.users
              .firstWhere((element) => element.id == userId)
              .getShortName(),
        );
      } else if (tribuneIndex != -1) {
        usersMicEnabled.putIfAbsent(
          currentMic.key,
          () => widget.group!.workplaces.tribuneNames[tribuneIndex],
        );
      } else if (guestPlace != null && guestPlace.name.isNotEmpty) {
        usersMicEnabled.putIfAbsent(
          currentMic.key,
          () => guestPlace.name,
        );
      } else {
        usersMicEnabled.putIfAbsent(
          currentMic.key,
          () => 'Гость[${currentMic.key}]',
        );
      }
    }

    return usersMicEnabled;
  }

  String getTerminalByUserId(User user) {
    return widget.serverState.usersTerminals.entries
            .firstWhereOrNull(
              (element) => element.value == user.id,
            )
            ?.key ??
        '00000';
  }

  Widget getUnregistredTable(String header, String tooltip, List<User> users,
      {int flex = 1}) {
    ScrollController controller = new ScrollController();
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Tooltip(
              message: tooltip,
              child: getTableHeader(
                '$header ${users.length}',
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              color: index % 2 == 0
                                  ? Colors.white
                                  : Colors.grey.withOpacity(0.2),
                            ),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Icon(Icons.person),
                                Text(users[index].getShortName()),
                                // Expanded(
                                //   child: Container(),
                                // ),
                                // TextButton(
                                //   style: ButtonStyle(
                                //     padding: WidgetStateProperty.all(
                                //         EdgeInsets.all(0)),
                                //   ),
                                //   onPressed: () {},
                                //   child: Text('рег.'),
                                // ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getUsersAskWordTable(String header, String tooltip, List<User> users,
      {int flex = 1}) {
    ScrollController controller = new ScrollController();
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Tooltip(
              message: tooltip,
              child: getTableHeader(
                '$header ${users.length}',
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            widget.setCurrentSpeaker(
                                getTerminalByUserId(users[index]),
                                users[index].getShortName());
                            widget.removeAskWord(users[index].id);
                          },
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                color: index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.withOpacity(0.2),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Icon(Icons.person),
                                  Text(users[index].getFullName()),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          EdgeInsets.all(0)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        widget.removeAskWord(users[index].id);
                                      });
                                    },
                                    child: Text('x'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getGuestsAskWordTable(
      String header, String tooltip, List<String> guests,
      {int flex = 1}) {
    ScrollController controller = new ScrollController();
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Tooltip(
              message: tooltip,
              child: getTableHeader(
                '$header ${guests.length}',
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      itemCount: guests.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            widget.setGuestSpeaker(guests[index]);
                            if (widget.removeGuestAskWord != null) {
                              widget.removeGuestAskWord!(guests[index]);
                            }
                          },
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                color: index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.withOpacity(0.2),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Icon(Icons.person),
                                  Text(widget.serverState.guestsPlaces
                                          .firstWhereOrNull((element) =>
                                              element.terminalId ==
                                              guests[index])
                                          ?.name ??
                                      'Гость[${guests[index]}]'),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          EdgeInsets.all(0)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (widget.removeGuestAskWord != null) {
                                          widget.removeGuestAskWord!(
                                              guests[index]);
                                        }
                                      });
                                    },
                                    child: Text('x'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getMicsEnabledTable(
      String header, String tooltip, Map<String, String> mics,
      {int flex = 1}) {
    ScrollController controller = new ScrollController();
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Tooltip(
              message: tooltip,
              child: getTableHeader(
                '$header ${mics.length}',
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      itemCount: mics.length,
                      itemBuilder: (BuildContext context, int index) {
                        var startDate = DateTime.parse(widget
                            .serverState.activeMics.entries
                            .firstWhereOrNull((element) =>
                                element.key == mics.keys.elementAt(index))!
                            .value);

                        var activeTime =
                            TimeUtil.getDateTimeNow(widget.timeOffset)
                                .difference(startDate);
                        String twoDigits(int n) => n.toString().padLeft(2, "0");
                        String activeTimeMinutes =
                            twoDigits(activeTime.inMinutes.remainder(60));
                        String activeTimeSeconds =
                            twoDigits(activeTime.inSeconds.remainder(60));

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.setSpeaker(
                                  mics.keys.elementAt(index), false);
                            });
                          },
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                color: index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.withOpacity(0.2),
                              ),
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Icon(Icons.person),
                                  Text(mics.values.elementAt(index)),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Text(
                                      "${activeTimeMinutes}:${activeTimeSeconds}"),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTable(
      String header, String tooltip, List<User> users, Widget button,
      {int flex = 1}) {
    ScrollController controller = new ScrollController();
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Tooltip(
              message: tooltip,
              child: getTableHeader(
                '$header ${users.length}',
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              color: index % 2 == 0
                                  ? Colors.white
                                  : Colors.grey.withOpacity(0.2),
                            ),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Icon(Icons.person),
                                Text(users[index].getShortName()),
                                Expanded(
                                  child: Container(),
                                ),
                                button,
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getGroupTable(Group group) {
    ScrollController controller = new ScrollController();

    List<User> registredUsers = UsersFilterUtil.getRegisteredUserList(
        widget.users, widget.group!, widget.serverState);

    var remainder =
        registredUsers.length % widget.settings.tableViewSettings.columnsCount;
    var ceil =
        (registredUsers.length / widget.settings.tableViewSettings.columnsCount)
            .ceil();

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Column(
        children: [
          getTableHeader(group.name),
          getGroupInfoPanel(group),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
                color: Colors.white.withOpacity(0.5),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                controller: controller,
                child: ListView.builder(
                    controller: controller,
                    itemCount: ceil,
                    itemBuilder: (BuildContext context, int index) {
                      var rowColor = index % 2 == 0
                          ? Colors.white
                          : Colors.grey.withOpacity(0.2);

                      List<Widget> userCells = <Widget>[];

                      for (int i = 0;
                          i < widget.settings.tableViewSettings.columnsCount;
                          i++) {
                        var userIndex = index *
                                widget.settings.tableViewSettings.columnsCount +
                            i;
                        if (userIndex < registredUsers.length) {
                          var user = registredUsers[userIndex];
                          userCells.add(getDetailedUser(
                            user,
                            rowColor,
                          ));
                        } else {
                          userCells.add(getEmptyUser(
                            rowColor,
                          ));
                        }
                      }

                      return Container(
                        color: Colors.white,
                        child: Row(children: userCells),
                      );
                    }),
              ),
            ),
          ),
          //getManagementScheme(group),
          widget.settings.tableViewSettings.showLegend
              ? getTribune(group)
              : Container(),
        ],
      ),
    );
  }

  Widget getManagementScheme(Group group) {
    List<Widget> managerCells = <Widget>[];

    if (group == null) {
      return new Container();
    }

    for (int i = 0; i < group.workplaces.schemeManagement.length; i++) {
      var user = widget.users.firstWhereOrNull(
          (element) => element.id == group.groupUsers[i].user.id);

      if (user != null) {
        managerCells.add(
          getDetailedUser(
            user,
            const Color.fromARGB(255, 231, 247, 255).withOpacity(0.2),
          ),
        );
      }
    }

    if (managerCells.length == 0) {
      return new Container();
    }

    // if (_isSchemeInversed) {
    //   managerCells = managerCells.reversed.toList();
    // }

    return Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: managerCells,
        ));
  }

  Widget getTribune(Group group) {
    List<Widget> tribuneCells = <Widget>[];

    if (group == null) {
      return new Container();
    }

    for (int i = 0; i < group.workplaces.tribuneTerminalIds.length; i++) {
      tribuneCells.add(getTribuneCell(group.workplaces.tribuneNames[i],
          group.workplaces.tribuneTerminalIds[i]));
    }

    if (tribuneCells.length == 0) {
      return new Container();
    }

    // if (_isSchemeInversed) {
    //   managerCells = managerCells.reversed.toList();
    // }

    tribuneCells.insert(
      0,
      Expanded(
        child: Container(),
      ),
    );

    tribuneCells.insert(
      tribuneCells.length,
      Expanded(
        child: Container(),
      ),
    );

    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: tribuneCells,
        ));
  }

  Widget getGroupInfoPanel(Group group) {
    List<Widget> controls = <Widget>[];

    for (int i = 0;
        i < widget.settings.tableViewSettings.headerItems.length;
        i++) {
      var item = widget.settings.tableViewSettings.headerItems[i];

      if (item.isVisible) {
        if (item.value == HeaderItemValue.RegistredCount) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${widget.serverState.usersRegistered.length.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
        if (item.value == HeaderItemValue.RegistredCount) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${group.groupUsers.length.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
        if (item.value == HeaderItemValue.VotedYes) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${widget.serverState.usersDecisions.values.where((element) => element == 'ЗА').length.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
        if (item.value == HeaderItemValue.VotedNo) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${widget.serverState.usersDecisions.values.where((element) => element == 'ПРОТИВ').length.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
        if (item.value == HeaderItemValue.VotedIndifferent) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${widget.serverState.usersDecisions.values.where((element) => element == 'ВОЗДЕРЖАЛСЯ').length.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
        if (item.value == HeaderItemValue.VotedTotal) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${widget.serverState.usersDecisions.values.length.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
        if (item.value == HeaderItemValue.QuorumCount) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${group.quorumCount.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
        if (item.value == HeaderItemValue.ChosenCount) {
          controls.add(Container(width: 15));
          controls.add(AutoSizeText(
            '${item.name}: ${group.chosenCount.toString()}',
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ));
        }
      }
    }

    controls.insert(0, Expanded(child: Container()));
    controls.insert(controls.length, Expanded(child: Container()));

    return Container(
      padding: EdgeInsets.all(5),
      color: Colors.lightBlueAccent.withOpacity(0.3),
      child: Row(
        children: controls,
      ),
    );
  }

  Widget getDetailedUser(User user, Color cellColor) {
    // mic and speaker icons
    String terminalId = getTerminalByUserId(user);

    var isUserAskSpeech = widget.serverState.usersAskSpeech.contains(user.id);
    var isMicEnabled = widget.serverState.activeMics.entries
        .any((element) => element.key == terminalId);

    var setSpeakerTooltip =
        isMicEnabled ? 'Выключить микрофон' : 'Включить микрофон';

    Color micColor = Colors.transparent;

    if (isUserAskSpeech) {
      micColor = Colors.green;
    }
    if (isMicEnabled) {
      micColor = Colors.red;
    }

    var iconSize = widget.settings.operatorSchemeSettings.iconSize.toDouble();

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          color: cellColor,
        ),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            widget.settings.tableViewSettings.cellTextAlign == 'Слева'
                ? Container()
                : Expanded(
                    child: Container(),
                  ),
            Text(
              user.getShortName(),
            ),
            Expanded(
              child: Container(),
            ),
            SizedBox(
              height: iconSize,
              width: iconSize,
              child: Tooltip(
                preferBelow: !widget.isOperatorView,
                waitDuration: Duration(seconds: 2),
                message: setSpeakerTooltip,
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                    side: widget.interval == null
                        ? null
                        : WidgetStateProperty.all(BorderSide(width: 1)),
                    backgroundColor: WidgetStateProperty.all(micColor),
                    overlayColor: WidgetStateProperty.all(
                        Colors.blueAccent.withAlpha(125)),
                  ),
                  child: Icon(
                    Icons.mic,
                    size: iconSize,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (isUserAskSpeech) {
                      widget.setSpeaker(terminalId, true);
                    } else {
                      if (isMicEnabled) {
                        widget.setSpeaker(terminalId, false);
                      } else {
                        if (widget.addUserAskWord != null) {
                          widget.addUserAskWord!(user.id);
                        }
                      }
                    }

                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getEmptyUser(Color cellColor) {
    return Expanded(
      child: Container(
        height: widget.settings.operatorSchemeSettings.iconSize + 12.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          color: cellColor,
        ),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTribuneCell(String tribuneName, String terminalId) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          color: Colors.lightBlue,
        ),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(
              Icons.mic,
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              tribuneName,
            ),
            Expanded(
              child: Container(),
            ),
            Icon(Icons.monitor),
          ],
        ),
      ),
    );
  }

  Widget getTableHeader(String text) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.lightBlue,
            child: Text(
              text,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: widget
                      .settings.managerSchemeSettings.deputyCaptionFontSize
                      .toDouble()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();

    super.dispose();
  }
}
