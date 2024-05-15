import 'package:ais_model/ais_model.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:storeboard/State/AppState.dart';
import 'package:ais_utils/ais_utils.dart';

import '../State/SoundPlayer.dart';
import '../State/WebSocketConnection.dart';

class StoreboardPage extends StatefulWidget {
  StoreboardPage({Key key}) : super(key: key);

  @override
  _StoreboardPageState createState() => _StoreboardPageState();
}

class _StoreboardPageState extends State<StoreboardPage> {
  @override
  void initState() {
    super.initState();
    WebSocketConnection.updateServerState = setServerState;
    StoreboardWidget.onIntervalEndingSignal = SoundPlayer.playEndingSignal;
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context, listen: true);

    if (AppState().getServerState() == null || !AppState().getIsOnline()) {
      return getLoadingStub('Подключение');
    }

    if (!AppState().getIsLoadingComplete()) {
      return getLoadingStub('Загрузка');
    }

    // calculate scale factor
    // as min of screen.width / settings.width  and screen.height / settings.height
    double scaleFactor = 1.0;
    var settings = AppState().getSettings().storeboardSettings;
    var screen = Size(
        int.parse(GlobalConfiguration().getValue('width')).toDouble(),
        int.parse(GlobalConfiguration().getValue('height'))
            .toDouble()); // MediaQuery.of(context).size;
    scaleFactor =
        screen.width / settings.width < screen.height / settings.height
            ? screen.width / settings.width
            : screen.height / settings.height;

    return Scaffold(
        backgroundColor:
            Color(AppState().getSettings().storeboardSettings.backgroundColor),
        body: Transform.scale(
            scale: scaleFactor,
            child: Align(
                alignment: Alignment.topCenter,
                child: StoreboardWidget(
                  serverState: AppState().getServerState(),
                  settings: AppState().getSettings(),
                  meeting: AppState().getCurrentMeeting(),
                  question: AppState().getCurrentQuestion(),
                  isStoreBoardClient: true,
                  timeOffset: AppState().getTimeOffset(),
                  votingModes: AppState().getVotingModes(),
                  users: AppState().getUsers(),
                ))));
  }

  Widget getLoadingStub(String caption) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container()),
          Row(
            children: [
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(
                  caption,
                  style: TextStyle(
                    fontSize: 40.0,
                  ),
                ),
              ),
              Container(
                child: CircularProgressIndicator(),
              ),
              Expanded(child: Container()),
            ],
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  static SystemState _prevSystemState;
  static String _prevPlaySoundTimestamp;

  void setServerState(ServerState serverState) {
    SoundPlayer.setVolume(serverState.soundVolume);

    if (serverState != null &&
        (serverState.systemState == SystemState.Registration ||
            serverState.systemState == SystemState.QuestionVoting ||
            serverState.systemState == SystemState.AskWordQueue) &&
        _prevSystemState != serverState.systemState) {
      SoundPlayer.playSignal(serverState.startSignal);
    } else if (serverState != null &&
        (serverState.systemState == SystemState.QuestionVotingComplete ||
            serverState.systemState == SystemState.RegistrationComplete ||
            serverState.systemState == SystemState.AskWordQueueCompleted) &&
        _prevSystemState != serverState.systemState) {
      SoundPlayer.playSignal(serverState.endSignal);
    }

    if (serverState.playSoundTimestamp != _prevPlaySoundTimestamp) {
      if (serverState.playSound == 'hymn_start') {
        SoundPlayer.playSoundByType('hymn_start');
      } else if (serverState.playSound == 'hymn_end') {
        SoundPlayer.playSoundByType('hymn_end');
      } else if (serverState.playSound == 'cancel') {
        SoundPlayer.cancelSound();
      } else if (serverState.playSound != '') {
        SoundPlayer.playSoundByPath(serverState.playSound);
      }
    }

    _prevSystemState = serverState.systemState;
    _prevPlaySoundTimestamp = serverState.playSoundTimestamp;
  }
}
