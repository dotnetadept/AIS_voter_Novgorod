import 'ws_connection.dart';
import 'dart:convert' show json;
import '../models/ais_model.dart';
import 'package:ais_model/ais_model.dart' as client_models;
import 'package:enum_to_string/enum_to_string.dart';

class ServerState {
  // current state of the system
  static client_models.SystemState systemState;

  // connected devices summary
  static String formattedDevicesOnline;

  // list of terminals online
  static List<String> terminalsOnline = <String>[];
  // map of users to terminals
  static Map<String, int> usersTerminals = <String, int>{};

  // users states
  static List<int> usersRegistered = <int>[];
  static List<int> usersAskSpeech = <int>[];
  static Map<String, String> usersDecisions = <String, String>{};

  // document states
  static bool isLoadingDocuments = false;
  static List<String> terminalsForDownload = <String>[];
  static List<String> terminalsLoadingDocuments = <String>[];
  static List<String> terminalsWithDocuments = <String>[];
  static Map<String, String> terminalsDocumentErrors = <String, String>{};

  // video stream settings
  static String streamUrl;
  static String streamControl;

  // vissonic settings
  static bool isVissonicModuleOnline = false;
  static bool isVissonicServerOnline = false;
  static bool isVissonicModuleInit = false;
  static bool micsEnabled;
  static List<int> activeMics = <int>[];
  static List<int> waitingMics = <int>[];

  // Storeboard params
  static int registrationResult;
  static int votingResultYes;
  static int votingResultNo;
  static int votingResultIndiffirent;
  static int votingTotalVotes;
  //  speaker
  static String currentSpeaker;
  static String speakerType;
  static String speakerName;
  static Duration speakerTimelimit;
  //  custom text
  static String storeboardCustomCaption;
  static String storeboardCustomText;
  //  storeboard template
  static client_models.StoreboardTemplate storeboardTemplate;
  //  break
  static DateTime breakTime;
  //  details results
  static bool isDetailsStoreboard;
  static bool isFlushStoreboard = false;

  // registration completed flag
  static bool isRegistrationCompleted = false;
  // meeting completed flag
  static bool isMeetingCompleted = false;

  // internal state
  static Meeting selectedMeeting;
  static MeetingSession selectedMeetingSession;
  static Question selectedQuestion;
  static Question previousSelectedQuestion;
  static QuestionSession selectedQuestionSession;
  static RegistrationSession registrationSession;

  static final ServerState _singleton = ServerState._internal();

  factory ServerState() {
    return _singleton;
  }

  ServerState._internal();

  // state message format for operator_panel and manager
  Map toJson() => {
        'systemState': EnumToString.convertToString(systemState),
        'params': json.encode({
          'selectedMeeting': selectedMeeting?.id,
          'selectedQuestion': selectedQuestion?.id,
          'status': selectedMeeting?.status,
          'lastUpdated': selectedMeeting?.lastUpdated?.toIso8601String(),
          'mode': selectedQuestionSession?.meetingSessionId,
          'voting_interval': selectedQuestionSession?.interval,
          'success_count': selectedQuestionSession?.usersCountForSuccess,
          'registration_interval': registrationSession?.interval,
          'voting_status': selectedQuestionSession == null ||
                  selectedQuestionSession.usersCountVotedYes == null
              ? false
              : selectedQuestionSession.usersCountVotedYes >=
                  selectedQuestionSession.usersCountForSuccess,
          'isLoadingDocuments': isLoadingDocuments,
        }),
        'formattedDevicesOnline': formattedDevicesOnline,
        'isVissonicModuleOnline': isVissonicModuleOnline,
        'isVissonicServerOnline': isVissonicServerOnline,
        'isVissonicModuleInit': isVissonicModuleInit,
        'terminalsOnline': terminalsOnline,
        'terminalsWithDocuments': terminalsWithDocuments,
        'terminalsLoadingDocuments': terminalsLoadingDocuments,
        'terminalsDocumentErrors': json.encode(terminalsDocumentErrors),
        'usersRegistered': usersRegistered,
        'usersAskSpeech': usersAskSpeech,
        'activeMics': activeMics,
        'waitingMics': waitingMics,
        'micsEnabled': micsEnabled,
        'currentSpeaker': currentSpeaker,
        'registrationResult': registrationResult,
        'votingResultIndiffirent': votingResultIndiffirent,
        'votingResultNo': votingResultNo,
        'votingResultYes': votingResultYes,
        'votingTotalVotes': votingTotalVotes,
        'speakerType': speakerType,
        'speakerName': speakerName,
        'speakerTimelimit': speakerTimelimit.toString(),
        'storeboardCustomCaption': storeboardCustomCaption,
        'storeboardCustomText': storeboardCustomText,
        'storeboardTemplate': storeboardTemplate,
        'breakTime': breakTime == null ? null : breakTime.toIso8601String(),
        'isFlushStoreboard': isFlushStoreboard,
        'isDetailsStoreboard': isDetailsStoreboard,
        'isRegistrationCompleted': isRegistrationCompleted,
        'isMeetingCompleted': isMeetingCompleted,
        'usersDecisions': json.encode(usersDecisions),
        'usersTerminals': json.encode(usersTerminals),
        'streamUrl': streamUrl,
        'streamControl': streamControl
      };

  // state message format for deputy, guest and storeboard
  Map toShortJson(WSConnection connection) => {
        'systemState': EnumToString.convertToString(systemState),
        'params': json.encode({
          'selectedMeeting': selectedMeeting?.id,
          'selectedQuestion': selectedQuestion?.id,
          'status': selectedMeeting?.status,
          'lastUpdated': selectedMeeting?.lastUpdated?.toIso8601String(),
          'mode': selectedQuestionSession?.meetingSessionId,
          'voting_interval': selectedQuestionSession?.interval,
          'success_count': selectedQuestionSession?.usersCountForSuccess,
          'registration_interval': registrationSession?.interval,
          'voting_status': selectedQuestionSession == null ||
                  selectedQuestionSession.usersCountVotedYes == null
              ? false
              : selectedQuestionSession.usersCountVotedYes >=
                  selectedQuestionSession.usersCountForSuccess,
        }),
        'registrationResult': registrationResult,
        'votingResultIndiffirent': votingResultIndiffirent,
        'votingResultNo': votingResultNo,
        'votingResultYes': votingResultYes,
        'votingTotalVotes': votingTotalVotes,
        'speakerType': speakerType,
        'speakerName': speakerName,
        'speakerTimelimit': speakerTimelimit.toString(),
        'storeboardCustomCaption': storeboardCustomCaption,
        'storeboardCustomText': storeboardCustomText,
        'storeboardTemplate': storeboardTemplate,
        'breakTime': breakTime == null ? null : breakTime.toIso8601String(),
        'isFlushStoreboard': isFlushStoreboard,
        'isDetailsStoreboard': isDetailsStoreboard,
        'isRegistrationCompleted': isRegistrationCompleted,
        'isMeetingCompleted': isMeetingCompleted,
        'streamUrl': streamUrl,
        'streamControl': streamControl,

        'usersRegistered': usersRegistered,
        'usersAskSpeech': usersAskSpeech,
        'usersDecisions': json.encode(usersDecisions)

        // /// set tables for single user
        // 'usersRegistered': usersRegistered.contains(connection.deputyId)
        //     ? <int>[connection.deputyId]
        //     : <int>[],
        // 'usersAskSpeech': usersAskSpeech.contains(connection.deputyId)
        //     ? <int>[connection.deputyId]
        //     : <int>[],
        // 'usersDecisions': usersDecisions.entries.any(
        //         (element) => element.key == connection.deputyId?.toString())
        //     ? json.encode(<String, String>{
        //         connection.deputyId?.toString():
        //             usersDecisions[connection.deputyId?.toString()],
        //       })
        //     : json.encode(<String, String>{})
      };

  void setDevicesInfo(List<WSConnection> connections) {
    var cardCount =
        connections.where((element) => element.isUseAuthcard == true).length;
    var windowsCount =
        connections.where((element) => element.isWindowsClient == true).length;
    var managerCount =
        connections.where((element) => element.type == 'manager').length;
    var deputyCount =
        connections.where((element) => element.type == 'deputy').length;
    var operatorCount =
        connections.where((element) => element.type == 'operator').length;
    var guestCount =
        connections.where((element) => element.type == 'guest').length;
    var storeboardCount =
        connections.where((element) => element.type == 'storeboard').length;

    var devicesOnline = <String, int>{};
    devicesOnline.putIfAbsent('Количество карт', () => cardCount);
    devicesOnline.putIfAbsent('Windows клиенты', () => windowsCount);
    devicesOnline.putIfAbsent('Председательские места', () => managerCount);
    devicesOnline.putIfAbsent('Депутатские места', () => deputyCount);
    devicesOnline.putIfAbsent('Операторские места', () => operatorCount);
    devicesOnline.putIfAbsent('Гости', () => guestCount);
    devicesOnline.putIfAbsent('Табло', () => storeboardCount);
    formattedDevicesOnline = json.encode(devicesOnline);
  }
}

class VissonicServerState {
  bool isVissonicServerOnline = false;
  bool isVissonicModuleInit = false;
  bool micsEnabled;
  List<int> activeMics = <int>[];
  List<int> waitingMics = <int>[];

  VissonicServerState.fromJson(Map<String, dynamic> json)
      : isVissonicServerOnline = json['isVissonicServerOnline'],
        isVissonicModuleInit = json['isVissonicModuleInit'],
        micsEnabled = json['micsEnabled'],
        activeMics = json['activeMics'].toList().cast<int>(),
        waitingMics = json['waitingMics'].toList().cast<int>();
}
