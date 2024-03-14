import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:storeboard/State/AppState.dart';
import 'package:ais_utils/ais_utils.dart';

class StoreboardPage extends StatefulWidget {
  StoreboardPage({Key key}) : super(key: key);

  @override
  _StoreboardPageState createState() => _StoreboardPageState();
}

class _StoreboardPageState extends State<StoreboardPage> {
  @override
  void initState() {
    super.initState();
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
}
