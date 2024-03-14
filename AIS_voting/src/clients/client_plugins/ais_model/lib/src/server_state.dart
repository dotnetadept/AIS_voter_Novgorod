import 'dart:convert';
import 'package:ais_model/src/guest_place.dart';
import 'package:ais_model/src/signal.dart';
import 'package:ais_model/src/registration_session.dart';
import 'package:ais_model/src/question_session.dart';
import 'package:ais_model/src/askwordqueue_session.dart';
import 'package:ais_model/src/speaker_session.dart';

import 'system_state.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'storeboard_template.dart';
import 'voting_history.dart';

class ServerState {
  //storeboard and deputy
  SystemState systemState;
  String params;

  StoreboardState storeboardState;
  String storeboardParams;
  bool isDetailsStoreboard;

  int registrationResult;
  int votingResultYes;
  int votingResultNo;
  int votingResultIndiffirent;
  int votingTotalVotes;
  RegistrationSession registrationSession;
  QuestionSession questionSession;
  AskWordQueueSession askWordQueueSession;
  SpeakerSession speakerSession;
  Signal startSignal;
  Signal endSignal;

  VotingHistory votingHistory;
  bool isRegistrationCompleted;

  bool isStreamStarted;
  String streamUrl;
  String streamControl;
  bool showToManager;
  bool showAskWordButton;

  //operator and manager
  Map<String, int> formattedDevicesOnline;
  Map<String, String> versions;

  Map<String, int> usersTerminals;
  List<String> terminalsOnline;
  List<String> terminalsWithDocuments;
  List<String> terminalsLoadingDocuments = <String>[];
  Map<String, String> terminalsDocumentErrors = <String, String>{};

  List<int> usersRegistered;
  List<int> usersAskSpeech;
  List<int> usersOnSpeech;

  List<String> guestsAskSpeech;
  List<GuestPlace> guestsPlaces;

  Map<String, String> usersDecisions;

  Map<String, String> activeMics;

  String playSound;
  double soundVolume;
  String playSoundTimestamp;

  DateTime timestamp;

  ServerState();

  ServerState.fromJson(Map<String, dynamic> json)
      //storeboard and deputy
      : systemState =
            EnumToString.fromString(SystemState.values, json['systemState']),
        params = json['params'],
        storeboardState = EnumToString.fromString(
            StoreboardState.values, json['storeboardState']),
        storeboardParams = json['storeboardParams'],
        isDetailsStoreboard = json['isDetailsStoreboard'],
        registrationResult = json['registrationResult'],
        votingTotalVotes = json['votingTotalVotes'],
        votingResultIndiffirent = json['votingResultIndiffirent'],
        votingResultNo = json['votingResultNo'],
        votingResultYes = json['votingResultYes'],
        registrationSession = json['registrationSession'] == null
            ? null
            : RegistrationSession.fromJson(json['registrationSession']),
        questionSession = json['questionSession'] == null
            ? null
            : QuestionSession.fromJson(json['questionSession']),
        askWordQueueSession = json['askWordQueueSession'] == null
            ? null
            : AskWordQueueSession.fromJson(json['askWordQueueSession']),
        speakerSession = json['speakerSession'] == null
            ? null
            : SpeakerSession.fromJson(json['speakerSession']),
        startSignal = json['startSignal'] == null
            ? null
            : Signal.fromJson(json['startSignal']),
        endSignal = json['endSignal'] == null
            ? null
            : Signal.fromJson(json['endSignal']),
        votingHistory =
            json['votingHistory'] == null || json['votingHistory'] == 'null'
                ? null
                : VotingHistory.fromJson(jsonDecode(json['votingHistory'])),
        isRegistrationCompleted = json['isRegistrationCompleted'],
        // operator and manager
        formattedDevicesOnline = json['formattedDevicesOnline'] == null
            ? <String, int>{}
            : jsonDecode(json['formattedDevicesOnline']).cast<String, int>(),
        versions = json['versions'] == null
            ? <String, String>{}
            : jsonDecode(json['versions']).cast<String, String>(),
        terminalsOnline = json['terminalsOnline'] == null
            ? <String>[]
            : json['terminalsOnline'].toList().cast<String>(),
        terminalsWithDocuments = json['terminalsWithDocuments'] == null
            ? <String>[]
            : json['terminalsWithDocuments'].toList().cast<String>(),
        terminalsLoadingDocuments = json['terminalsLoadingDocuments'] == null
            ? <String>[]
            : json['terminalsLoadingDocuments'].toList().cast<String>(),
        terminalsDocumentErrors = json['terminalsDocumentErrors'] == null
            ? <String, String>{}
            : jsonDecode(json['terminalsDocumentErrors'])
                .cast<String, String>(),
        usersRegistered = json['usersRegistered'] == null
            ? <int>[]
            : json['usersRegistered'].toList().cast<int>(),
        usersAskSpeech = json['usersAskSpeech'] == null
            ? <int>[]
            : json['usersAskSpeech'].toList().cast<int>(),
        usersOnSpeech = json['usersOnSpeech'] == null
            ? <int>[]
            : json['usersOnSpeech'].toList().cast<int>(),
        guestsAskSpeech = json['guestsAskSpeech'] == null
            ? <String>[]
            : json['guestsAskSpeech'].toList().cast<String>(),
        guestsPlaces = json['guestsPlaces'] == null
            ? <GuestPlace>[]
            : ((json['guestsPlaces']) as List)
                .map((data) => GuestPlace.fromJson(data))
                .toList(),
        usersDecisions = json['usersDecisions'] == null
            ? <String, String>{}
            : jsonDecode(json['usersDecisions']).cast<String, String>(),
        usersTerminals = json['usersTerminals'] == null
            ? <String, int>{}
            : jsonDecode(json['usersTerminals']).cast<String, int>(),
        activeMics = json['activeMics'] == null
            ? <String, String>{}
            : jsonDecode(json['activeMics']).cast<String, String>(),
        timestamp = DateTime.now(),
        isStreamStarted = json['isStreamStarted'],
        streamUrl = json['streamUrl'],
        streamControl = json['streamControl'],
        showToManager = json['showToManager'],
        showAskWordButton = json['showAskWordButton'],
        playSound = json['playSound'],
        soundVolume = json['soundVolume'],
        playSoundTimestamp = json['playSoundTimestamp'];
}
