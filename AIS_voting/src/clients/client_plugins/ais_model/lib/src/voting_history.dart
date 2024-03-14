import 'dart:convert';
import 'package:ais_model/ais_model.dart';

class VotingHistory {
  String questionName;
  bool isQuorumSuccess;
  bool isVotingSuccess;
  bool isManagerDecides;
  int totalVotes;
  int yesVotes;
  int noVotes;
  int indifferentVotes;
  int usersCountForSuccess;
  int usersCountForSuccessDisplay;
  bool isDetailsStoreboard;
  Map<String, String> usersDecisions;

  VotingHistory(
      this.questionName,
      this.isQuorumSuccess,
      this.isVotingSuccess,
      this.isManagerDecides,
      this.totalVotes,
      this.yesVotes,
      this.noVotes,
      this.indifferentVotes,
      this.usersCountForSuccess,
      this.usersCountForSuccessDisplay,
      this.isDetailsStoreboard,
      this.usersDecisions);

  Map toJson() => {
        'usersDecisions': json.encode(usersDecisions),
        'isDetailsStoreboard': isDetailsStoreboard,
        'questionName': questionName,
        'isQuorumSuccess': isQuorumSuccess,
        'isVotingSuccess': isVotingSuccess,
        'isManagerDecides': isManagerDecides,
        'totalVotes': totalVotes,
        'yesVotes': yesVotes,
        'noVotes': noVotes,
        'indifferentVotes': indifferentVotes,
        'usersCountForSuccess': usersCountForSuccess,
        'usersCountForSuccessDisplay': usersCountForSuccessDisplay,
      };

  VotingHistory.fromJson(Map<String, dynamic> json)
      : usersDecisions = json['usersDecisions'] == null
            ? <String, String>{}
            : jsonDecode(json['usersDecisions']).cast<String, String>(),
        isDetailsStoreboard = json['isDetailsStoreboard'],
        questionName = json['questionName'],
        isQuorumSuccess = json['isQuorumSuccess'],
        isVotingSuccess = json['isVotingSuccess'],
        isManagerDecides = json['isManagerDecides'],
        totalVotes = json['totalVotes'],
        yesVotes = json['yesVotes'],
        noVotes = json['noVotes'],
        indifferentVotes = json['indifferentVotes'],
        usersCountForSuccess = json['usersCountForSuccess'],
        usersCountForSuccessDisplay = json['usersCountForSuccessDisplay'];
}
