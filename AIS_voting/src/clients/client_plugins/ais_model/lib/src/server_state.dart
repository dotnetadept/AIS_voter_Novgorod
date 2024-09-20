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
  late SystemState? systemState;
  late String params;

  late StoreboardState? storeboardState;
  late String? storeboardParams;
  late bool isDetailsStoreboard;

  late int registrationResult = 0;
  late int votingResultYes = 0;
  late int votingResultNo = 0;
  late int votingResultIndiffirent = 0;
  late int votingTotalVotes = 0;
  late RegistrationSession? registrationSession;
  late QuestionSession? questionSession;
  late AskWordQueueSession? askWordQueueSession;
  late SpeakerSession? speakerSession;
  late Signal? startSignal;
  late Signal? endSignal;

  late VotingHistory? votingHistory;
  late bool isRegistrationCompleted;

  late bool isStreamStarted;
  late String? streamUrl;
  late String? streamControl;
  late bool? showToManager;
  late bool? showAskWordButton;

  //operator and manager
  late Map<String, int> formattedDevicesOnline;
  late Map<String, String> versions;

  late Map<String, int> usersTerminals;
  late List<String> terminalsOnline;
  late List<String> terminalsWithDocuments;
  late List<String> terminalsLoadingDocuments = <String>[];
  late Map<String, String> terminalsDocumentErrors = <String, String>{};

  late List<int> usersRegistered;
  late List<int> usersAskSpeech;
  late List<int> usersOnSpeech;

  late List<String> guestsAskSpeech;
  late List<GuestPlace> guestsPlaces;

  late Map<String, String> usersDecisions;

  late bool? isVissonicModuleOnline;
  late bool? isVissonicServerOnline;
  late bool? isVissonicModuleInit;
  late bool? isVissonicLoading;
  late bool? micsEnabled;
  late Map<String, String> activeMics;
  late List<int> waitingMics;

  late String? playSound;
  late double soundVolume;
  late String? playSoundTimestamp;

  late DateTime timestamp;

  ServerState();

  ServerState.fromJson(Map<String, dynamic> json)
      //storeboard and deputy
      : systemState =
            EnumToString.fromString(SystemState.values, json['systemState']),
        params = json['params'],
        storeboardState = json['storeboardState'] == null
            ? null
            : EnumToString.fromString(
                StoreboardState.values, json['storeboardState']),
        storeboardParams = json['storeboard'],
        isDetailsStoreboard = json['isDetailsStoreboard'],
        registrationResult = json['registrationResult'] ?? 0,
        votingTotalVotes = json['votingTotalVotes'] ?? 0,
        votingResultIndiffirent = json['votingResultIndiffirent'] ?? 0,
        votingResultNo = json['votingResultNo'] ?? 0,
        votingResultYes = json['votingResultYes'] ?? 0,
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
        isVissonicModuleOnline = json['isVissonicModuleOnline'],
        isVissonicModuleInit = json['isVissonicModuleInit'],
        isVissonicLoading = json['isVissonicLoading'],
        isVissonicServerOnline = json['isVissonicServerOnline'],
        micsEnabled = json['micsEnabled'],
        activeMics = json['activeMics'] == null
            ? <String, String>{}
            : jsonDecode(json['activeMics']).cast<String, String>(),
        waitingMics = json['waitingMics'] == null
            ? <int>[]
            : json['waitingMics'].toList().cast<int>(),
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
