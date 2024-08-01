import 'package:ais_model/ais_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deputy/State/AppState.dart';
import 'package:deputy/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';

class VotingUtils {
  Widget getEmblemButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Image(image: AssetImage('assets/images/emblem.png')),
    );
  }

  Widget getVotingButton(
      String buttonName,
      int color,
      bool isBigButtonsView,
      int defaultButtonsHeight,
      int defaultButtonsWidth,
      BuildContext context,
      Function setState,
      AutoSizeGroup group) {
    return Container(
      padding: isBigButtonsView
          ? EdgeInsets.fromLTRB(20, 20, 20, 20)
          : EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppState().getDecision() == buttonName
                ? Colors.white
                : Colors.transparent,
            width: 5,
          ),
        ),
        child: GestureDetector(
          onPanDown: (DragDownDetails d) {
            Provider.of<WebSocketConnection>(context, listen: false)
                .sendMessage(buttonName);
            setState(() {});
          },
          child: TextButton(
            style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0))),
                backgroundColor: WidgetStateProperty.all(
                  Color(color),
                ),
                overlayColor:
                    WidgetStateProperty.all(Colors.white.withAlpha(30))),
            onPressed: () => null,
            child: Container(
              width: isBigButtonsView ? null : defaultButtonsWidth.toDouble(),
              height: isBigButtonsView ? null : defaultButtonsHeight.toDouble(),
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: AutoSizeText(
                        buttonName,
                        maxLines: 1,
                        group: group,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: AppState().getDecision() == buttonName,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Container(
                      padding: isBigButtonsView
                          ? EdgeInsets.fromLTRB(0, 30, 0, 30)
                          : EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: LayoutBuilder(
                        builder: (context, constraint) {
                          return Icon(Icons.done,
                              size: constraint.biggest.height);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAskWordButton(
    BuildContext context,
    Function setState,
    AutoSizeGroup group,
    int defaultButtonsHeight,
    int defaultButtonsWidth,
    bool isHorisontalWiev,
  ) {
    var connection = Provider.of<WebSocketConnection>(context, listen: true);

    var isEnabled = AppState().getSettings().deputySettings.useTempAskWordQueue
        ? AppState().getServerState().systemState == SystemState.AskWordQueue
        : true;

    if (!isEnabled) {
      return Container();
    }

    int indexOfCurrentUser = AppState()
        .getServerState()
        .usersAskSpeech
        .indexOf(AppState().getCurrentUser()?.id ?? -1);

    var queueOrder = (indexOfCurrentUser == -1 ? 0 : indexOfCurrentUser) + 1;

    var micIsOn = AppState()
            .getServerState()
            .activeMics[GlobalConfiguration().getValue('terminal_id')] !=
        null;

    if (isHorisontalWiev) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        width: 600,
        child: micIsOn
            ? Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            'ГОВОРИТЕ',
                            maxLines: 1,
                            group: AutoSizeGroup(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 50,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.mic,
                          color: Colors.red,
                          size: defaultButtonsHeight.toDouble(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.transparent,
                        width: 5,
                      ),
                    ),
                    child: GestureDetector(
                      onPanDown: !isEnabled
                          ? null
                          : (DragDownDetails d) {
                              Provider.of<WebSocketConnection>(context,
                                      listen: false)
                                  .setSpeaker(
                                      GlobalConfiguration()
                                          .getValue('terminal_id'),
                                      false);
                              setState(() {});
                            },
                      child: TextButton(
                        style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
                            backgroundColor: WidgetStateProperty.all(
                              AppState().getAskWordStatus()
                                  ? Color(AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .askWordColor)
                                  : Colors.blue,
                            ),
                            overlayColor: WidgetStateProperty.all(
                                Colors.white.withAlpha(30))),
                        onPressed: () => null,
                        child: Container(
                          width: defaultButtonsWidth.toDouble(),
                          height: defaultButtonsHeight.toDouble(),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: AutoSizeText(
                                    'ЗАКОНЧИТЬ ВЫСТУПЛЕНИЕ',
                                    maxLines: 1,
                                    group: group,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 300,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  AppState().getAskWordStatus()
                      ? Expanded(
                          child: AutoSizeText(
                            'ВЫ ЗАПИСАНЫ - $queueOrder',
                            maxLines: 1,
                            group: AutoSizeGroup(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 50,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(),
                        ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppState().getAskWordStatus()
                            ? Colors.white
                            : Colors.transparent,
                        width: 5,
                      ),
                    ),
                    child: GestureDetector(
                      onPanDown: !isEnabled
                          ? null
                          : (DragDownDetails d) {
                              if (AppState().getAskWordStatus()) {
                                connection.sendMessage('ПРОШУ СЛОВА СБРОС');
                              } else {
                                connection.sendMessage('ПРОШУ СЛОВА');
                              }
                              setState(() {});
                            },
                      child: TextButton(
                        style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
                            backgroundColor: WidgetStateProperty.all(
                              AppState().getAskWordStatus()
                                  ? Color(AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .askWordColor)
                                  : Colors.blue,
                            ),
                            overlayColor: WidgetStateProperty.all(
                                Colors.white.withAlpha(30))),
                        onPressed: () => null,
                        child: Container(
                          width: defaultButtonsWidth.toDouble(),
                          height: defaultButtonsHeight.toDouble(),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: AutoSizeText(
                                    AppState().getAskWordStatus()
                                        ? 'ОТМЕНИТЬ ЗАПИСЬ'
                                        : 'ЗАПИСАТЬСЯ НА ВЫСТУПЛЕНИЕ',
                                    maxLines: 1,
                                    group: group,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 300,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: micIsOn
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        'ГОВОРИТЕ',
                        maxLines: 1,
                        group: AutoSizeGroup(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 200,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: defaultButtonsHeight * 0.80,
                    ),
                  ],
                ),
                GestureDetector(
                  onPanDown: !isEnabled
                      ? null
                      : (DragDownDetails d) {
                          Provider.of<WebSocketConnection>(context,
                                  listen: false)
                              .setSpeaker(
                                  GlobalConfiguration().getValue('terminal_id'),
                                  false);
                          setState(() {});
                        },
                  child: TextButton(
                    style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0))),
                        backgroundColor: WidgetStateProperty.all(
                          AppState().getAskWordStatus()
                              ? Color(AppState()
                                  .getSettings()
                                  .palletteSettings
                                  .askWordColor)
                              : Colors.blue,
                        ),
                        overlayColor: WidgetStateProperty.all(
                            Colors.white.withAlpha(30))),
                    onPressed: () => null,
                    child: Container(
                      width: defaultButtonsWidth.toDouble(),
                      height: defaultButtonsHeight.toDouble(),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: AutoSizeText(
                                'ЗАКОНЧИТЬ ВЫСТУПЛЕНИЕ',
                                maxLines: 1,
                                group: group,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                AppState().getAskWordStatus()
                    ? Container(
                        height: defaultButtonsHeight * 0.5,
                        child: AutoSizeText(
                          'ВЫ ЗАПИСАНЫ - $queueOrder',
                          maxLines: 1,
                          group: AutoSizeGroup(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 300,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        height: defaultButtonsHeight * 0.5.toDouble(),
                      ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppState().getAskWordStatus()
                          ? Colors.white
                          : Colors.transparent,
                      width: 5,
                    ),
                  ),
                  child: GestureDetector(
                    onPanDown: !isEnabled
                        ? null
                        : (DragDownDetails d) {
                            if (AppState().getAskWordStatus()) {
                              connection.sendMessage('ПРОШУ СЛОВА СБРОС');
                            } else {
                              connection.sendMessage('ПРОШУ СЛОВА');
                            }
                            setState(() {});
                          },
                    child: TextButton(
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0))),
                          backgroundColor: WidgetStateProperty.all(
                            AppState().getAskWordStatus()
                                ? Color(AppState()
                                    .getSettings()
                                    .palletteSettings
                                    .askWordColor)
                                : Colors.blue,
                          ),
                          overlayColor: WidgetStateProperty.all(
                              Colors.white.withAlpha(30))),
                      onPressed: () => null,
                      child: Container(
                        width: defaultButtonsWidth.toDouble(),
                        height: defaultButtonsHeight.toDouble(),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: AutoSizeText(
                                  AppState().getAskWordStatus()
                                      ? 'ОТМЕНИТЬ ЗАПИСЬ'
                                      : 'ЗАПИСАТЬСЯ НА ВЫСТУПЛЕНИЕ',
                                  maxLines: 1,
                                  group: group,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 300,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget getExpandedButton(
    BuildContext context,
    String name,
    Function onClick,
    AutoSizeGroup group,
    int defaultButtonsHeight,
  ) {
    return Container(
      child: Container(
        child: GestureDetector(
          onPanDown: (DragDownDetails d) {
            onClick();
          },
          child: TextButton(
            style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0))),
                backgroundColor: WidgetStateProperty.all(
                  Colors.blue,
                ),
                overlayColor:
                    WidgetStateProperty.all(Colors.white.withAlpha(30))),
            onPressed: () => null,
            child: Container(
              height: defaultButtonsHeight.toDouble(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: AutoSizeText(
                        name,
                        maxLines: 1,
                        group: group,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
