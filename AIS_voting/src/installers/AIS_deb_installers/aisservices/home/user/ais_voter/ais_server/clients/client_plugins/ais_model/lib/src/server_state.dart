import 'dart:convert';
import 'system_state.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'storeboard_template.dart';

class ServerState {
  //storeboard and deputy
  SystemState systemState;
  String params;

  int registrationResult;
  int votingResultYes;
  int votingResultNo;
  int votingResultIndiffirent;
  int votingTotalVotes;
  String speakerType;
  String speakerName;
  Duration speakerTimelimit;
  String storeboardCustomCaption;
  String storeboardCustomText;
  StoreboardTemplate storeboardTemplate;
  DateTime breakTime;
  bool isFlushStoreboard;
  bool isDetailsStoreboard;
  bool isRegistrationCompleted;
  bool isMeetingCompleted;

  String streamUrl;
  String streamControl;

  //operator and manager
  Map<String, int> formattedDevicesOnline;

  Map<String, int> usersTerminals;
  List<String> terminalsOnline;
  List<String> terminalsWithDocuments;
  List<String> terminalsLoadingDocuments = <String>[];
  Map<String, String> terminalsDocumentErrors = <String, String>{};

  List<int> usersRegistered;
  List<int> usersAskSpeech;
  List<int> usersOnSpeech;

  Map<String, String> usersDecisions;

  bool isVissonicModuleOnline;
  bool isVissonicServerOnline;
  bool isVissonicModuleInit;
  bool micsEnabled;
  List<int> activeMics;
  List<int> waitingMics;
  String currentSpeaker;

  DateTime timestamp;

  ServerState();

  ServerState.fromJson(Map<String, dynamic> json)
      //storeboard and deputy
      : systemState =
            EnumToString.fromString(SystemState.values, json['systemState']),
        params = json['params'],
        registrationResult = json['registrationResult'],
        votingTotalVotes = json['votingTotalVotes'],
        votingResultIndiffirent = json['votingResultIndiffirent'],
        votingResultNo = json['votingResultNo'],
        votingResultYes = json['votingResultYes'],
        speakerType = json['speakerType'],
        speakerName = json['speakerName'],
        speakerTimelimit = (json['speakerTimelimit'] == null ||
                json['speakerTimelimit'].toString() == 'null' ||
                json['speakerTimelimit'].toString().isEmpty)
            ? Duration(seconds: 0)
            : Duration(
                hours: int.tryParse(
                        (json['speakerTimelimit'].toString().split(':'))[0]) ??
                    0,
                minutes: int.tryParse(
                        (json['speakerTimelimit'].toString().split(':'))[1]) ??
                    0,
                seconds: double.tryParse(
                            (json['speakerTimelimit'].toString().split(':'))[2])
                        ?.ceil() ??
                    0,
              ),
        storeboardCustomText = json['storeboardCustomText'],
        storeboardCustomCaption = json['storeboardCustomCaption'],
        storeboardTemplate = json['storeboardTemplate'] == null
            ? null
            : StoreboardTemplate.fromJson(json['storeboardTemplate']),
        breakTime = json['breakTime'] == null
            ? null
            : DateTime.parse(json['breakTime']),
        isFlushStoreboard = json['isFlushStoreboard'],
        isDetailsStoreboard = json['isDetailsStoreboard'],
        isRegistrationCompleted = json['isRegistrationCompleted'],
        isMeetingCompleted = json['isMeetingCompleted'],
        // operator and manager
        formattedDevicesOnline = json['formattedDevicesOnline'] == null
            ? <String, int>{}
            : jsonDecode(json['formattedDevicesOnline']).cast<String, int>(),
        isVissonicServerOnline = json['isVissonicServerOnline'],
        isVissonicModuleInit = json['isVissonicModuleInit'],
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
        usersDecisions = json['usersDecisions'] == null
            ? <String, String>{}
            : jsonDecode(json['usersDecisions']).cast<String, String>(),
        usersTerminals = json['usersTerminals'] == null
            ? <String, int>{}
            : jsonDecode(json['usersTerminals']).cast<String, int>(),
        activeMics = json['activeMics'] == null
            ? <int>[]
            : json['activeMics'].toList().cast<int>(),
        waitingMics = json['waitingMics'] == null
            ? <int>[]
            : json['waitingMics'].toList().cast<int>(),
        micsEnabled = json['micsEnabled'],
        currentSpeaker = json['currentSpeaker'],
        timestamp = DateTime.now(),
        streamUrl = json['streamUrl'],
        streamControl = json['streamControl'];
}
