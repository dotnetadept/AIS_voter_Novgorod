import 'ws_connection.dart';
import 'dart:convert' show json;
import '../models/ais_model.dart';
import 'package:ais_model/ais_model.dart' as client_models;
import 'package:enum_to_string/enum_to_string.dart';

class ServerState {
  // current state of the system
  static client_models.SystemState systemState;

  // current state of the storeboard
  static client_models.StoreboardState storeboardState;
  // params of storeboard
  static String storeboardParams;
  static bool isDetailsStoreboard = false;

  // connected devices summary
  static String formattedDevicesOnline;
  static String versions;

  // list of terminals online
  static List<String> terminalsOnline = <String>[];
  // map of users to terminals
  static Map<String, int> usersTerminals = <String, int>{};

  // users states
  static List<int> usersRegistered = <int>[];
  static List<int> usersAskSpeech = <int>[];
  static Map<String, String> usersDecisions = <String, String>{};

  static List<String> guestsAskSpeech = <String>[];
  static List<client_models.GuestPlace> guestsPlaces =
      <client_models.GuestPlace>[];

  // document states
  static bool isLoadingDocuments = false;
  static List<String> terminalsForDownload = <String>[];
  static List<String> terminalsLoadingDocuments = <String>[];
  static List<String> terminalsWithDocuments = <String>[];
  static Map<String, String> terminalsDocumentErrors = <String, String>{};

  // video stream settings
  static bool isStreamStarted = false;
  static String streamControl;
  static bool showToManager = false;
  static bool showAskWordButton = false;

  // active microphones
  static Map<String, String> activeMics = <String, String>{};

  // Storeboard params
  static int registrationResult;
  static int votingResultYes;
  static int votingResultNo;
  static int votingResultIndiffirent;
  static int votingTotalVotes;
  // signalization signals
  static client_models.Signal startSignal;
  static client_models.Signal endSignal;
  static bool autoEnd;
  //  voting history
  static client_models.VotingHistory votingHistory;
  // refresh stream
  static bool isRefreshStream = false;

  // registration completed flag
  static bool isRegistrationCompleted = false;

  // internal state
  static Meeting selectedMeeting;
  static MeetingSession meetingSession;
  static Question selectedQuestion;
  static Question previousSelectedQuestion;
  static QuestionSession questionSession;
  static AskWordQueueSession askWordQueueSession;
  static RegistrationSession registrationSession;
  static SpeakerSession speakerSession;

  static String playSound = '';
  static double soundVolume = 100.0;
  static String playSoundTimestamp = '';

  static final ServerState _singleton = ServerState._internal();

  factory ServerState() {
    return _singleton;
  }

  ServerState._internal();

  // state message format for operator_panel and manager
  Map toJson() => {
        'systemState': EnumToString.convertToString(systemState),
        'storeboardState': EnumToString.convertToString(storeboardState),
        'storeboardParams': storeboardParams,
        'isDetailsStoreboard': isDetailsStoreboard,
        'params': json.encode({
          'selectedMeeting': selectedMeeting?.id,
          'selectedQuestion': selectedQuestion?.id,
          'status': selectedMeeting?.status,
          'lastUpdated': selectedMeeting?.lastUpdated?.toIso8601String(),
          'mode': questionSession?.meetingSessionId,
          'voting_status': questionSession == null ||
                  questionSession.usersCountVotedYes == null
              ? false
              : questionSession.usersCountVotedYes >=
                  questionSession.usersCountForSuccess,
          'isLoadingDocuments': isLoadingDocuments,
        }),
        'questionSession': questionSession?.toClient()?.toJson(),
        'registrationSession': registrationSession?.toClient()?.toJson(),
        'askWordQueueSession': askWordQueueSession?.toClient()?.toJson(),
        'speakerSession': speakerSession?.toClient()?.toJson(),
        'formattedDevicesOnline': formattedDevicesOnline,
        'versions': versions,
        'terminalsOnline': terminalsOnline,
        'terminalsWithDocuments': terminalsWithDocuments,
        'terminalsLoadingDocuments': terminalsLoadingDocuments,
        'terminalsDocumentErrors': json.encode(terminalsDocumentErrors),
        'usersRegistered': usersRegistered,
        'usersAskSpeech': usersAskSpeech,
        'guestsAskSpeech': guestsAskSpeech,
        'guestsPlaces': guestsPlaces,
        'activeMics': json.encode(activeMics),
        'registrationResult': registrationResult,
        'votingResultIndiffirent': votingResultIndiffirent,
        'votingResultNo': votingResultNo,
        'votingResultYes': votingResultYes,
        'votingTotalVotes': votingTotalVotes,
        'startSignal': startSignal?.toJson(),
        'endSignal': endSignal?.toJson(),
        'autoEnd': autoEnd,
        'votingHistory': json.encode(votingHistory?.toJson()),
        'isRegistrationCompleted': isRegistrationCompleted,
        'usersDecisions': json.encode(usersDecisions),
        'usersTerminals': json.encode(usersTerminals),
        'isStreamStarted': isStreamStarted,
        'isRefreshStream': isRefreshStream,
        'streamControl': streamControl,
        'showToManager': showToManager,
        'showAskWordButton': showAskWordButton,
        'playSound': playSound,
        'soundVolume': soundVolume,
        'playSoundTimestamp': playSoundTimestamp,
      };

  // state message format for deputy, guest and storeboard
  Map toShortJson(WSConnection connection) => {
        'systemState': EnumToString.convertToString(systemState),
        'storeboardState': EnumToString.convertToString(storeboardState),
        'storeboardParams': storeboardParams,
        'isDetailsStoreboard': isDetailsStoreboard,
        'params': json.encode({
          'selectedMeeting': selectedMeeting?.id,
          'selectedQuestion': selectedQuestion?.id,
          'status': selectedMeeting?.status,
          'lastUpdated': selectedMeeting?.lastUpdated?.toIso8601String(),
          'mode': questionSession?.meetingSessionId,
        }),
        'questionSession': questionSession?.toClient()?.toJson(),
        'askWordQueueSession': askWordQueueSession?.toClient()?.toJson(),
        'registrationSession': registrationSession?.toClient()?.toJson(),
        'speakerSession': speakerSession?.toClient()?.toJson(),
        'registrationResult': registrationResult,
        'votingResultIndiffirent': votingResultIndiffirent,
        'votingResultNo': votingResultNo,
        'votingResultYes': votingResultYes,
        'votingTotalVotes': votingTotalVotes,
        'startSignal': startSignal?.toJson(),
        'endSignal': endSignal?.toJson(),
        'autoEnd': autoEnd,
        'terminalsOnline': terminalsOnline,
        'votingHistory': json.encode(votingHistory?.toJson()),
        'isRegistrationCompleted': isRegistrationCompleted,
        'usersTerminals': json.encode(usersTerminals),
        'isStreamStarted': isStreamStarted,
        'isRefreshStream': isRefreshStream,
        'streamControl': streamControl,
        'showToManager': showToManager,
        'showAskWordButton': showAskWordButton,
        'usersRegistered': usersRegistered,
        'usersAskSpeech': usersAskSpeech,
        'guestsAskSpeech': guestsAskSpeech,
        'guestsPlaces': guestsPlaces,
        'usersDecisions': json.encode(usersDecisions)
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

    connections.sort((a, b) {
      var cmp = b.type.compareTo(a.type);
      if (cmp != 0) return cmp;
      return (b.terminalId ?? '').compareTo(a.terminalId ?? '');
    });
    var connectionVersions = <String, String>{};
    for (var i = 0; i < connections.length; i++) {
      connectionVersions.putIfAbsent(
          'type:${connections[i].type ?? 'н/д'};terminalId:${connections[i].terminalId ?? 'н/д'};userId:${connections[i].deputyId?.toString() ?? 'н/д'}',
          () => connections[i].version ?? 'н/д');
    }
    versions = json.encode(connectionVersions);
  }
}