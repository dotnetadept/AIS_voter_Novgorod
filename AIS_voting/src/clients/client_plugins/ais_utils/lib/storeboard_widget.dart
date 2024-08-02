import 'dart:async';
import 'package:ais_utils/ais_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'dart:convert' show json;
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class StoreboardWidget extends StatefulWidget {
  StoreboardWidget({
    Key? key,
    required this.serverState,
    required this.meeting,
    this.question,
    required this.settings,
    this.isStoreBoardClient = false,
    this.screenScale = 1.0,
    required this.timeOffset,
    required this.votingModes,
    required this.users,
  }) : super(key: key);

  final ServerState serverState;
  final Meeting meeting;
  final Question? question;
  final Settings settings;
  final bool isStoreBoardClient;
  final int timeOffset;
  final double screenScale;
  final List<VotingMode> votingModes;
  final List<User> users;

  static late bool Function(Signal signal) onIntervalEndingSignal;

  @override
  _StoreboardStateWidgetState createState() => _StoreboardStateWidgetState();
}

class _StoreboardStateWidgetState extends State<StoreboardWidget>
    with TickerProviderStateMixin {
  late Timer _clockTimer;
  String _clockText = '';

  late Timer _intervalTimer;
  int _intervalIndicatorValue = 0;
  int _intervalValue = 0;
  late Timer _resultsTimer;
  late TabController _resultsTabController;
  late TabController _askWordQueueTabController;
  int _maxDetailsPagesCount = 0;
  bool _intervalEndWasPlayed = false;

  late SpeakerSession _prevSpeakerSession;
  late SystemState _previousState;

  @override
  void initState() {
    super.initState();

    _resultsTimer = Timer.periodic(
        Duration(
            seconds: widget.settings.storeboardSettings
                .detailsAnimationDuration), (v) async {
      var nextIndexResults =
          (_resultsTabController.index + 1) >= _resultsTabController.length
              ? 0
              : _resultsTabController.index + 1;
      _resultsTabController.animateTo(nextIndexResults);

      var nextIndexAskWordQueue = (_askWordQueueTabController.index + 1) >=
              _askWordQueueTabController.length
          ? 0
          : _askWordQueueTabController.index + 1;
      _askWordQueueTabController.animateTo(nextIndexAskWordQueue);
    });

    _clockText = DateFormat('dd.MM.yyyy HH:mm:ss')
        .format(TimeUtil.getDateTimeNow(widget.timeOffset));

    _clockTimer = Timer.periodic(Duration(seconds: 1), (v) {
      setState(() {
        _clockText = DateFormat('dd.MM.yyyy HH:mm:ss')
            .format(TimeUtil.getDateTimeNow(widget.timeOffset));
      });
    });
  }

  void initControllers() {
    if (widget.serverState.votingHistory != null) {
      _maxDetailsPagesCount =
          (widget.serverState.votingHistory!.usersDecisions.length /
                  widget.settings.storeboardSettings.detailsRowsCount)
              .ceil();
    } else if (widget.meeting != null) {
      _maxDetailsPagesCount = (widget.meeting.group!.getVoters().length /
              widget.settings.storeboardSettings.detailsRowsCount)
          .ceil();
    }

    if (_resultsTabController?.length != _maxDetailsPagesCount) {
      _resultsTabController = TabController(
        vsync: this,
        length: _maxDetailsPagesCount,
        initialIndex: 0,
      );
    }

    int pagesCount = (widget.serverState.askWordQueueSession?.users?.length ??
            0 / widget.settings.storeboardSettings.detailsRowsCount)
        .ceil();
    pagesCount = pagesCount == 0 ? 1 : pagesCount;

    if (_askWordQueueTabController?.length != pagesCount) {
      _askWordQueueTabController = TabController(
        vsync: this,
        length: pagesCount,
        initialIndex: 0,
      );
    }
  }

  double getScaledSize(double size) {
    return (size / widget.screenScale).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    initControllers();

    if (_previousState != widget.serverState.systemState ||
        json.encode(_prevSpeakerSession?.toJson()) !=
            json.encode(widget.serverState.speakerSession?.toJson())) {
      _prevSpeakerSession = widget.serverState.speakerSession!;
      _intervalEndWasPlayed = false;

      _intervalTimer?.cancel();

      DateTime startTime;
      if (widget.serverState.storeboardState == StoreboardState.Speaker) {
        startTime = widget.serverState.speakerSession!.startDate!;
        _intervalValue = widget.serverState.speakerSession!.interval;

        updateIndicatorInterval(startTime, _intervalValue);
        _intervalTimer = Timer.periodic(Duration(seconds: 1),
            (Timer t) => updateIndicatorInterval(startTime, _intervalValue));
      }

      if (widget.serverState.systemState == SystemState.Registration) {
        startTime = DateTime.parse(
            json.decode(widget.serverState.params)['lastUpdated']);
        _intervalValue = widget.serverState.registrationSession!.interval;

        updateIndicatorInterval(startTime, _intervalValue);
        _intervalTimer = Timer.periodic(Duration(seconds: 1),
            (Timer t) => updateIndicatorInterval(startTime, _intervalValue));
      }

      if (widget.serverState.systemState == SystemState.QuestionVoting) {
        startTime = DateTime.parse(
            json.decode(widget.serverState.params)['lastUpdated']);
        _intervalValue = widget.serverState.questionSession!.interval;

        updateIndicatorInterval(startTime, _intervalValue);
        _intervalTimer = Timer.periodic(Duration(seconds: 1),
            (Timer t) => updateIndicatorInterval(startTime, _intervalValue));
      }

      if (widget.serverState.systemState == SystemState.AskWordQueue) {
        startTime = DateTime.parse(
            json.decode(widget.serverState.params)['lastUpdated']);
        _intervalValue = widget.serverState.askWordQueueSession!.interval;

        updateIndicatorInterval(startTime, _intervalValue);
        _intervalTimer = Timer.periodic(Duration(seconds: 1),
            (Timer t) => updateIndicatorInterval(startTime, _intervalValue));
      }

      _previousState = widget.serverState.systemState!;
    }

    return DefaultTextStyle(
        style: TextStyle(fontSize: 11),
        child:
            Align(alignment: Alignment.bottomCenter, child: getStoreBoard()));
  }

  Widget getStoreBoard() {
    return Stack(children: [
      widget.isStoreBoardClient
          ? Container(
              alignment: Alignment.center,
              color: Color(widget.settings.storeboardSettings.backgroundColor),
              child: Container(
                width: widget.settings.storeboardSettings.width.toDouble(),
                height: widget.settings.storeboardSettings.height.toDouble(),
                padding: EdgeInsets.fromLTRB(
                    widget.settings.storeboardSettings.paddingLeft.toDouble(),
                    widget.settings.storeboardSettings.paddingTop.toDouble(),
                    widget.settings.storeboardSettings.paddingRight.toDouble(),
                    widget.settings.storeboardSettings.paddingBottom
                        .toDouble()),
                margin: EdgeInsets.all(0),
                child: getStoreBoardContent(),
              ),
            )
          : Container(
              alignment: Alignment.center,
              color: Color(widget.settings.storeboardSettings.backgroundColor),
              width: widget.settings.storeboardSettings.width.toDouble(),
              height: widget.settings.storeboardSettings.height.toDouble(),
              child: Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.fromLTRB(
                    widget.settings.storeboardSettings.paddingLeft.toDouble(),
                    widget.settings.storeboardSettings.paddingTop.toDouble(),
                    widget.settings.storeboardSettings.paddingRight.toDouble(),
                    widget.settings.storeboardSettings.paddingBottom
                        .toDouble()),
                child: getStoreBoardContent(),
              ),
            ),
    ]);
  }

  Widget getStoreBoardContent() {
    if (widget.serverState.storeboardState == StoreboardState.CustomText) {
      return getCustomStoreBoard();
    }
    if (widget.serverState.storeboardState == StoreboardState.Template) {
      return getTemplateStoreboard(StoreboardTemplate.fromJson(
          json.decode(widget.serverState.storeboardParams ?? '')));
    }
    if (widget.serverState.votingHistory != null) {
      if (widget.serverState.votingHistory?.isDetailsStoreboard == true) {
        return getVotingDetailsResultStoreBoard(
            widget.serverState.votingHistory!);
      } else {
        return getVotingResultStoreBoard(widget.serverState.votingHistory!);
      }
    }
    if (widget.meeting == null) {
      return getEmptyStoreBoard();
    }

    if (widget.serverState.systemState == SystemState.Registration) {
      return getRegistrationStoreBoard();
    }
    if (widget.serverState.systemState == SystemState.QuestionVoting) {
      return getVotingStoreBoard();
    }
    if (widget.serverState.systemState == SystemState.AskWordQueue) {
      return getAskWordQueueStoreBoard();
    }

    if (widget.serverState.storeboardState == StoreboardState.Break) {
      return getMeetingBreakStoreboard();
    }
    if (widget.serverState.storeboardState == StoreboardState.Speaker) {
      return getSpeakerStoreBoard();
    }
    if (widget.serverState.storeboardState == StoreboardState.Started) {
      return getMeetingStartStoreboard();
    }
    if (widget.serverState.storeboardState == StoreboardState.Completed) {
      return getMeetingCompletedStoreboard();
    }

    if (widget.serverState.systemState == SystemState.RegistrationComplete) {
      return getMeetingStartStoreboard();
      //return getRegistrationResultStoreBoard();
    }
    if (widget.serverState.systemState == SystemState.QuestionVotingComplete) {
      bool isQuorumSuccess =
          widget.serverState.questionSession!.usersCountRegistred >=
              widget.meeting.group!.quorumCount;

      bool isVotingSuccess = false;
      bool isManagerDecides = false;

      if (widget.serverState.questionSession!.usersCountVotedYes >=
          widget.serverState.questionSession!.usersCountForSuccess) {
        isVotingSuccess = true;

        // check is manager vote was casting vote
        if (widget.meeting.group!.isManagerCastingVote &&
            (DecisionModeHelper.getEnumValue(
                    widget.serverState.questionSession!.decision) ==
                DecisionMode.MajorityOfRegistredMembers) &&
            (widget.serverState.questionSession!.usersCountVotedYes ==
                widget.serverState.questionSession!.usersCountVotedNo) &&
            (widget.serverState.questionSession!.usersCountVotedYes ==
                widget.serverState.questionSession!.usersCountForSuccess)) {
          var currentManagerId = GroupUtil().getManagerId(
              widget.meeting.group!, widget.serverState.usersTerminals);
          var managerDecision =
              widget.serverState.usersDecisions.entries.firstWhereOrNull(
            (element) => element.key == currentManagerId?.toString(),
          );

          if (managerDecision != null && managerDecision.value == 'ПРОТИВ') {
            isVotingSuccess = false;
            isManagerDecides = true;
          }
          if (managerDecision != null && managerDecision.value == 'ЗА') {
            isVotingSuccess = true;
            isManagerDecides = true;
          }
        }
      }

      int totalVotes = widget.serverState.votingTotalVotes;
      int yesVotes = widget.serverState.votingResultYes;
      int noVotes = widget.serverState.votingResultNo;
      int indifferentVotes = widget.serverState.votingResultIndiffirent;
      int usersCountForSuccess =
          widget.serverState.questionSession!.usersCountForSuccess;
      int usersCountForSuccessDisplay =
          widget.serverState.questionSession!.usersCountForSuccessDisplay;

      var voters = widget.meeting.group!
          .getVoters()
          .map<User>((row) => row.user)
          .toList(growable: false);

      Map<String, String> decisions = <String, String>{};

      for (int i = 0; i < voters.length; i++) {
        decisions.putIfAbsent(
            voters[i].getShortName(),
            () =>
                widget.serverState.usersDecisions[voters[i].id.toString()] ??
                widget.settings.storeboardSettings.noDataText);
      }

      VotingHistory votingHistory = VotingHistory(
          getQuestionName(),
          isQuorumSuccess,
          isVotingSuccess,
          isManagerDecides,
          totalVotes,
          yesVotes,
          noVotes,
          indifferentVotes,
          usersCountForSuccess,
          usersCountForSuccessDisplay,
          widget.serverState.isDetailsStoreboard,
          decisions);

      if (widget.serverState.isDetailsStoreboard) {
        return getVotingDetailsResultStoreBoard(votingHistory);
      } else {
        return getVotingResultStoreBoard(votingHistory);
      }
    }
    if (widget.serverState.systemState == SystemState.AskWordQueueCompleted) {
      return getAskWordQueueCompletedStoreBoard(
          widget.serverState.askWordQueueSession!);
    }
    if (widget.serverState.systemState == SystemState.QuestionLocked) {
      return getQuestionDescriptionStoreBoard();
    }
    if (widget.serverState.systemState == SystemState.MeetingStarted ||
        widget.serverState.systemState == SystemState.MeetingPreparation) {
      return getMeetingStoreboard();
    }

    return getEmptyStoreBoard();
  }

  void updateIndicatorInterval(DateTime startTime, int time) {
    var secondsElapsed =
        ((TimeUtil.getDateTimeNow(widget.timeOffset).millisecondsSinceEpoch -
                    startTime.millisecondsSinceEpoch) /
                1000)
            .round();

    int maxValue = time == null ? 0 : time;
    setState(() {
      _intervalIndicatorValue =
          maxValue - secondsElapsed < 0 ? 0 : maxValue - secondsElapsed;

      if (StoreboardWidget.onIntervalEndingSignal != null &&
          !_intervalEndWasPlayed &&
          _intervalIndicatorValue == 0 &&
          widget.serverState.storeboardState == StoreboardState.Speaker) {
        _intervalEndWasPlayed = StoreboardWidget.onIntervalEndingSignal(
            widget.serverState.endSignal!);
      }
    });
  }

  Widget getTemplateStoreboard(StoreboardTemplate template) {
    List<Widget> items = <Widget>[];

    for (int i = 0; i < template.items.length; i++) {
      var align = TextAlign.center;
      if (template.items[i].align == 'По левому краю') {
        align = TextAlign.left;
      }
      if (template.items[i].align == 'По правому краю') {
        align = TextAlign.right;
      }

      var fontWeight = FontWeight.w400;
      if (template.items[i].weight == 'Жирный') {
        fontWeight = FontWeight.w500;
      }

      items.add(Row(children: [
        Expanded(
          child: Text(
            template.items[i].text,
            overflow: TextOverflow.ellipsis,
            maxLines: 100,
            softWrap: true,
            textAlign: align,
            style: TextStyle(
              fontSize: template.items[i].fontSize.toDouble(),
              fontWeight: fontWeight,
              color: Color(widget.settings.storeboardSettings.textColor),
            ),
          ),
        ),
      ]));
    }

    items.insert(0, getTopRow());

    return Column(
      children: items,
    );
  }

  Widget getEmptyStoreBoard() {
    return Column(
      children: [
        getMeetingTopRow(),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getCustomStoreBoard() {
    var caption = json.decode(widget.serverState.storeboardParams!)['caption'];
    var text = json.decode(widget.serverState.storeboardParams!)['text'];
    return Column(
      children: [
        getTopRow(),
        Expanded(child: Container()),
        (caption == null || caption.isEmpty)
            ? Container()
            : Padding(
                padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 1),
                child: Text(
                  caption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.customCaptionFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
        (text == null || text.isEmpty)
            ? Container()
            : Padding(
                padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 1),
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 9,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.customTextFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
        Expanded(child: Container()),
      ],
    );
  }

  Color getIndicatorColor() {
    Color indicatorColor = Colors.blue;
    if (widget.serverState.startSignal != null &&
        _intervalValue - _intervalIndicatorValue <=
            widget.serverState.startSignal!.duration) {
      indicatorColor = Color(widget.serverState.startSignal!.color);
    } else if (widget.serverState.endSignal != null &&
        _intervalIndicatorValue <= widget.serverState.endSignal!.duration) {
      indicatorColor = Color(widget.serverState.endSignal!.color);
    }

    return indicatorColor;
  }

  Widget getSpeakerStoreBoard() {
    String speakerSurname =
        widget.serverState.speakerSession!.name.trim().split(' ').first;
    String speakerNameAndLastName = widget.serverState.speakerSession!.name
        .replaceFirst(speakerSurname, '')
        .trim();

    return Column(
      children: [
        getTopRow(),
        Expanded(child: Container()),
        Padding(
          padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 1),
          child: Column(
            children: [
              widget.serverState.speakerSession!.type == 'ФИО:'
                  ? Container()
                  : getStoreBoardLine(
                      widget.serverState.speakerSession!.type, 24),
              getStoreBoardLine(speakerSurname, 24),
              getStoreBoardLine(speakerNameAndLastName, 24),
              _intervalValue == 0
                  ? Container()
                  : Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            backgroundColor:
                                getIndicatorColor().withOpacity(0.45),
                            color: getIndicatorColor(),
                            value: (_intervalValue - _intervalIndicatorValue) /
                                _intervalValue,
                            minHeight: getScaledSize(10),
                          ),
                        ),
                      ],
                    ),
              _intervalValue == 0 ? Container() : getSpeakerTimeInterval(),
            ],
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  AutoSizeGroup group = AutoSizeGroup();

  Widget getRegistrationStoreBoard() {
    if (widget.isStoreBoardClient) {
      var timeParts = _clockText.split(' ');
      bool totalResult = widget.serverState.usersRegistered.length >=
          widget.meeting.group!.quorumCount;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    timeParts[0],
                    style: TextStyle(
                        fontSize: getScaledSize(14),
                        color: Color(
                            widget.settings.storeboardSettings.textColor)),
                  ),
                ),
              ),
              Text(
                'РЕГИСТРАЦИЯ',
                style: TextStyle(
                    fontSize: getScaledSize(18),
                    color: Color(widget.settings.storeboardSettings.textColor)),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    timeParts[1],
                    style: TextStyle(
                        fontSize: getScaledSize(14),
                        color: Color(
                            widget.settings.storeboardSettings.textColor)),
                  ),
                ),
              ),
            ],
          ),
          Container(height: getScaledSize(5)),
          Expanded(child: getGroupScheme()),
          Container(height: getScaledSize(5)),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                width: getScaledSize(60),
                height: getScaledSize(7),
                color: totalResult ? Colors.green : Colors.red,
              ),
              Container(
                width: getScaledSize(5),
              ),
              Text(
                totalResult ? 'КВОРУМ ЕСТЬ' : 'КВОРУМА НЕТ',
              ),
              Container(
                width: getScaledSize(2),
              ),
              Container(
                width: getScaledSize(60),
                height: getScaledSize(7),
                color: totalResult ? Colors.green : Colors.red,
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Container(height: getScaledSize(5)),
        ],
      );
    }

    return Column(
      children: [
        getTopRow(),
        Expanded(child: Container()),
        Text(
          'РЕГИСТРАЦИЯ',
          style: TextStyle(
            fontSize: getScaledSize(20),
            fontWeight: FontWeight.w500,
            color: Color(widget.settings.storeboardSettings.textColor),
          ),
        ),
        Expanded(child: Container()),
        Text(
          'ЗАРЕГИСТРИРОВАЛОСЬ',
          style: TextStyle(
            fontSize: getScaledSize(30),
            fontWeight: FontWeight.w500,
            color: Color(widget.settings.storeboardSettings.textColor),
          ),
        ),
        Expanded(child: Container()),
        Text(
          widget.serverState.usersRegistered.length.toString(),
          style: TextStyle(
            fontSize: getScaledSize(30),
            fontWeight: FontWeight.w500,
            color: Color(widget.settings.storeboardSettings.textColor),
          ),
        ),
        Expanded(child: Container()),
        _intervalValue == 0
            ? Container()
            : Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      backgroundColor: getIndicatorColor().withOpacity(0.45),
                      color: getIndicatorColor(),
                      value: (_intervalValue - _intervalIndicatorValue) /
                          _intervalValue,
                      minHeight: getScaledSize(10),
                    ),
                  ),
                  Text(
                    '  ${(_intervalIndicatorValue).toString()} c',
                    style: TextStyle(
                      color:
                          Color(widget.settings.storeboardSettings.textColor),
                    ),
                  )
                ],
              ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getGroupScheme() {
    var columns = <Widget>[];

    var userCounter = 0;

    var columnsCount = (widget.meeting.group!.groupUsers.length /
            widget.settings.storeboardSettings.detailsRowsCount)
        .ceil();

    var users = widget.users
        .where((u) =>
            widget.meeting.group!.groupUsers.any((gu) => gu.user.id == u.id))
        .toList();

    for (int i = 0; i < columnsCount; i++) {
      var userWidgets = <Widget>[];

      for (int j = 0;
          j < widget.settings.storeboardSettings.detailsRowsCount;
          j++) {
        var user = userCounter >= users.length ? null : users[userCounter];

        userWidgets.add(getUserRegistrationCell(user));
        userWidgets.add(Container(height: 4));
        userCounter++;
      }

      var column = Expanded(
        child: Column(
          children: userWidgets,
        ),
      );
      columns.add(column);
      columns.add(Container(width: 10));
    }

    return Row(
      children: columns,
    );
  }

  AutoSizeGroup _autoSizeGroup = new AutoSizeGroup();
  AutoSizeGroup _autoSizeGroupRegistred = new AutoSizeGroup();

  Widget getUserRegistrationCell(User? user) {
    var isRegistred = widget.serverState.usersRegistered.contains(user?.id);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(widget.settings.storeboardSettings.backgroundColor),
              width: isRegistred ? 2 : 0,
            ),
            bottom: BorderSide(
              color: Color(widget.settings.storeboardSettings.backgroundColor),
              width: isRegistred ? 2 : 0,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Color(0xAA2a2a2a),
              ],
              tileMode: TileMode.mirror,
            ),
          ),
          child: Row(children: [
            Container(
              width: getScaledSize(1),
            ),
            user == null
                ? Container()
                : Icon(Icons.circle,
                    size: getScaledSize(8),
                    color: widget.serverState.usersRegistered.contains(user?.id)
                        ? Colors.green
                        : Colors.red),
            Container(
              width: getScaledSize(1),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                  isRegistred ? 1 : 0,
                ),
                child: AutoSizeText(
                  user == null ? '' : user.getShortName(),
                  maxLines: 1,
                  minFontSize: 1,
                  stepGranularity: 0.1,
                  softWrap: true,
                  group: isRegistred ? _autoSizeGroupRegistred : _autoSizeGroup,
                  style: TextStyle(
                    color: Color(isRegistred
                        ? Colors.white24.value
                        : widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget getRegistrationResultStoreBoard() {
    bool totalResult = widget.serverState.registrationResult >=
        widget.meeting.group!.quorumCount;

    return Column(
      children: [
        getTopRow(),
        Expanded(child: Container()),
        Text(
          'РЕГИСТРАЦИЯ',
          style: TextStyle(
            fontSize: getScaledSize(20),
            fontWeight: FontWeight.w500,
            color: Color(widget.settings.storeboardSettings.textColor),
          ),
        ),
        Expanded(child: Container()),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ВСЕГО ДЕПУТАТОВ',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(5),
                ),
                Text(
                  'ПРИСУТСТВУЕТ',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(5),
                ),
                Text(
                  'ОТСУТСТВУЕТ',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(5),
                ),
                Text(
                  'КВОРУМ',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.meeting.group!.lawUsersCount}',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(5),
                ),
                Text(
                  '${widget.serverState.registrationResult}',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(5),
                ),
                Text(
                  '${widget.meeting.group!.lawUsersCount - widget.serverState.registrationResult}',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(5),
                ),
                Text(
                  '${widget.meeting.group!.quorumCount}',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ],
            )
          ],
        ),
        Expanded(child: Container()),
        Padding(
          padding: EdgeInsets.fromLTRB(0, getScaledSize(10), 0, 0),
          child: Text(
            totalResult ? 'КВОРУМ ЕСТЬ' : 'КВОРУМА НЕТ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.settings.storeboardSettings.resultTotalFontSize
                  .toDouble(),
              fontWeight: FontWeight.w500,
              color: Color(widget.settings.storeboardSettings.textColor),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getVotingStoreBoard() {
    String timeLasts = (_intervalIndicatorValue ~/ 60) > 0
        ? 'осталось ${_intervalIndicatorValue ~/ 60} мин. ${_intervalIndicatorValue % 60} сек.'
        : 'осталось ${_intervalIndicatorValue % 60} сек.';
    var votingModeId = widget.serverState.questionSession!.votingModeId;
    var selectedVotingMode =
        widget.votingModes.firstWhere((i) => i.id == votingModeId);
    return Column(
      children: [
        getTopRow(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 0),
                child: AutoSizeText(
                  getQuestionName(),
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: getScaledSize(22),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 0),
                child: AutoSizeText(
                  selectedVotingMode.name,
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: getScaledSize(28),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
              widget.question!.name ==
                      widget.settings.questionListSettings.firstQuestion
                          .defaultGroupName
                  ? Container()
                  : Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(
                            0, getScaledSize(5), 0, getScaledSize(1)),
                        child: AgendaUtil.getQuestionDescriptionText(
                            widget.question!,
                            widget.settings.storeboardSettings
                                .questionDescriptionFontSize
                                .toDouble(),
                            isAutoSize: true,
                            textColor: Color(
                                widget.settings.storeboardSettings.textColor),
                            textAlign: widget.settings.storeboardSettings
                                    .justifyQuestionDescription
                                ? TextAlign.justify
                                : TextAlign.left),
                      ),
                    ),
            ],
          ),
        ),
        Column(
          children: [
            _intervalValue == 0
                ? Container()
                : Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          backgroundColor:
                              getIndicatorColor().withOpacity(0.45),
                          color: getIndicatorColor(),
                          value: (_intervalValue - _intervalIndicatorValue) /
                              _intervalValue,
                          minHeight: getScaledSize(10),
                        ),
                      ),
                      Text(
                        '  ${(_intervalIndicatorValue).toString()} c',
                        style: TextStyle(
                          color: Color(
                              widget.settings.storeboardSettings.textColor),
                        ),
                      )
                    ],
                  ),
            Text(
              'ИДЕТ ГОЛОСОВАНИЕ',
              style: TextStyle(
                fontSize: widget.settings.storeboardSettings.resultTotalFontSize
                    .toDouble(),
                fontWeight: FontWeight.w500,
                color: Color(widget.settings.storeboardSettings.textColor),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget getVotingResultStoreBoard(VotingHistory votingHistory) {
    var indifferentCount = votingHistory.indifferentVotes;

    var noVotedCount = votingHistory.usersDecisions.values
        .where((element) => element == 'н/д')
        .length;

    if (widget.settings.votingSettings.isCountNotVotingAsIndifferent) {
      indifferentCount += noVotedCount;
    }

    return Column(
      children: [
        getTopRow(),
        Expanded(
          child: Container(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 0),
          child: AutoSizeText(
            votingHistory.questionName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
            style: TextStyle(
              fontSize: getScaledSize(22),
              fontWeight: FontWeight.w500,
              color: Color(widget.settings.storeboardSettings.textColor),
            ),
          ),
        ),
        Expanded(
          child: Container(),
        ),
        // Padding(
        //   padding:
        //       EdgeInsets.fromLTRB(getScaledSize(20), 0, getScaledSize(20), 0),
        //   child: AutoSizeText(
        //     'ДЛЯ ПРИНЯТИЯ РЕШЕНИЯ НЕОБХОДИМО ${votingHistory.usersCountForSuccessDisplay}',
        //     overflow: TextOverflow.ellipsis,
        //     maxLines: 1,
        //     softWrap: true,
        //     style: TextStyle(
        //       fontSize: 100,
        //       fontWeight: FontWeight.w500,
        //       color: Color(widget.settings.storeboardSettings.textColor),
        //     ),
        //   ),
        // ),
        Expanded(
          child: Container(),
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ЗА',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(2),
                ),
                Text(
                  'ПРОТИВ',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(2),
                ),
                Text(
                  'ВОЗДЕРЖАЛИСЬ',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                widget.settings.votingSettings.isCountNotVotingAsIndifferent
                    ? Container()
                    : Container(
                        height: getScaledSize(2),
                      ),
                // widget.settings.votingSettings.isCountNotVotingAsIndifferent
                //     ? Container()
                //     : Text(
                //         'НЕ ГОЛОСОВАЛО',
                //         style: TextStyle(
                //           fontSize: widget
                //               .settings.storeboardSettings.resultItemsFontSize
                //               .toDouble(),
                //           fontWeight: FontWeight.w500,
                //           color: Color(
                //               widget.settings.storeboardSettings.textColor),
                //         ),
                //       ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${votingHistory.yesVotes}',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(2),
                ),
                Text(
                  '${votingHistory.noVotes}',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                Container(
                  height: getScaledSize(2),
                ),
                Text(
                  '$indifferentCount',
                  style: TextStyle(
                    fontSize: widget
                        .settings.storeboardSettings.resultItemsFontSize
                        .toDouble(),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
                // widget.settings.votingSettings.isCountNotVotingAsIndifferent
                //     ? Container()
                //     : Container(
                //         height: getScaledSize(2),
                //       ),
                // widget.settings.votingSettings.isCountNotVotingAsIndifferent
                //     ? Container()
                //     : Text(
                //         '$noVotedCount',
                //         style: TextStyle(
                //           fontSize: widget
                //               .settings.storeboardSettings.resultItemsFontSize
                //               .toDouble(),
                //           fontWeight: FontWeight.w500,
                //           color: Color(
                //               widget.settings.storeboardSettings.textColor),
                //         ),
                //       ),
              ],
            )
          ],
        ),
        Expanded(child: Container()),
        Text(
          votingHistory.isVotingSuccess
              ? 'РЕШЕНИЕ ПРИНЯТО'
              : 'РЕШЕНИЕ НЕ ПРИНЯТО',
          style: TextStyle(
            fontSize: widget.settings.storeboardSettings.resultTotalFontSize
                .toDouble(),
            fontWeight: FontWeight.w500,
            color: votingHistory.isManagerDecides
                ? Colors.white
                : votingHistory.isVotingSuccess
                    ? Color(widget
                        .settings.storeboardSettings.decisionAcceptedColor)
                    : Color(widget
                        .settings.storeboardSettings.decisionDeclinedColor),
          ),
        )
      ],
    );
  }

  Widget getVotingDetailsResultStoreBoard(VotingHistory votingHistory) {
    List<Widget> votersList = <Widget>[];

    for (var decision in votingHistory.usersDecisions.entries) {
      votersList.add(getStoreBoardResultLine(decision.key, decision.value,
          widget.settings.storeboardSettings.resultItemsFontSize.toDouble()));
    }

    int rowsPerPage = widget.settings.storeboardSettings.detailsRowsCount;
    int pagesCount = (votersList.length / rowsPerPage).ceil();

    List<Column> tabColumns = <Column>[];

    for (int i = 0; i < pagesCount; i++) {
      tabColumns.add(Column(
        children: votersList
            .getRange(
                i * rowsPerPage,
                (i * rowsPerPage + rowsPerPage) > votersList.length
                    ? votersList.length
                    : (i * rowsPerPage + rowsPerPage))
            .toList(),
      ));
    }

    return Column(
      children: [
        getTopRow(),
        Container(
          height: getScaledSize(10),
        ),
        widget.serverState.votingHistory == null
            ? Padding(
                padding: EdgeInsets.all(0),
                child: AutoSizeText(
                  getQuestionName(),
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: getScaledSize(22),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(0),
                child: AutoSizeText(
                  votingHistory.questionName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: getScaledSize(22),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
        Container(
          height: getScaledSize(10),
        ),
        Expanded(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: null,
            body: TabBarView(
              controller: _resultsTabController,
              children: tabColumns,
            ),
          ),
        ),
      ],
    );
  }

  Widget getAskWordQueueStoreBoard() {
    return Column(
      children: [
        getTopRow(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 0),
                child: AutoSizeText(
                  getQuestionName(),
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: getScaledSize(22),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 0),
                child: AutoSizeText(
                  'ЗАПИСАТЬСЯ',
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: getScaledSize(28),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
              widget.question!.name ==
                      widget.settings.questionListSettings.firstQuestion
                          .defaultGroupName
                  ? Container()
                  : Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(
                            0, getScaledSize(5), 0, getScaledSize(1)),
                        child: AgendaUtil.getQuestionDescriptionText(
                            widget.question!,
                            widget.settings.storeboardSettings
                                .questionDescriptionFontSize
                                .toDouble(),
                            isAutoSize: true,
                            textColor: Color(
                                widget.settings.storeboardSettings.textColor),
                            textAlign: widget.settings.storeboardSettings
                                    .justifyQuestionDescription
                                ? TextAlign.justify
                                : TextAlign.left),
                      ),
                    ),
            ],
          ),
        ),
        Column(
          children: [
            _intervalValue == 0
                ? Container()
                : Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          backgroundColor:
                              getIndicatorColor().withOpacity(0.45),
                          color: getIndicatorColor(),
                          value: (_intervalValue - _intervalIndicatorValue) /
                              _intervalValue,
                          minHeight: getScaledSize(10),
                        ),
                      ),
                      Text(
                        '  ${(_intervalIndicatorValue).toString()} c',
                        style: TextStyle(
                          color: Color(
                              widget.settings.storeboardSettings.textColor),
                        ),
                      )
                    ],
                  ),
            Text(
              'ИДЕТ ЗАПИСЬ НА ВЫСТУПЛЕНИЕ',
              style: TextStyle(
                fontSize: widget.settings.storeboardSettings.resultTotalFontSize
                    .toDouble(),
                fontWeight: FontWeight.w500,
                color: Color(widget.settings.storeboardSettings.textColor),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget getAskWordQueueCompletedStoreBoard(AskWordQueueSession session) {
    List<Widget> askWordList = <Widget>[];

    for (var userId in session.users) {
      var user =
          widget.users.firstWhereOrNull((element) => element.id == userId);

      if (user != null) {
        askWordList.add(getStoreBoardResultLine(
            user.getFullName(),
            (session.users.indexOf(userId) + 1).toString(),
            widget.settings.storeboardSettings.resultItemsFontSize.toDouble()));
      }
    }

    int rowsPerPage = widget.settings.storeboardSettings.detailsRowsCount;
    int pagesCount = (askWordList.length / rowsPerPage).ceil();
    pagesCount = pagesCount == 0 ? 1 : pagesCount;

    List<Column> tabColumns = <Column>[];

    for (int i = 0; i < pagesCount; i++) {
      tabColumns.add(Column(
        children: askWordList
            .getRange(
                i * rowsPerPage,
                (i * rowsPerPage + rowsPerPage) > askWordList.length
                    ? askWordList.length
                    : (i * rowsPerPage + rowsPerPage))
            .toList(),
      ));
    }

    return Column(
      children: [
        getTopRow(),
        Container(
          height: getScaledSize(10),
        ),
        Padding(
          padding: EdgeInsets.all(0),
          child: AutoSizeText(
            getQuestionName(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
            style: TextStyle(
              fontSize: getScaledSize(22),
              fontWeight: FontWeight.w500,
              color: Color(widget.settings.storeboardSettings.textColor),
            ),
          ),
        ),
        Container(
          height: getScaledSize(10),
        ),
        Expanded(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: null,
            body: TabBarView(
              controller: _askWordQueueTabController,
              children: tabColumns,
            ),
          ),
        ),
      ],
    );
  }

  Widget getQuestionDescriptionStoreBoard() {
    return Column(
      children: [
        getTopRow(),
        Expanded(
          child: Column(
            mainAxisAlignment: widget.question!.name ==
                    widget.settings.questionListSettings.firstQuestion
                        .defaultGroupName
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, getScaledSize(20), 0, 0),
                child: AutoSizeText(
                  getQuestionName(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: getScaledSize(22),
                    fontWeight: FontWeight.w500,
                    color: Color(widget.settings.storeboardSettings.textColor),
                  ),
                ),
              ),
              widget.question!.name ==
                      widget.settings.questionListSettings.firstQuestion
                          .defaultGroupName
                  ? Container()
                  : Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0, getScaledSize(5), 0, 0),
                        child: AgendaUtil.getQuestionDescriptionText(
                            widget.question!,
                            widget.settings.storeboardSettings
                                .questionDescriptionFontSize
                                .toDouble(),
                            isAutoSize: true,
                            textColor: Color(
                                widget.settings.storeboardSettings.textColor),
                            textAlign: widget.settings.storeboardSettings
                                    .justifyQuestionDescription
                                ? TextAlign.justify
                                : TextAlign.left),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  String getQuestionName() {
    if (widget.question!.name ==
        widget.settings.questionListSettings.firstQuestion.defaultGroupName) {
      return widget.settings.questionListSettings.firstQuestion.storeboardStub;
    }
    return widget.question.toString();
  }

  Widget getMeetingStoreboard() {
    return Column(
      children: [
        getMeetingTopRow(),
        Expanded(child: Container()),
        Text(
          widget.meeting.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getScaledSize(28),
            fontWeight: FontWeight.w500,
            color: Color(widget.settings.storeboardSettings.textColor),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getMeetingBreakStoreboard() {
    return Column(
      children: [
        getTopRow(),
        Expanded(child: Container()),
        Text(
          'ПЕРЕРЫВ ДО ${DateFormat("HH:mm").format(DateTime.parse(json.decode(widget.serverState.storeboardParams!)['break']))}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getScaledSize(30),
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: Color(widget.settings.storeboardSettings.textColor),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getMeetingStartStoreboard() {
    return Column(
      children: [
        getMeetingTopRow(),
        Expanded(child: Container()),
        Padding(
          padding:
              EdgeInsets.fromLTRB(getScaledSize(20), 0, getScaledSize(20), 0),
          child: AutoSizeText(
            '${widget.meeting.name.toUpperCase()}',
            textAlign: TextAlign.center,
            stepGranularity: 0.1,
            minFontSize: 1,
            softWrap: true,
            maxLines: 3,
            style: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.w500,
              color: Color(widget.settings.storeboardSettings.textColor),
            ),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.fromLTRB(getScaledSize(100), 0, getScaledSize(100), 0),
          child: AutoSizeText(
            '${'ОТКРЫТО'}',
            textAlign: TextAlign.center,
            stepGranularity: 0.1,
            minFontSize: 1,
            softWrap: true,
            maxLines: 1,
            style: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.w500,
              color: Color(widget.settings.storeboardSettings.textColor),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getMeetingCompletedStoreboard() {
    return Column(
      children: [
        getMeetingTopRow(),
        Expanded(child: Container()),
        Padding(
          padding:
              EdgeInsets.fromLTRB(getScaledSize(45), 0, getScaledSize(45), 0),
          child: AutoSizeText(
            'ПРИСУТСТВУЕТ ${widget.serverState.usersRegistered.length}',
            stepGranularity: 0.1,
            minFontSize: 1,
            softWrap: true,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: Color(widget.settings.storeboardSettings.textColor),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getStoreBoardLine(String text, double fontSize) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      softWrap: true,
      style: TextStyle(
        fontSize: getScaledSize(fontSize),
        fontWeight: FontWeight.w500,
        color: Color(widget.settings.storeboardSettings.textColor),
      ),
    );
  }

  Widget getStoreBoardResultLine(
      String caption, String value, double fontSize) {
    return Row(
      children: [
        Text(
          caption,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Color(widget.settings.storeboardSettings.textColor),
          ),
        ),
        Expanded(child: Container()),
        Text(
          value,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Color(widget.settings.storeboardSettings.textColor)),
        ),
      ],
    );
  }

  Widget getTopRow() {
    var timeParts = _clockText.split(' ');

    return Row(
      children: [
        Expanded(
          child: widget.meeting == null
              ? Container()
              : Text(
                  widget.meeting.name,
                  style: TextStyle(
                      fontSize: getScaledSize(14),
                      color:
                          Color(widget.settings.storeboardSettings.textColor)),
                ),
        ),
        Text(
          timeParts[1],
          style: TextStyle(
              fontSize: getScaledSize(14),
              color: Color(widget.settings.storeboardSettings.textColor)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              timeParts[0],
              style: TextStyle(
                  fontSize: getScaledSize(14),
                  color: Color(widget.settings.storeboardSettings.textColor)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getMeetingTopRow() {
    var timeParts = _clockText.split(' ');

    return Row(
      children: [
        Expanded(
          child: Container(),
        ),
        Text(
          timeParts[1],
          style: TextStyle(
              fontSize: getScaledSize(14),
              color: Color(widget.settings.storeboardSettings.textColor)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              timeParts[0],
              style: TextStyle(
                  fontSize: getScaledSize(14),
                  color: Color(widget.settings.storeboardSettings.textColor)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getSpeakerTimeInterval() {
    return Text(
      (_intervalIndicatorValue ~/ 60) > 0
          ? 'Время: ${_intervalIndicatorValue ~/ 60} мин. ${_intervalIndicatorValue % 60} сек.'
          : 'Время: ${_intervalIndicatorValue % 60} сек.',
      style: TextStyle(
          fontSize:
              widget.settings.storeboardSettings.timersFontSize.toDouble(),
          fontWeight: FontWeight.w500,
          color: Color(widget.settings.storeboardSettings.textColor)),
    );
  }

  @override
  dispose() {
    _resultsTabController.dispose();
    _askWordQueueTabController.dispose();

    _clockTimer.cancel();
    _intervalTimer?.cancel();
    _resultsTimer?.cancel();
    super.dispose();
  }
}
