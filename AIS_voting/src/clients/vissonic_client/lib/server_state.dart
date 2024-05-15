import 'dart:convert';
import 'vissonic_client/terminal_mic.dart';

class ServerState {
  static bool isVissonicServerOnline = false;
  static bool isVissonicModuleInit = false;
  static bool? micsEnabled;
  static List<TerminalMic> currentMics = <TerminalMic>[];

  Map toJson() => {
        'isVissonicServerOnline': isVissonicServerOnline,
        'isVissonicModuleInit': isVissonicModuleInit,
        'micsEnabled': micsEnabled,
        'activeMics': jsonEncode(Map.fromEntries(currentMics
            .where((element) => element.getIsSound())
            .map((e) => MapEntry(e.micId.toString(), e.startTime)))),
        'waitingMics': currentMics
            .where((element) => element.getIsWaiting())
            .map((e) => e.micId)
            .toList(),
      };

  static void micsFromJson(List<dynamic> json) {
    currentMics = json.isEmpty
        ? <TerminalMic>[]
        : json.map<TerminalMic>((q) => TerminalMic.fromJson(q)).toList();
  }
}
