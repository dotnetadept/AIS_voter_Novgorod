import 'dart:convert' show json;
import 'package:ais_model/ais_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:global_configuration/global_configuration.dart';
import '../Widgets/voting_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../State/AppState.dart';

class VotingPage extends StatefulWidget {
  VotingPage({Key? key}) : super(key: key);

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  late Question _question;
  var _autoSizeGroup = AutoSizeGroup();

  bool _isBigButtons = false;
  late int _defaultButtonsHeight;
  late int _defaultButtonsWidth;

  @override
  void initState() {
    super.initState();

    _isBigButtons =
        GlobalConfiguration().getValue('voting_view_use_flex_buttons') ==
            'true';
    _defaultButtonsHeight =
        int.parse(GlobalConfiguration().getValue('default_buttons_height'));
    _defaultButtonsWidth =
        int.parse(GlobalConfiguration().getValue('default_buttons_width'));

    var selectedQuestionId =
        json.decode(AppState().getServerState().params)['selectedQuestion'];
    _question = AppState()
        .getCurrentMeeting()!
        .agenda!
        .questions
        .firstWhere((element) => element.id == selectedQuestionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget body() {
    if (_isBigButtons) {
      return getBigButtonsView();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: leftPanel(),
        ),
        Container(
          width: AppState().getSettings().storeboardSettings.width.toDouble(),
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget getBigButtonsView() {
    Provider.of<AppState>(context, listen: true);
    var storeboardWidth =
        ((2 * MediaQuery.of(context).size.width - 40) / 3).round();
    var storeboardHeight =
        ((2 * MediaQuery.of(context).size.height - 40) / 3).round();

    var scaleFactor = storeboardWidth /
                AppState().getSettings().storeboardSettings.width <
            storeboardHeight /
                AppState().getSettings().storeboardSettings.height
        ? storeboardWidth / AppState().getSettings().storeboardSettings.width
        : storeboardHeight / AppState().getSettings().storeboardSettings.height;

    var storeboardBottomOffset =
        ((scaleFactor * AppState().getSettings().storeboardSettings.height) -
                    AppState().getSettings().storeboardSettings.height) /
                2 +
            25;

    var emblemHeight = MediaQuery.of(context).size.height -
        AppState().getSettings().storeboardSettings.height * scaleFactor -
        25;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          width: 20,
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      AppState().getCurrentUser()!.secondName,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      AppState().getCurrentUser()!.firstName +
                                          ' ' +
                                          AppState().getCurrentUser()!.lastName,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: emblemHeight, minHeight: emblemHeight),
                    child: VotingUtils().getEmblemButton(),
                  ),
                ],
              ),
              Expanded(
                child: Container(),
              ),
              Transform.scale(
                scale: scaleFactor,
                child: StoreboardWidget(
                  serverState: AppState().getServerState(),
                  meeting: AppState().getCurrentMeeting()!,
                  question: _question,
                  settings: AppState().getSettings(),
                  timeOffset: AppState().getTimeOffset(),
                  votingModes: AppState().getVotingModes(),
                  users: AppState().getUsers(),
                ),
              ),
              Container(
                height: storeboardBottomOffset,
              )
            ],
          ),
        ),
        Container(
          width: 20,
        ),
        AppState().getServerState().systemState != SystemState.QuestionVoting
            ? Expanded(
                child: Container(),
              )
            : Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: VotingUtils().getVotingButton(
                          'ЗА',
                          AppState()
                              .getSettings()
                              .palletteSettings
                              .voteYesColor,
                          _isBigButtons,
                          _defaultButtonsHeight,
                          _defaultButtonsWidth,
                          context,
                          setState,
                          _autoSizeGroup),
                    ),
                    Expanded(
                      child: VotingUtils().getVotingButton(
                          'ПРОТИВ',
                          AppState().getSettings().palletteSettings.voteNoColor,
                          _isBigButtons,
                          _defaultButtonsHeight,
                          _defaultButtonsWidth,
                          context,
                          setState,
                          _autoSizeGroup),
                    ),
                    Expanded(
                      child: VotingUtils().getVotingButton(
                          'ВОЗДЕРЖАЛСЯ',
                          AppState()
                              .getSettings()
                              .palletteSettings
                              .voteIndifferentColor,
                          _isBigButtons,
                          _defaultButtonsHeight,
                          _defaultButtonsWidth,
                          context,
                          setState,
                          _autoSizeGroup),
                    ),
                    // Expanded(
                    //   child: VotingUtils().getVotingButton(
                    //       'СБРОС',
                    //       AppState().getSettings().palletteSettings.voteResetColor,
                    //       _isBigButtons,
                    //       _defaultButtonsHeight,
                    //       _defaultButtonsWidth,
                    //       context,
                    //       setState,
                    //       _autoSizeGroup),
                    // ),
                  ],
                ),
              ),
        Container(
          width: 20,
        ),
      ],
    );
  }

  Widget leftPanel() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Image(image: AssetImage('assets/images/emblem.png')),
    );
  }

  Widget rightPanel() {
    Provider.of<AppState>(context, listen: true);
    return Container(
      color: Colors.blue[100],
      child:
          AppState().getServerState().systemState != SystemState.QuestionVoting
              ? Expanded(
                  child: Container(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    VotingUtils().getVotingButton(
                        'ЗА',
                        AppState().getSettings().palletteSettings.voteYesColor,
                        _isBigButtons,
                        _defaultButtonsHeight,
                        _defaultButtonsWidth,
                        context,
                        setState,
                        _autoSizeGroup),
                    VotingUtils().getVotingButton(
                        'ПРОТИВ',
                        AppState().getSettings().palletteSettings.voteNoColor,
                        _isBigButtons,
                        _defaultButtonsHeight,
                        _defaultButtonsWidth,
                        context,
                        setState,
                        _autoSizeGroup),
                    VotingUtils().getVotingButton(
                        'ВОЗДЕРЖАЛСЯ',
                        AppState()
                            .getSettings()
                            .palletteSettings
                            .voteIndifferentColor,
                        _isBigButtons,
                        _defaultButtonsHeight,
                        _defaultButtonsWidth,
                        context,
                        setState,
                        _autoSizeGroup),
                    // VotingUtils().getVotingButton(
                    //     'СБРОС',
                    //     AppState().getSettings().palletteSettings.voteResetColor,
                    //     _isBigButtons,
                    //     _defaultButtonsHeight,
                    //     _defaultButtonsWidth,
                    //     context,
                    //     setState,
                    //     _autoSizeGroup),
                    Expanded(
                      child: Container(),
                    ),
                    StoreboardWidget(
                      serverState: AppState().getServerState(),
                      meeting: AppState().getCurrentMeeting()!,
                      question: _question,
                      settings: AppState().getSettings(),
                      timeOffset: AppState().getTimeOffset(),
                      votingModes: AppState().getVotingModes(),
                      users: AppState().getUsers(),
                    ),
                  ],
                ),
    );
  }
}
