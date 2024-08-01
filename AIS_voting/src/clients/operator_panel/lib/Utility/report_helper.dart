import 'dart:convert';
import 'dart:io';
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/dialogs.dart';
import 'package:ais_utils/server_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:docx_template/docx_template.dart';

class ReportHelper {
  // Novgorod
  Future<void> getMeetingDetailedReport(
    BuildContext context,
    Meeting meeting,
    Settings settings,
    int timeOffset,
    List<VotingMode> votingModes,
  ) async {
    var isReportCompleted = false;
    var reportDirectory =
        settings.questionListSettings.reportsFolderPath + '/' + meeting.name;

    try {
      //delete previous reports directory
      if (await Directory(reportDirectory).exists()) {
        await Directory(reportDirectory).delete(recursive: true);
      }
      // create new report directory
      await Directory(reportDirectory).create();

      var usersResponse = await http.get(Uri.http(
          ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"));
      var users = (json.decode(usersResponse.body) as List)
          .map((data) => User.fromJson(data))
          .toList();

      var meetingSessionsResponce = await http.get(Uri.http(
          ServerConnection.getHttpServerUrl(GlobalConfiguration()),
          "/meeting_sessions"));

      List<MeetingSession> meetingSessionsList =
          (json.decode(meetingSessionsResponce.body) as List)
              .map((data) => MeetingSession.fromJson(data))
              .toList()
              .where((element) => element.meetingId == meeting.id)
              .toList();

      for (int meetingSessionIndex = 0;
          meetingSessionIndex < meetingSessionsList.length;
          meetingSessionIndex++) {
        var currentMeetingSession = meetingSessionsList[meetingSessionIndex];

        var guestsInfo = meeting.group.guests.split(',').join(', ');

        var additionalUsers = settings.reportSettings.reportFooter.split(', ');

        var secretaryInfo = additionalUsers.removeLast();
        var membersInfo = additionalUsers.join(', ');

        var chairmanGroupUser = meeting.group.groupUsers
            .firstWhere((element) => element.isManager, orElse: () => null);
        var chairman = users.firstWhere(
            (element) => element.id == chairmanGroupUser.user.id,
            orElse: () => null);

        var startDate = currentMeetingSession.startDate ?? DateTime.now();
        var endDate = currentMeetingSession.endDate ?? DateTime.now();

        // fill common info
        Content votingNamedContent = Content();
        votingNamedContent
          ..add(TextContent("date",
              "${DateFormat('dd.MM.yyyy').format(startDate.toLocal())}"))
          ..add(TextContent(
              "start_hours", "${DateFormat('HH').format(startDate.toLocal())}"))
          ..add(TextContent("start_minutes",
              "${DateFormat('mm').format(startDate.toLocal())}"))
          ..add(TextContent("chairman", "${chairman.getShortName()}"))
          ..add(TextContent("secretary", "$secretaryInfo"))
          ..add(TextContent("members", "$membersInfo"))
          ..add(TextContent("quests", "$guestsInfo"))
          ..add(TextContent(
              "close_hours", "${DateFormat('HH').format(endDate.toLocal())}"))
          ..add(TextContent("close_minutes",
              "${DateFormat('mm').format(endDate.toLocal())}"));

        var questionSessionsResponse = await http.get(Uri.http(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/questionsessions/${currentMeetingSession.id}"));
        var questionSessions =
            (json.decode(questionSessionsResponse.body) as List)
                .map((data) => QuestionSession.fromJson(data))
                .toList();

        // fill questions info
        var questionsInfo = <PlainContent>[];

        for (var questionSessionIndex = 0;
            questionSessionIndex < questionSessions.length;
            questionSessionIndex++) {
          var currentQuestionSession = questionSessions[questionSessionIndex];

          var currentQuestion = meeting.agenda.questions.firstWhere(
              (element) => element.id == currentQuestionSession.questionId,
              orElse: () => null);

          var isUnanimously = currentQuestionSession.usersCountVotedYes ==
                  currentQuestionSession.usersCountVoted ||
              currentQuestionSession.usersCountVotedNo ==
                  currentQuestionSession.usersCountVoted;
          var unanimouslyModifier = isUnanimously ? ' единогласно' : '';

          questionsInfo.add(PlainContent("question_info")
            ..add(TextContent("question_name", "${currentQuestion.name}"))
            ..add(TextContent("question_content",
                "${currentQuestion.getReportDescription()}"))
            ..add(TextContent("voted_yes_count",
                "${currentQuestionSession.usersCountVotedYes}"))
            ..add(TextContent("voted_no_count",
                "${currentQuestionSession.usersCountVotedNo}"))
            ..add(TextContent("voted_indifferent_count",
                "${currentQuestionSession.usersCountVotedIndiffirent}"))
            ..add(TextContent(
                "decision",
                currentQuestionSession.usersCountVotedYes >=
                        currentQuestionSession.usersCountForSuccess
                    ? "принято$unanimouslyModifier"
                    : "не принято$unanimouslyModifier")));
        }

        votingNamedContent..add(ListContent("questions_info", questionsInfo));

        // fill detailed template
        final dataNamed =
            await rootBundle.load('assets/templates/votingDetailed.docx');
        final bytesNamed = dataNamed.buffer.asUint8List();
        final docxNamed = await DocxTemplate.fromBytes(bytesNamed);
        final docNamed = await docxNamed.generate(votingNamedContent);

        final fileNameNamed = reportDirectory +
            '/Протокол_Президиума_${(meetingSessionIndex + 1)}.docx';
        final fileNamed = File(fileNameNamed);
        if (docNamed != null) {
          await fileNamed.writeAsBytes(docNamed);
        }

        // print report
        await Process.run('unoconv', <String>[
          '-f',
          'pdf',
          '--export=ExportFormFields=false',
          '$fileNameNamed'
        ]);
        var fileToPrint = fileNameNamed.replaceAll('.docx', '.pdf');
        Process.run('lp', <String>[fileToPrint]);
      }
    } catch (exc) {
      isReportCompleted = false;
      Utility().showMessageOkDialog(context,
          title: 'Ошибка экспорта протокола',
          message: TextSpan(
            text:
                'В ходе экспорта протокола возникла ошибка: ${exc.toString()}',
          ),
          okButtonText: 'Ок');
    } finally {
      if (isReportCompleted == true) {
        Utility().showMessageOkDialog(context,
            title: 'Экспорт протокола',
            message: TextSpan(
              text:
                  'Экспорт протокола успешно завершен.\r\nДиректория отчета: $reportDirectory',
            ),
            okButtonText: 'Ок');
      }
    }
  }

  // Novgorod
  Future<void> getMeetingCommonReport(
    BuildContext context,
    Meeting meeting,
    Settings settings,
    int timeOffset,
    List<VotingMode> votingModes,
  ) async {
    var isReportCompleted = false;
    var reportDirectory =
        settings.questionListSettings.reportsFolderPath + '/' + meeting.name;

    try {
      //delete previous reports directory
      if (await Directory(reportDirectory).exists()) {
        await Directory(reportDirectory).delete(recursive: true);
      }
      // create new report directory
      await Directory(reportDirectory).create();

      var usersResponse = await http.get(Uri.http(
          ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"));
      var users = (json.decode(usersResponse.body) as List)
          .map((data) => User.fromJson(data))
          .toList();

      var meetingSessionsResponce = await http.get(Uri.http(
          ServerConnection.getHttpServerUrl(GlobalConfiguration()),
          "/meeting_sessions"));

      List<MeetingSession> meetingSessionsList =
          (json.decode(meetingSessionsResponce.body) as List)
              .map((data) => MeetingSession.fromJson(data))
              .toList()
              .where((element) => element.meetingId == meeting.id)
              .toList();

      for (int meetingSessionIndex = 0;
          meetingSessionIndex < meetingSessionsList.length;
          meetingSessionIndex++) {
        var currentMeetingSession = meetingSessionsList[meetingSessionIndex];

        var guestsInfo = meeting.group.guests.split(',').join(', ');

        var additionalUsers = settings.reportSettings.reportFooter.split(', ');

        var secretaryInfo = additionalUsers.removeLast();
        var membersInfo = additionalUsers.join(', ');

        var chairmanGroupUser = meeting.group.groupUsers
            .firstWhere((element) => element.isManager, orElse: () => null);
        var chairman = users.firstWhere(
            (element) => element.id == chairmanGroupUser.user.id,
            orElse: () => null);

        var questionSessionsResponse = await http.get(Uri.http(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/questionsessions/${currentMeetingSession.id}"));
        var questionSessions =
            (json.decode(questionSessionsResponse.body) as List)
                .map((data) => QuestionSession.fromJson(data))
                .toList();

        var isQuorumSuccess = false;
        var registredCount = 0;
        if (questionSessions.isNotEmpty) {
          isQuorumSuccess = questionSessions.first.usersCountRegistred >=
              meeting.group.quorumCount;
          registredCount = questionSessions.first.usersCountRegistred;
        }

        var startDate = currentMeetingSession.startDate ?? DateTime.now();
        var endDate = currentMeetingSession.endDate ?? DateTime.now();

        // fill common content
        Content votingNamedContent = Content();
        votingNamedContent
          ..add(TextContent("date",
              "${DateFormat('dd.MM.yyyy').format(startDate.toLocal())}"))
          ..add(TextContent(
              "start_hours", "${DateFormat('HH').format(startDate.toLocal())}"))
          ..add(TextContent("start_minutes",
              "${DateFormat('mm').format(startDate.toLocal())}"))
          ..add(TextContent("common_count", "${meeting.group.chosenCount}"))
          ..add(TextContent("registred_count", "$registredCount"))
          ..add(TextContent("quorum_status",
              isQuorumSuccess ? "кворум имеется" : "кворум отсутствует"))
          ..add(TextContent("chairman", "${chairman.getShortName()}"))
          ..add(TextContent("secretary", "$secretaryInfo"))
          ..add(TextContent("members", "$membersInfo"))
          ..add(TextContent("quests", "$guestsInfo"))
          ..add(TextContent(
              "close_hours", "${DateFormat('HH').format(endDate.toLocal())}"))
          ..add(TextContent("close_minutes",
              "${DateFormat('mm').format(endDate.toLocal())}"));

        // fill agenda info
        var agendaInfo = <PlainContent>[];

        meeting.agenda.questions
            .sort((a, b) => a.orderNum.compareTo(b.orderNum));

        for (var questionIndex = 0;
            questionIndex < meeting.agenda.questions.length;
            questionIndex++) {
          var currentQuestion = meeting.agenda.questions[questionIndex];

          if (currentQuestion.orderNum == 0) {
            continue;
          }

          agendaInfo.add(PlainContent("question_info")
            ..add(TextContent("question_content",
                "${currentQuestion.orderNum}. ${currentQuestion.getReportDescription()}")));
        }

        votingNamedContent..add(ListContent("agenda_info", agendaInfo));

        // fill questions info
        var questionsInfo = <PlainContent>[];

        for (var questionSessionIndex = 0;
            questionSessionIndex < questionSessions.length;
            questionSessionIndex++) {
          var currentQuestionSession = questionSessions[questionSessionIndex];

          var currentQuestion = meeting.agenda.questions.firstWhere(
              (element) => element.id == currentQuestionSession.questionId,
              orElse: () => null);

          if (currentQuestion.orderNum == 0) {
            continue;
          }

          var isUnanimously = currentQuestionSession.usersCountVotedYes ==
                  currentQuestionSession.usersCountVoted ||
              currentQuestionSession.usersCountVotedNo ==
                  currentQuestionSession.usersCountVoted;
          var unanimouslyModifier = isUnanimously ? ' единогласно' : '';

          questionsInfo.add(PlainContent("question_info")
            ..add(TextContent("question_name", "${currentQuestion.name}"))
            ..add(TextContent("question_content",
                "${currentQuestion.getReportDescription()}"))
            ..add(TextContent("voted_yes_count",
                "${currentQuestionSession.usersCountVotedYes}"))
            ..add(TextContent("voted_no_count",
                "${currentQuestionSession.usersCountVotedNo}"))
            ..add(TextContent("voted_indifferent_count",
                "${currentQuestionSession.usersCountVotedIndiffirent}"))
            ..add(TextContent(
                "decision",
                currentQuestionSession.usersCountVotedYes >=
                        currentQuestionSession.usersCountForSuccess
                    ? "решение принято$unanimouslyModifier"
                    : "решение не принято$unanimouslyModifier")));
        }

        votingNamedContent..add(ListContent("questions_info", questionsInfo));

        // fill common template
        final dataNamed =
            await rootBundle.load('assets/templates/votingCommon.docx');
        final bytesNamed = dataNamed.buffer.asUint8List();
        final docxNamed = await DocxTemplate.fromBytes(bytesNamed);
        final docNamed = await docxNamed.generate(votingNamedContent);

        final fileNameNamed = reportDirectory +
            '/Протокол_Общий_${(meetingSessionIndex + 1)}.docx';
        final fileNamed = File(fileNameNamed);
        if (docNamed != null) {
          await fileNamed.writeAsBytes(docNamed);
        }

        // print report
        await Process.run('unoconv', <String>[
          '-f',
          'pdf',
          '--export=ExportFormFields=false',
          '$fileNameNamed'
        ]);
        var fileToPrint = fileNameNamed.replaceAll('.docx', '.pdf');
        Process.run('lp', <String>[fileToPrint]);
      }
    } catch (exc) {
      isReportCompleted = false;
      Utility().showMessageOkDialog(context,
          title: 'Ошибка экспорта протокола',
          message: TextSpan(
            text:
                'В ходе экспорта протокола возникла ошибка: ${exc.toString()}',
          ),
          okButtonText: 'Ок');
    } finally {
      if (isReportCompleted == true) {
        Utility().showMessageOkDialog(context,
            title: 'Экспорт протокола',
            message: TextSpan(
              text:
                  'Экспорт протокола успешно завершен.\r\nДиректория отчета: $reportDirectory',
            ),
            okButtonText: 'Ок');
      }
    }
  }

  // Novgorod
  Future<void> getVotingNamedReport(
    Meeting meeting,
    Settings settings,
    VotingMode votingMode,
    List<User> users,
    List<int> usersRegistered,
    Question question,
    QuestionSession questionSession,
    MeetingSession meetingSession,
    int timeOffset,
  ) async {
    var currentMeetingSession = meetingSession;

    if (currentMeetingSession == null) {
      var meetingSessionsResponce = await http.get(Uri.http(
          ServerConnection.getHttpServerUrl(GlobalConfiguration()),
          "/meeting_sessions"));

      List<MeetingSession> meetingSessionsList =
          (json.decode(meetingSessionsResponce.body) as List)
              .map((data) => MeetingSession.fromJson(data))
              .toList()
              .where((element) => element.meetingId == meeting.id)
              .toList();
      currentMeetingSession = meetingSessionsList.last;
    }

    var currentQuestionSession = questionSession;

    var questionSessionsResponse = await http.get(Uri.http(
        ServerConnection.getHttpServerUrl(GlobalConfiguration()),
        "/questionsessions/${currentMeetingSession.id}"));
    var questionSessions = (json.decode(questionSessionsResponse.body) as List)
        .map((data) => QuestionSession.fromJson(data))
        .toList();

    if (currentQuestionSession == null) {
      if (questionSessions.length == 0) {
        return;
      }

      currentQuestionSession = questionSessions.last;
    }

    var sessionIndex = questionSessions.indexOf(questionSessions.firstWhere(
      (element) => element.id == currentQuestionSession.id,
      orElse: () => null,
    ));

    var isQuorumSuccess =
        currentQuestionSession.usersCountRegistred >= meeting.group.quorumCount;

    var votedYesNames = '';
    var votedNoNames = '';
    var votedIndifferentNames = '';

    for (var groupUser in meeting.group.groupUsers) {
      var user = users.firstWhere((element) => element.id == groupUser.user.id,
          orElse: () => null);
      var result = currentQuestionSession.results.firstWhere(
          (element) => element.userId == groupUser.user.id,
          orElse: () => null);

      var isUserRegistred = usersRegistered.contains(user?.id);

      if (!isUserRegistred) {
        continue;
      }

      if (result?.result == 'ЗА') {
        votedYesNames += (votedYesNames.isEmpty ? '' : '\r\n') +
            '    ' +
            user?.getFullName();
      } else if (result?.result == 'ПРОТИВ') {
        votedNoNames +=
            (votedNoNames.isEmpty ? '' : '\r\n') + '    ' + user?.getFullName();
      } else if (result?.result == 'ВОЗДЕРЖАЛСЯ') {
        votedIndifferentNames += (votedIndifferentNames.isEmpty ? '' : '\r\n') +
            '    ' +
            user?.getFullName();
      }
    }

    Content votingNamedContent = Content();
    votingNamedContent
      ..add(TextContent("group_name", "№${meeting.group.name}"))
      ..add(TextContent("time",
          "${DateFormat('HH:mm').format(currentQuestionSession.endDate.toLocal())}"))
      ..add(TextContent("date",
          "${DateFormat('dd.MM.yyyy').format(currentQuestionSession.endDate.toLocal())}"))
      ..add(TextContent("protocol_number", "№${(sessionIndex + 1)}"))
      ..add(TextContent("question_name", "${question.name}"))
      ..add(
          TextContent("question_content", "${question.getReportDescription()}"))
      ..add(TextContent("voting_mode", "${votingMode.name}"))
      ..add(TextContent("law_count", "${meeting.group.lawUsersCount}"))
      ..add(TextContent("chosen_count", "${meeting.group.chosenCount}"))
      ..add(TextContent("quorum_count", "${meeting.group.quorumCount}"))
      ..add(TextContent(
          "quorum_status", "${isQuorumSuccess ? 'Кворум есть' : 'Кворум нет'}"))
      ..add(TextContent(
          "voted_yes_count", "${currentQuestionSession.usersCountVotedYes}"))
      ..add(TextContent("voted_yes_names", "$votedYesNames"))
      ..add(TextContent(
          "voted_no_count", "${currentQuestionSession.usersCountVotedNo}"))
      ..add(TextContent("voted_no_names", "$votedNoNames"))
      ..add(TextContent("voted_indifferent_count",
          "${currentQuestionSession.usersCountVotedIndiffirent}"))
      ..add(TextContent("voted_indifferent_names", "$votedIndifferentNames"))
      ..add(TextContent(
          "voted_total", "${currentQuestionSession.usersCountVoted}"))
      ..add(TextContent(
          "success_count", "${currentQuestionSession.usersCountForSuccess}"))
      ..add(TextContent(
          "decision",
          currentQuestionSession.usersCountVotedYes >=
                  currentQuestionSession.usersCountForSuccess
              ? "РЕШЕНИЕ ПРИНЯТО"
              : "РЕШЕНИЕ НЕ ПРИНЯТО"))
      ..add(TextContent("chairman", "${settings.reportSettings.reportFooter}"));

    // fill voting named template
    final dataNamed =
        await rootBundle.load('assets/templates/votingNamed.docx');
    final bytesNamed = dataNamed.buffer.asUint8List();
    final docxNamed = await DocxTemplate.fromBytes(bytesNamed);
    final docNamed = await docxNamed.generate(votingNamedContent);
    var reportDirectory =
        settings.questionListSettings.reportsFolderPath + '/' + meeting.name;
    // create reports directory if not exists
    if (!await Directory(reportDirectory).exists()) {
      await Directory(reportDirectory).create();
    }
    final fileNameNamed = reportDirectory +
        '/${DateFormat('HHmm').format(currentQuestionSession.endDate)}_Поименно_${(sessionIndex + 1)}.docx';
    final fileNamed = File(fileNameNamed);
    if (docNamed != null) {
      await fileNamed.writeAsBytes(docNamed);
    }

    // print report
    await Process.run('unoconv', <String>[
      '-f',
      'pdf',
      '--export=ExportFormFields=false',
      '$fileNameNamed'
    ]);
    var fileToPrint = fileNameNamed.replaceAll('.docx', '.pdf');
    Process.run('lp', <String>[fileToPrint]);
  }
}
