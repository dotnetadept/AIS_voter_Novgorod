import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../State/AppState.dart';

class TableUtils {
  Widget getUnregistredTable(ScrollController controller, {int flex = 1}) {
    List<User> users = UsersFilterUtil.getUnregisterUserList(
        AppState().getUsers(),
        AppState().getCurrentMeeting()!.group!,
        AppState().getServerState());

    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Container(
            color: Colors.lightBlue,
            height: 45,
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: [
                Container(width: 5),
                Expanded(
                  child: Text(
                    'ОТСУТСТВУЮТ ${users.length}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: 5,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1,
                        ),
                        color:
                            Color.fromRGBO(255, 255, 255, 1).withOpacity(0.5),
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
                                  padding: EdgeInsets.all(0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person),
                                      Text(
                                        users[index].getShortName(),
                                        style: TextStyle(fontSize: 16),
                                      ),
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
          ),
        ],
      ),
    );
  }

  AutoSizeGroup _micsEnabled = AutoSizeGroup();

  Widget getMicsEnabledTable(
      ScrollController controller, Function(String) setSpeaker) {
    Map<String, String> mics = getMicEnabledList();

    return Expanded(
      flex: 10,
      child: Container(
        child: Column(
          children: [
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
                        var startDate = DateTime.parse(AppState()
                                .getServerState()
                                .activeMics
                                .entries
                                .firstWhereOrNull((element) =>
                                    element.key == mics.keys.elementAt(index))
                                ?.value ??
                            '');

                        var activeTime =
                            TimeUtil.getDateTimeNow(AppState().getTimeOffset())
                                .difference(startDate);
                        String twoDigits(int n) => n.toString().padLeft(2, "0");
                        String activeTimeMinutes =
                            twoDigits(activeTime.inMinutes.remainder(60));
                        String activeTimeSeconds =
                            twoDigits(activeTime.inSeconds.remainder(60));

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
                                Expanded(
                                  child: AutoSizeText(
                                    mics.values.elementAt(index),
                                    maxLines: 1,
                                    group: _micsEnabled,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                    "${activeTimeMinutes}:${activeTimeSeconds}"),
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

  Map<String, String> getMicEnabledList() {
    Map<String, String> usersMicEnabled = Map<String, String>();

    for (int micIndex = 0;
        micIndex < AppState().getServerState().activeMics.length;
        micIndex++) {
      var currentMic =
          AppState().getServerState().activeMics.entries.elementAt(micIndex);

      var userId = AppState().getServerState().usersTerminals[currentMic.key];
      var tribuneIndex = AppState()
          .getCurrentMeeting()!
          .group!
          .workplaces
          .tribuneTerminalIds
          .indexOf(currentMic.key);
      var guestPlace = AppState()
          .getServerState()
          .guestsPlaces
          .firstWhereOrNull((element) => element.terminalId == currentMic.key);

      if (userId != null) {
        usersMicEnabled.putIfAbsent(
          currentMic.key,
          () => AppState()
              .getUsers()
              .firstWhere((element) => element.id == userId)
              .getShortName(),
        );
      } else if (tribuneIndex != -1) {
        usersMicEnabled.putIfAbsent(
          currentMic.key,
          () => AppState()
              .getCurrentMeeting()!
              .group!
              .workplaces
              .tribuneNames[tribuneIndex],
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
}
