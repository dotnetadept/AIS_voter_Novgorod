import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:ais_utils/ais_utils.dart';

class WorkplacesSchemeWidget extends StatefulWidget {
  WorkplacesSchemeWidget(
      {Key key,
      this.settings,
      this.serverState,
      this.group,
      this.interval,
      this.isOperatorView,
      this.setRegistration,
      this.undoRegistration,
      this.setSpeaker,
      this.setCurrentSpeaker,
      this.setTribuneSpeaker,
      this.setUser,
      this.setUserExit,
      this.setTerminalReset,
      this.setTerminalShutdown,
      this.setTerminalScreenOff,
      this.setTerminalScreenOn,
      this.setResetAll,
      this.setRefreshStreamAll,
      this.setShutdownAll,
      this.saveGroup,
      this.addGuest,
      this.removeGuest,
      this.addGuestAskWord,
      this.removeGuestAskWord,
      this.addUserAskWord})
      : super(key: key);

  final Settings settings;
  final ServerState serverState;
  final Group group;
  final ais.Interval interval;
  final bool isOperatorView;

  final void Function(int) setRegistration;
  final void Function(int) undoRegistration;
  final void Function(String, bool) setSpeaker;
  final void Function(String, String) setCurrentSpeaker;
  final void Function(String, String) setTribuneSpeaker;
  final void Function(String, int) setUser;
  final void Function(String) setUserExit;
  final void Function(String) setTerminalReset;
  final void Function(String) setTerminalShutdown;
  final void Function(String) setTerminalScreenOff;
  final void Function(String) setTerminalScreenOn;
  final void Function() setResetAll;
  final void Function() setShutdownAll;
  final void Function() setRefreshStreamAll;
  final void Function(Group) saveGroup;
  final void Function(String, String) addGuest;
  final void Function(String) removeGuest;
  final void Function(String) addGuestAskWord;
  final void Function(String) removeGuestAskWord;
  final void Function(int) addUserAskWord;

  @override
  _WorkplacesSchemeStateWidgetState createState() =>
      _WorkplacesSchemeStateWidgetState();
}

class _WorkplacesSchemeStateWidgetState extends State<WorkplacesSchemeWidget> {
  bool _isSchemeInversed = false;
  bool _isShowTribune = false;
  bool _isControlSound = false;

  TextEditingController _searchGuestController = TextEditingController();

  @override
  void initState() {
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

    List<Widget> schemeParts = <Widget>[
      getWorkplacesScheme(),
      getManagementScheme(),
      getTribuneScheme(),
    ];

    if (_isSchemeInversed) {
      schemeParts = schemeParts.reversed.toList();
    }

    return Column(children: schemeParts);
  }

  Widget getWorkplacesScheme() {
    if (widget.group == null) {
      return new Container();
    }

    List<Widget> columns = <Widget>[];

    var alternateRowNumbers = widget
        .settings.palletteSettings.alternateRowNumbers
        .split(',')
        .map((e) => int.parse(e))
        .toList();

    for (int i = 0; i < widget.group.workplaces.rows.length; i++) {
      var row = widget.group.workplaces.rows[i];
      var isDisplayEmptyCell = widget.group.workplaces.isDisplayEmptyCell[i];
      List<Widget> currentRow = <Widget>[];

      bool isAlternateRow = alternateRowNumbers.contains(i);
      for (int j = 0; j < row; j++) {
        currentRow.add(
          createUserCell(
            widget.group,
            widget.group.workplaces.workplacesTerminalIds[i][j],
            widget.serverState.usersTerminals[
                widget.group.workplaces.workplacesTerminalIds[i][j]],
            isDisplayEmptyCell,
            isAlternateRow
                ? Color(widget.settings.palletteSettings.alternateCellColor)
                : Color(widget.settings.palletteSettings.cellColor),
            false,
          ),
        );
      }

      if (_isSchemeInversed) {
        currentRow = currentRow.reversed.toList();
      }

      Widget column = Column(
        children: currentRow,
      );

      var paddingRowNumbers = widget.settings.palletteSettings.paddingRowNumbers
          .split(',')
          .map((e) => int.parse(e))
          .toList();
      bool isPaddingRow = paddingRowNumbers.contains(i);
      var alternatePadding =
          widget.settings.palletteSettings.alternateRowPadding.toDouble();

      if (!isPaddingRow && paddingRowNumbers.contains(i + 1)) {
        column = Container(
          padding: EdgeInsets.fromLTRB(_isSchemeInversed ? alternatePadding : 0,
              0, _isSchemeInversed ? 0 : alternatePadding, 0),
          child: column,
        );
      } else if (isPaddingRow && !paddingRowNumbers.contains(i + 1)) {
        column = Container(
          padding: EdgeInsets.fromLTRB(_isSchemeInversed ? alternatePadding : 0,
              0, _isSchemeInversed ? 0 : alternatePadding, 0),
          child: column,
        );
      }
      columns.add(column);
    }

    if (_isSchemeInversed) {
      columns = columns.reversed.toList();
    }

    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: _isSchemeInversed
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: columns,
        ));
  }

  Widget getManagementScheme() {
    List<Widget> managerCells = <Widget>[];

    if (widget.group == null) {
      return new Container();
    }

    for (int i = 0; i < widget.group.workplaces.schemeManagement.length; i++) {
      managerCells.add(createUserCell(
        widget.group,
        widget.group.workplaces.managementTerminalIds[i],
        widget.serverState
            .usersTerminals[widget.group.workplaces.managementTerminalIds[i]],
        widget.group.workplaces.showEmptyManagement,
        Color(widget.settings.palletteSettings.cellColor),
        true,
      ));
    }

    if (managerCells.length == 0) {
      return new Container();
    }

    if (_isSchemeInversed) {
      managerCells = managerCells.reversed.toList();
    }

    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: managerCells,
        ));
  }

  Widget guestPopupItemBuilder(
      BuildContext context, String item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Row(
          children: [
            Expanded(
              child: Text(item.toString()),
            ),
            TextButton(
              onPressed: () {
                widget.group.guests = widget.group.guests
                    .replaceAll(',${item.toString()}', '')
                    .replaceAll('${item.toString()}', '');

                widget.saveGroup(widget.group);
                widget.removeGuest(item.toString());
              },
              child: Icon(Icons.clear),
            ),
          ],
        ),
      ),
    );
  }

  Widget guestDropDownBuilder(
      BuildContext context, String item, String itemDesignation) {
    return Container(
      height: 20,
      child: (item == null)
          ? Container()
          : ListTile(
              contentPadding: EdgeInsets.all(0.0),
              tileColor: Colors.blue,
              title: Align(
                child: Text(
                  item.toString(),
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                alignment: Alignment(0, -7),
              ),
            ),
    );
  }

  Widget createGuestCell(
    String terminalId,
    String guest,
    Color cellBackground,
    bool isManagementSection,
  ) {
    var isTerminalOnline =
        widget.serverState.terminalsOnline.contains(terminalId);

    var isUserAskSpeech =
        widget.serverState.guestsAskSpeech.contains(terminalId);
    var isMicEnabled = widget.serverState.activeMics.entries
        .any((element) => element.key == terminalId);

    Color defaultColor = Colors.white;
    Color userColor = isUserAskSpeech
        ? Color(widget.settings.palletteSettings.askWordColor)
        : defaultColor;

    var cellPadding = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.cellInnerPadding.toDouble()
        : widget.settings.managerSchemeSettings.cellInnerPadding.toDouble();

    var iconSize = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.iconSize.toDouble()
        : widget.settings.managerSchemeSettings.iconSize.toDouble();

    var overflowOption = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.overflowOption
        : widget.settings.managerSchemeSettings.overflowOption;
    var showOverflow = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.showOverflow
        : widget.settings.managerSchemeSettings.showOverflow;
    TextOverflow textOverflowOption = (overflowOption == 'Обрезать текст')
        ? (showOverflow ? TextOverflow.ellipsis : TextOverflow.clip)
        : TextOverflow.clip;
    var maxLines = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.textMaxLines
        : widget.settings.managerSchemeSettings.textMaxLines;

    // mic and speaker icons
    var setSpeakerTooltip =
        isMicEnabled ? 'Выключить микрофон' : 'Включить микрофон';

    Color micColor = Colors.transparent;
    if (isUserAskSpeech) {
      micColor = Colors.green;
    }
    if (isMicEnabled) {
      micColor = Colors.red;
    }

    // ask word icon
    String askWordOrder = '--';
    if (widget.serverState.guestsAskSpeech.contains(terminalId)) {
      askWordOrder =
          (widget.serverState.guestsAskSpeech.indexOf(terminalId) + 1)
              .toString()
              .padLeft(2, '0');
    }

    var cellWidth = getCellWidth(isManagementSection);

    List<Widget> buttons = <Widget>[];
    buttons.add(Icon(
      Icons.circle,
      color: isTerminalOnline
          ? Color(widget.settings.palletteSettings.iconOnlineColor)
          : Color(widget.settings.palletteSettings.iconOfflineColor),
      size: iconSize,
    ));

    widget.isOperatorView
        ? buttons.add(getUserOptions(terminalId, null, Colors.white))
        : buttons.add(Icon(
            Icons.person,
            color: Colors.white,
            size: iconSize,
          ));
    buttons.add(Container(
      width: 5,
    ));

    buttons.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, cellPadding, 0, cellPadding),
        width: iconSize * 2,
        child: SizedBox(
          height: iconSize,
          width: cellWidth,
          child: Tooltip(
            preferBelow: !widget.isOperatorView,
            waitDuration: Duration(seconds: widget.isOperatorView ? 2 : 0),
            message: 'Очередь на выступление',
            child: Container(
              decoration: BoxDecoration(
                color: askWordOrder == '--'
                    ? Colors.white
                    : Color(widget.settings.palletteSettings.askWordColor),
                border: Border.all(
                    width: askWordOrder == '--' ? 0 : 2, color: Colors.green),
              ),
              alignment: Alignment.center,
              child: Text(
                askWordOrder,
              ),
            ),
          ),
        ),
      ),
    );

    buttons.add(Expanded(child: Container()));

    if (widget.isOperatorView) {
      buttons.add(
        Container(
          margin: EdgeInsets.fromLTRB(
            0,
            0,
            cellPadding,
            0,
          ),
          child: Text(
            terminalId,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      buttons.add(
        Container(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            cellPadding,
            0,
          ),
          child: SizedBox(
            height: iconSize,
            width: iconSize,
            child: Tooltip(
              preferBelow: !widget.isOperatorView,
              waitDuration: Duration(seconds: widget.isOperatorView ? 2 : 0),
              message: 'Выступление',
              child: IconButton(
                padding: EdgeInsets.fromLTRB(0, 0, cellPadding, 0),
                alignment: Alignment.topCenter,
                color: (widget.serverState.speakerSession != null &&
                        widget.serverState.speakerSession.name == guest)
                    ? Colors.green
                    : Colors.red,
                icon: Icon(Icons.monitor, size: iconSize),
                onPressed: () {
                  widget.setTribuneSpeaker(terminalId, guest);
                },
              ),
            ),
          ),
        ),
      );
    }

    if (_isControlSound) {
      if (widget.isOperatorView || isMicEnabled) {
        buttons.add(
          SizedBox(
            height: iconSize,
            width: iconSize,
            child: Tooltip(
              preferBelow: !widget.isOperatorView,
              waitDuration: Duration(seconds: widget.isOperatorView ? 2 : 0),
              message: setSpeakerTooltip,
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                  side: widget.interval == null
                      ? null
                      : MaterialStateProperty.all(BorderSide(width: 1)),
                  backgroundColor: MaterialStateProperty.all(micColor),
                  overlayColor: MaterialStateProperty.all(
                      Colors.blueAccent.withAlpha(125)),
                ),
                child: Icon(
                  Icons.mic,
                  size: iconSize,
                  color: Colors.white,
                ),
                onPressed: !widget.isOperatorView
                    ? null
                    : () {
                        if (isUserAskSpeech) {
                          widget.setSpeaker(terminalId, true);
                        } else {
                          if (isMicEnabled) {
                            widget.setSpeaker(terminalId, false);
                          } else {
                            widget.addGuestAskWord(terminalId);
                          }
                        }

                        setState(() {});
                      },
              ),
            ),
          ),
        );
      }
    }

    var textFieldHeight = (getCellHeight() / 2).floor().toDouble() -
        cellPadding / 2 -
        2 -
        (widget.isOperatorView ? 0 : 3);

    var guests = (widget.group.guests ?? '').split(',').toList();
    guests.sort((a, b) => a.compareTo(b));

    Widget cell = Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(cellPadding,
              cellPadding - (widget.isOperatorView ? 2 : 1), cellPadding, 0.0),
          width: cellWidth,
          height: textFieldHeight,
          decoration: BoxDecoration(
            color: userColor,
          ),
          child: widget.isOperatorView
              ? DropdownSearch<String>(
                  searchBoxController: _searchGuestController,
                  searchBoxStyle: TextStyle(
                    fontSize: 20,
                  ),
                  mode: Mode.DIALOG,
                  showSearchBox: true,
                  showClearButton: guest != null && guest.isNotEmpty,
                  clearButtonBuilder: (context) {
                    return Icon(Icons.clear);
                  },
                  dropdownButtonBuilder: (context) {
                    return Icon(Icons.arrow_drop_down);
                  },
                  items: guests,
                  popupTitle: Container(
                    alignment: Alignment.center,
                    color: Colors.blueAccent,
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Гости',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 28),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.indigoAccent),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.fromLTRB(0, 15, 0, 15)),
                            shape: MaterialStateProperty.all(
                              CircleBorder(
                                side: BorderSide(color: Colors.transparent),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  hint: 'Выберите гостя',
                  selectedItem: guest,
                  onChanged: (value) {
                    setState(() {
                      widget.addGuest(value, terminalId);
                    });
                  },
                  dropdownBuilder: guestDropDownBuilder,
                  popupItemBuilder: guestPopupItemBuilder,
                  emptyBuilder: (context, searchEntry) {
                    return Center(
                        child: TextButton(
                      child: Text('Добавить гостя'),
                      onPressed: () {
                        setState(() {
                          if (widget.group.guests != null &&
                              widget.group.guests.isNotEmpty) {
                            widget.group.guests +=
                                ',' + _searchGuestController.text;
                          } else {
                            widget.group.guests = _searchGuestController.text;
                          }
                        });

                        widget.saveGroup(widget.group);
                        widget.addGuest(
                            _searchGuestController.text, terminalId);
                      },
                    ));
                  },
                  onPopupDismissed: () {
                    setState(() {
                      _searchGuestController.text = '';
                    });
                  },
                )
              : Container(
                  padding: EdgeInsets.fromLTRB(0, cellPadding, 0, cellPadding),
                  width: cellWidth,
                  decoration: BoxDecoration(
                    color: userColor,
                  ),
                  child: Tooltip(
                    preferBelow: !widget.isOperatorView,
                    waitDuration:
                        Duration(seconds: widget.isOperatorView ? 2 : 0),
                    message: guest,
                    child: Text(
                      '$guest',
                      maxLines:
                          overflowOption == 'Обрезать текст' ? maxLines : null,
                      overflow: textOverflowOption,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: widget.isOperatorView
                            ? widget
                                .settings.operatorSchemeSettings.cellTextSize
                                .toDouble()
                            : widget.settings.managerSchemeSettings.cellTextSize
                                .toDouble(),
                        color: Color(
                            widget.settings.palletteSettings.cellTextColor),
                      ),
                    ),
                  ),
                ),
        ),
        widget.isOperatorView
            ? Container()
            : Container(
                height: cellPadding,
              ),
        Container(
          width: cellWidth,
          child: Row(
            children: buttons,
          ),
        ),
      ],
    );

    var verticalPadding = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.cellOuterPaddingVertical
            .toDouble()
        : widget.settings.managerSchemeSettings.cellOuterPaddingVertical
            .toDouble();
    var horisontalPadding = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.cellOuterPaddingHorisontal
            .toDouble()
        : widget.settings.managerSchemeSettings.cellOuterPaddingHorisontal
            .toDouble();

    return Container(
      padding: EdgeInsets.fromLTRB(horisontalPadding, verticalPadding,
          horisontalPadding, verticalPadding),
      child: Container(
          decoration: BoxDecoration(
            color: cellBackground,
            border: Border.all(
              color: Color(widget.settings.palletteSettings.cellBorderColor),
              width: widget.isOperatorView
                  ? widget.settings.operatorSchemeSettings.cellBorder.toDouble()
                  : widget.settings.managerSchemeSettings.cellBorder.toDouble(),
            ),
          ),
          child: cell),
    );
  }

  Widget createUserCell(
    Group selectedGroup,
    String terminalId,
    int userId,
    bool isDisplayEmptyCell,
    Color cellBackground,
    bool isManagementSection,
  ) {
    if (GroupUtil.isTerminalGuest(widget.serverState, terminalId)) {
      //return guest cell
      var guestPlaceFound = widget.serverState.guestsPlaces.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null,
      );

      return createGuestCell(
        terminalId,
        guestPlaceFound?.name ?? '',
        cellBackground,
        isManagementSection,
      );
    }
    if (terminalId == null || terminalId.isEmpty) {
      if (isDisplayEmptyCell) {
        // return empty cell
        var verticalPadding = widget.isOperatorView
            ? widget.settings.operatorSchemeSettings.cellOuterPaddingVertical
                .toDouble()
            : widget.settings.managerSchemeSettings.cellOuterPaddingVertical
                .toDouble();
        var horisontalPadding = widget.isOperatorView
            ? widget.settings.operatorSchemeSettings.cellOuterPaddingHorisontal
                .toDouble()
            : widget.settings.managerSchemeSettings.cellOuterPaddingHorisontal
                .toDouble();

        return Padding(
            padding: EdgeInsets.fromLTRB(horisontalPadding, verticalPadding,
                horisontalPadding, verticalPadding),
            child: Container(
              //color: Colors.red,
              width: getCellWidth(isManagementSection),
              height: getCellHeight(),
            ));
      } else {
        return Container();
      }
    }

    var selectedUser = selectedGroup.groupUsers
        .firstWhere((element) => element.user.id == userId, orElse: () => null);

    var verticalPadding = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.cellOuterPaddingVertical
            .toDouble()
        : widget.settings.managerSchemeSettings.cellOuterPaddingVertical
            .toDouble();
    var horisontalPadding = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.cellOuterPaddingHorisontal
            .toDouble()
        : widget.settings.managerSchemeSettings.cellOuterPaddingHorisontal
            .toDouble();

    var cell = Container(
      decoration: BoxDecoration(
        color: cellBackground,
        border: Border.all(
          color: Color(widget.settings.palletteSettings.cellBorderColor),
          width: widget.isOperatorView
              ? widget.settings.operatorSchemeSettings.cellBorder.toDouble()
              : widget.settings.managerSchemeSettings.cellBorder.toDouble(),
        ),
      ),
      child: getCellContent(
          selectedGroup, terminalId, selectedUser, isManagementSection),
    );

    return Padding(
        padding: EdgeInsets.fromLTRB(horisontalPadding, verticalPadding,
            horisontalPadding, verticalPadding),
        child: cell);
  }

  Widget getCellContent(Group selectedGroup, String terminalId,
      GroupUser selectedUser, bool isManagementSection) {
    var selectedUserName = '';
    var selectedUserFullName = '';
    if (selectedUser != null) {
      selectedUserFullName = selectedUser.user.getFullName();
      if (widget.isOperatorView) {
        if (widget.settings.operatorSchemeSettings.isShortNamesUsed) {
          selectedUserName = selectedUser.user.getShortName();
        } else {
          selectedUserName = selectedUser.user.getFullName();
        }
      } else {
        if (widget.settings.managerSchemeSettings.isShortNamesUsed) {
          selectedUserName = selectedUser.user.getShortName();
        } else {
          selectedUserName = selectedUser.user.getFullName();
        }
      }
    }

    int userId = selectedUser?.user?.id;

    var isTerminalOnline =
        widget.serverState.terminalsOnline.contains(terminalId);
    var isUserOnline =
        widget.serverState.usersTerminals.values.contains(userId);
    var isUserRegistred = widget.serverState.usersRegistered.contains(userId);

    var isUserAskSpeech = widget.serverState.usersAskSpeech.contains(userId);
    var isUserOnSpeech = widget.serverState.usersOnSpeech.contains(userId);

    var isUserVotingPositive =
        widget.serverState.usersDecisions.keys.contains(userId.toString()) &&
            widget.serverState.usersDecisions[userId.toString()] == 'ЗА';
    var isUserVotingNegative =
        widget.serverState.usersDecisions.keys.contains(userId.toString()) &&
            widget.serverState.usersDecisions[userId.toString()] == 'ПРОТИВ';
    var isUserVotingIndifferent = widget.serverState.usersDecisions.keys
            .contains(userId.toString()) &&
        widget.serverState.usersDecisions[userId.toString()] == 'ВОЗДЕРЖАЛСЯ';

    var isDocumentsLoading =
        widget.serverState.terminalsLoadingDocuments.contains(terminalId);
    var isDocumentsDownloaded =
        widget.serverState.terminalsWithDocuments.contains(terminalId);
    var isDocumentsError =
        widget.serverState.terminalsDocumentErrors.keys.contains(terminalId);

    var isMicEnabled = widget.serverState.activeMics.entries
        .any((element) => element.key == terminalId);

    // user icon
    var userIconColor =
        Color(widget.settings.palletteSettings.iconOfflineColor);
    if (isUserOnline) {
      userIconColor = Color(widget.settings.palletteSettings.iconOnlineColor);
      userIconColor = isUserRegistred
          ? Color(widget.settings.palletteSettings.registredColor)
          : Color(widget.settings.palletteSettings.unRegistredColor);
    }

    // user name textbox
    Color defaultColor = Colors.white;
    Color userColor = isUserAskSpeech
        ? Color(widget.settings.palletteSettings.askWordColor)
        : defaultColor;

    if (widget.serverState.systemState == SystemState.Registration) {
      userColor = isUserRegistred
          ? Color(widget.settings.palletteSettings.registredColor)
          : Color(widget.settings.palletteSettings.unRegistredColor);
    }

    userColor = isUserOnSpeech
        ? Color(widget.settings.palletteSettings.onSpeechColor)
        : userColor;
    userColor = isUserVotingPositive
        ? Color(widget.settings.palletteSettings.voteYesColor)
        : userColor;
    userColor = isUserVotingNegative
        ? Color(widget.settings.palletteSettings.voteNoColor)
        : userColor;
    userColor = isUserVotingIndifferent
        ? Color(widget.settings.palletteSettings.voteIndifferentColor)
        : userColor;

    // document icon
    Color documentsIconColor =
        Color(widget.settings.palletteSettings.iconDocumentsNotDownloadedColor);
    String documentsIconTooltip = 'Не загружены';

    if (isDocumentsLoading) {
      documentsIconColor = Colors.yellowAccent;
      documentsIconTooltip = 'Идет загрузка';
    }
    if (isDocumentsDownloaded) {
      documentsIconColor =
          Color(widget.settings.palletteSettings.iconDocumentsDownloadedColor);
      documentsIconTooltip = 'Загружены';
    }
    if (isDocumentsError) {
      documentsIconColor = Colors.purple;
      documentsIconTooltip =
          'Ошибка: ' + widget.serverState.terminalsDocumentErrors[terminalId];
    }

    // mic and speaker icons
    var setSpeakerTooltip =
        isMicEnabled ? 'Выключить микрофон' : 'Включить микрофон';

    Color micColor = Colors.transparent;
    if (isUserAskSpeech) {
      micColor = Colors.green;
    }
    if (isMicEnabled) {
      micColor = Colors.red;
    }

    // ask word icon
    String askWordOrder = '--';
    if (widget.serverState.usersAskSpeech.contains(userId)) {
      askWordOrder = (widget.serverState.usersAskSpeech.indexOf(userId) + 1)
          .toString()
          .padLeft(2, '0');
    }

    // cell size settings
    var cellPadding = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.cellInnerPadding.toDouble()
        : widget.settings.managerSchemeSettings.cellInnerPadding.toDouble();
    var overflowOption = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.overflowOption
        : widget.settings.managerSchemeSettings.overflowOption;
    var maxLines = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.textMaxLines
        : widget.settings.managerSchemeSettings.textMaxLines;

    var showOverflow = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.showOverflow
        : widget.settings.managerSchemeSettings.showOverflow;

    var iconSize = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.iconSize.toDouble()
        : widget.settings.managerSchemeSettings.iconSize.toDouble();

    List<Widget> buttons = <Widget>[];
    if (widget.isOperatorView) {
      buttons.add(Icon(
        Icons.circle,
        color: isTerminalOnline
            ? Color(widget.settings.palletteSettings.iconOnlineColor)
            : Color(widget.settings.palletteSettings.iconOfflineColor),
        size: iconSize,
      ));
      buttons.add(
        !(SystemStateHelper.isStarted(widget.serverState.systemState) ||
                SystemStateHelper.isPreparation(widget.serverState.systemState))
            ? Icon(
                Icons.person,
                color: userIconColor,
                size: iconSize,
              )
            : Tooltip(
                preferBelow: !widget.isOperatorView,
                waitDuration: Duration(seconds: widget.isOperatorView ? 2 : 0),
                message: selectedUserFullName,
                child: getUserOptions(terminalId, userId, userIconColor),
              ),
      );
    }

    if (!widget.isOperatorView) {
      buttons.add(Icon(
        Icons.person,
        color: userIconColor,
        size: iconSize,
      ));
    }

    var cellWidth = getCellWidth(isManagementSection);

    buttons.add(
      Expanded(
        child: Container(),
      ),
    );

    buttons.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, cellPadding, 0, cellPadding),
        width: iconSize * 2,
        child: SizedBox(
          height: iconSize,
          width: cellWidth,
          child: Tooltip(
            preferBelow: !widget.isOperatorView,
            waitDuration: Duration(seconds: widget.isOperatorView ? 2 : 0),
            message: 'Очередь на выступление',
            child: Container(
              decoration: BoxDecoration(
                color: askWordOrder == '--'
                    ? Colors.white
                    : Color(widget.settings.palletteSettings.askWordColor),
                border: Border.all(
                    width: askWordOrder == '--' ? 0 : 2, color: Colors.green),
              ),
              alignment: Alignment.center,
              child: Text(
                askWordOrder,
              ),
            ),
          ),
        ),
      ),
    );

    buttons.add(
      Expanded(
        child: Container(),
      ),
    );

    if (widget.isOperatorView) {
      buttons.add(
        Container(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            cellPadding,
            0,
          ),
          child: SizedBox(
            height: iconSize,
            width: iconSize,
            child: IconButton(
              padding: EdgeInsets.all(0),
              alignment: Alignment.topCenter,
              color: (widget.serverState.speakerSession != null &&
                      widget.serverState.speakerSession.terminalId ==
                          terminalId)
                  ? Colors.green
                  : Colors.red,
              icon: Icon(Icons.monitor, size: iconSize),
              onPressed: () {
                setState(() {
                  widget.setCurrentSpeaker(terminalId, null);
                });
              },
            ),
          ),
        ),
      );
    }

    if (_isControlSound) {
      if (widget.isOperatorView || isMicEnabled) {
        buttons.add(
          SizedBox(
            height: iconSize,
            width: iconSize,
            child: Tooltip(
              preferBelow: !widget.isOperatorView,
              waitDuration: Duration(seconds: widget.isOperatorView ? 2 : 0),
              message: setSpeakerTooltip,
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                  side: widget.interval == null
                      ? null
                      : MaterialStateProperty.all(BorderSide(width: 1)),
                  backgroundColor: MaterialStateProperty.all(micColor),
                  overlayColor: MaterialStateProperty.all(
                      Colors.blueAccent.withAlpha(125)),
                ),
                child: Icon(
                  Icons.mic,
                  size: iconSize,
                  color: Colors.white,
                ),
                onPressed: !widget.isOperatorView
                    ? null
                    : () {
                        if (isUserAskSpeech) {
                          widget.setSpeaker(terminalId, true);
                        } else {
                          if (isMicEnabled) {
                            widget.setSpeaker(terminalId, false);
                          } else {
                            widget.addUserAskWord(userId);
                          }
                        }

                        setState(() {});
                      },
              ),
            ),
          ),
        );
      }
    }

    TextOverflow textOverflowOption = (overflowOption == 'Обрезать текст')
        ? (showOverflow ? TextOverflow.ellipsis : TextOverflow.clip)
        : TextOverflow.clip;

    Widget cellContent = Column(
      children: [
        InkWell(
          onTap: !widget.isOperatorView
              ? null
              : () {
                  if (isUserAskSpeech) {
                    widget.setSpeaker(terminalId, true);
                  } else {
                    if (isMicEnabled) {
                      widget.setSpeaker(terminalId, false);
                    } else {
                      widget.addUserAskWord(userId);
                    }
                  }

                  setState(() {});
                },
          child: Container(
            margin:
                EdgeInsets.fromLTRB(cellPadding, cellPadding, cellPadding, 0.0),
            padding: EdgeInsets.fromLTRB(0, cellPadding, 0, cellPadding),
            width: cellWidth,
            decoration: BoxDecoration(
              color: userColor,
            ),
            child: Tooltip(
              preferBelow: !widget.isOperatorView,
              waitDuration: Duration(seconds: widget.isOperatorView ? 2 : 0),
              message: selectedUserFullName,
              child: Text(
                '$selectedUserName',
                maxLines: overflowOption == 'Обрезать текст' ? maxLines : null,
                overflow: textOverflowOption,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: widget.isOperatorView
                        ? widget.settings.operatorSchemeSettings.cellTextSize
                            .toDouble()
                        : widget.settings.managerSchemeSettings.cellTextSize
                            .toDouble(),
                    color:
                        Color(widget.settings.palletteSettings.cellTextColor)),
              ),
            ),
          ),
        ),
        widget.isOperatorView
            ? Container()
            : Container(
                height: widget.settings.managerSchemeSettings.cellInnerPadding
                    .toDouble()),
        Container(
          width: cellWidth,
          child: Row(
            children: buttons,
          ),
        ),
      ],
    );

    return cellContent;
  }

  double getCellWidth(bool isManagementSection) {
    var cellWidth = 0.0;
    if (isManagementSection) {
      cellWidth = widget.isOperatorView
          ? widget.settings.operatorSchemeSettings.cellManagementWidth
              .toDouble()
          : widget.settings.managerSchemeSettings.cellManagementWidth
              .toDouble();
    } else {
      cellWidth = widget.isOperatorView
          ? widget.settings.operatorSchemeSettings.cellWidth.toDouble()
          : widget.settings.managerSchemeSettings.cellWidth.toDouble();
    }

    return cellWidth;
  }

  double getCellHeight() {
    double cellheight = 0.0;

    if (widget.isOperatorView) {
      cellheight = widget.settings.operatorSchemeSettings.cellBorder * 4 +
          widget.settings.operatorSchemeSettings.cellInnerPadding * 5 +
          widget.settings.operatorSchemeSettings.cellTextSize +
          widget.settings.operatorSchemeSettings.iconSize.toDouble();
    } else {
      cellheight = widget.settings.operatorSchemeSettings.cellBorder * 4.0 +
          widget.settings.managerSchemeSettings.cellInnerPadding * 6 +
          widget.settings.managerSchemeSettings.cellTextSize +
          widget.settings.managerSchemeSettings.iconSize.toDouble();
    }
    return cellheight;
  }

  Widget getUserOptions(String terminalId, int userId, Color userIconColor) {
    return PopupMenuButton(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          color: userIconColor,
        ),
      ),
      offset: Offset(0, 40),
      onSelected: (value) {
        if (value == 'setRegistration') {
          setState(() {
            widget.setRegistration(userId);
          });
        }
        if (value == 'undoRegistration') {
          setState(() {
            widget.undoRegistration(userId);
          });
        }
        if (value == 'setUser') {
          setState(() {
            widget.setUser(terminalId, userId);
          });
        }
        if (value == 'setUserExit') {
          setState(() {
            widget.setUserExit(terminalId);
          });
        }
        if (value == 'setScreenOn') {
          setState(() {
            widget.setTerminalScreenOn(terminalId);
          });
        }
        if (value == 'setScreenOff') {
          setState(() {
            widget.setTerminalScreenOff(terminalId);
          });
        }
        if (value == 'setReset') {
          setState(() {
            widget.setTerminalReset(terminalId);
          });
        }
        if (value == 'setShutdown') {
          setState(() {
            widget.setTerminalShutdown(terminalId);
          });
        }
        if (value == 'setResetAll') {
          setState(() {
            widget.setResetAll();
          });
        }
        if (value == 'setShutdownAll') {
          setState(() {
            widget.setShutdownAll();
          });
        }
        if (value == 'setRefreshStreamAll') {
          setState(() {
            widget.setRefreshStreamAll();
          });
        }
      },
      tooltip: '',
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: widget.serverState.terminalsOnline.contains(terminalId) &&
              widget.serverState.isRegistrationCompleted &&
              !widget.serverState.usersRegistered.contains(userId),
          value: 'setRegistration',
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.app_registration),
              ),
              Text('Зарегистрировать'),
            ],
          ),
        ),
        PopupMenuItem(
          enabled: widget.serverState.isRegistrationCompleted &&
              widget.serverState.usersRegistered.contains(userId),
          value: 'undoRegistration',
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.undo),
              ),
              Text('Снять регистрацию'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setUser',
          enabled: (SystemStateHelper.isPreparation(
                      widget.serverState.systemState) ||
                  SystemStateHelper.isStarted(
                      widget.serverState.systemState)) &&
              widget.serverState.terminalsOnline.contains(terminalId),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.person_add_alt_1),
              ),
              Text('Назначить пользователя'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setUserExit',
          enabled: widget.serverState.terminalsOnline.contains(terminalId),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.person_off),
              ),
              Text('Выход'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setScreenOn',
          enabled: widget.serverState.terminalsOnline.contains(terminalId),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.tv),
              ),
              Text('Включить экран'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setScreenOff',
          enabled: widget.serverState.terminalsOnline.contains(terminalId),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(CupertinoIcons.tv_fill),
              ),
              Text('Погасить экран'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setReset',
          enabled: widget.serverState.terminalsOnline.contains(terminalId),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.refresh),
              ),
              Text('Перезагрузить'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setShutdown',
          enabled: widget.serverState.terminalsOnline.contains(terminalId),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.power_off),
              ),
              Text('Выключить'),
            ],
          ),
        ),
        PopupMenuItem(
          enabled: false,
          value: 'setShutdownAll',
          child: Divider(
            color: Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'setShutdownAll',
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.video_call),
              ),
              Expanded(
                child: Text(
                  'Перезапустить стрим на всех терминалах',
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setResetAll',
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.refresh),
              ),
              Expanded(
                child: Text(
                  'Перезагрузить все терминалы',
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'setShutdownAll',
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.power_off),
              ),
              Text('Выключить все терминалы'),
            ],
          ),
        ),
      ],
    );
  }

  Widget getTribuneScheme() {
    if (!_isShowTribune) {
      return Container();
    }

    if (widget.group == null) {
      return Container();
    }

    List<Widget> tribuneCells = <Widget>[];

    tribuneCells.add(Expanded(child: Container()));

    for (int i = 0;
        i < widget.group.workplaces.tribuneTerminalIds.length;
        i++) {
      tribuneCells.add(createTribuneCell(
          widget.group.workplaces.tribuneNames[i],
          widget.group.workplaces.tribuneTerminalIds[i]));
    }

    tribuneCells.insert(tribuneCells.length, Expanded(child: Container()));

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width -
            widget.settings.storeboardSettings.width -
            20,
        margin: EdgeInsets.all(widget.isOperatorView
            ? widget.settings.operatorSchemeSettings.cellInnerPadding.toDouble()
            : widget.settings.managerSchemeSettings.cellInnerPadding
                .toDouble()),
        alignment: Alignment.bottomCenter,
        child: Row(
          children: tribuneCells,
        ),
      ),
    );
  }

  Widget createTribuneCell(String tribuneName, String terminalIds) {
    List<Widget> terminalButtons = <Widget>[];

    bool isTribuneMicrophoneEnabled = widget.serverState.activeMics.entries
        .any((element) => element.key == terminalIds);

    bool isTribuneStoreboardEnabled =
        widget.serverState.speakerSession?.terminalId == terminalIds;

    var setSpeakerTooltip =
        isTribuneMicrophoneEnabled ? 'Убрать выступление' : 'Выступление';

    terminalButtons.add(Expanded(
      child: Container(),
    ));

    Color tribuneMicColor = Colors.white;

    if (isTribuneMicrophoneEnabled) {
      tribuneMicColor = Colors.red;
    }

    var iconSize = widget.isOperatorView
        ? widget.settings.operatorSchemeSettings.iconSize.toDouble()
        : widget.settings.managerSchemeSettings.iconSize.toDouble();

    var displayButton = SizedBox(
        height: iconSize,
        width: iconSize * 3,
        child: Tooltip(
          message: 'Назначить выступление',
          child: TextButton(
            style: ButtonStyle(
              padding:
                  MaterialStateProperty.all(EdgeInsets.fromLTRB(0, 0, 0, 0)),
            ),
            child: Icon(
              Icons.monitor,
              size: iconSize - 2,
              color: isTribuneStoreboardEnabled ? Colors.green : Colors.red,
            ),
            onPressed: () {
              widget.setTribuneSpeaker(terminalIds, null);
            },
          ),
        ));

    if (_isControlSound) {
      if (widget.isOperatorView || isTribuneMicrophoneEnabled) {
        terminalButtons.add(SizedBox(
            height: iconSize,
            width: iconSize * 3,
            child: Tooltip(
              message: setSpeakerTooltip,
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.fromLTRB(0, 0, 0, 0)),
                  side: widget.interval == null
                      ? null
                      : MaterialStateProperty.all(BorderSide(width: 1)),
                ),
                child: Icon(
                  Icons.mic,
                  size: iconSize,
                  color: tribuneMicColor,
                ),
                onPressed: () {
                  setState(() {
                    widget.setSpeaker(terminalIds, !isTribuneMicrophoneEnabled);
                  });
                },
              ),
            )));

        terminalButtons.add(Expanded(
          flex: 5,
          child: Container(),
        ));

        terminalButtons.add(displayButton);

        terminalButtons.add(Expanded(
          child: Container(),
        ));

        return Container(
          padding: EdgeInsets.all(widget.isOperatorView
              ? widget
                  .settings.operatorSchemeSettings.cellOuterPaddingHorisontal
                  .toDouble()
              : widget.settings.managerSchemeSettings.cellOuterPaddingHorisontal
                  .toDouble()),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            border: Border.all(
              color: Color(widget.settings.palletteSettings.cellBorderColor),
              width: widget.isOperatorView
                  ? widget.settings.operatorSchemeSettings.cellBorder.toDouble()
                  : widget.settings.managerSchemeSettings.cellBorder.toDouble(),
            ),
          ),
          width: widget.isOperatorView
              ? widget.settings.operatorSchemeSettings.cellTribuneWidth
                  .toDouble()
              : widget.settings.managerSchemeSettings.cellTribuneWidth
                  .toDouble(),
          child: Column(
            children: [
              Container(
                child: Text(
                  tribuneName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                child: Row(
                  children: terminalButtons,
                ),
              ),
            ],
          ),
        );
      }
    }

    return Container(
      padding: EdgeInsets.all(widget.isOperatorView
          ? widget.settings.operatorSchemeSettings.cellOuterPaddingHorisontal
              .toDouble()
          : widget.settings.managerSchemeSettings.cellOuterPaddingHorisontal
              .toDouble()),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        border: Border.all(
          color: Color(widget.settings.palletteSettings.cellBorderColor),
          width: widget.isOperatorView
              ? widget.settings.operatorSchemeSettings.cellBorder.toDouble()
              : widget.settings.managerSchemeSettings.cellBorder.toDouble(),
        ),
      ),
      width: widget.isOperatorView
          ? widget.settings.operatorSchemeSettings.cellTribuneWidth.toDouble()
          : widget.settings.managerSchemeSettings.cellTribuneWidth.toDouble(),
      child: Row(
        children: [
          Expanded(
            child: Container(),
          ),
          Container(
            child: Text(
              tribuneName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Container(
            child: displayButton,
          ),
        ],
      ),
    );
  }
}