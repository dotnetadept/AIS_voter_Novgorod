import 'dart:convert';
import 'dart:io';
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/dialogs.dart';
import 'package:ais_utils/server_connection.dart';
import 'package:ais_utils/time_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:docx_template/docx_template.dart';
import 'package:provider/provider.dart';

import '../Providers/WebSocketConnection.dart';

class ReportHelper {
  // Novgorod
  Future<void> getMeetingReport(
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

        Content votingNamedContent = Content();
        votingNamedContent
          ..add(TextContent("group_name", "№${meeting.group.name}"))
          ..add(TextContent("date",
              "${DateFormat('dd.MM.yyyy').format(currentMeetingSession.startDate.toLocal())}"))
          ..add(TextContent("start_hours",
              "${DateFormat('HH').format(currentMeetingSession.startDate.toLocal())}"))
          ..add(TextContent("start_minutes",
              "${DateFormat('mm').format(currentMeetingSession.startDate.toLocal())}"))
          ..add(TextContent("chairman", "${chairman.getShortName()}"))
          ..add(TextContent("secretary", "$secretaryInfo"))
          ..add(TextContent("members", "$membersInfo"))
          ..add(TextContent("quests", "$guestsInfo"))
          ..add(TextContent("close_hours",
              "${DateFormat('HH').format(currentMeetingSession.endDate.toLocal())}"))
          ..add(TextContent("close_minutes",
              "${DateFormat('mm').format(currentMeetingSession.endDate.toLocal())}"));

        var questionSessionsResponse = await http.get(Uri.http(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/questionsessions/${currentMeetingSession.id}"));
        var questionSessions =
            (json.decode(questionSessionsResponse.body) as List)
                .map((data) => QuestionSession.fromJson(data))
                .toList();

        var questionsInfo = <PlainContent>[];

        for (var questionSessionIndex = 0;
            questionSessionIndex < questionSessions.length;
            questionSessionIndex++) {
          var currentQuestionSession = questionSessions[questionSessionIndex];

          var currentQuestion = meeting.agenda.questions.firstWhere(
              (element) => element.id == currentQuestionSession.questionId,
              orElse: () => null);

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
                    ? "принято."
                    : "не принято.")));
        }

        votingNamedContent..add(ListContent("questions_info", questionsInfo));

        // fill voting named template
        final dataNamed =
            await rootBundle.load('assets/templates/votingCommon.docx');
        final bytesNamed = dataNamed.buffer.asUint8List();
        final docxNamed = await DocxTemplate.fromBytes(bytesNamed);
        final docNamed = await docxNamed.generate(votingNamedContent);

        final fileNameNamed =
            reportDirectory + '/Протокол_${(meetingSessionIndex + 1)}.docx';
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

  // // Novgorod
  // Future<void> getMeetingReport(
  //   BuildContext context,
  //   Meeting meeting,
  //   Settings settings,
  //   int timeOffset,
  //   List<VotingMode> votingModes,
  // ) async {
  //   var isReportCompleted = false;
  //   var reportDirectory =
  //       settings.questionListSettings.reportsFolderPath + '/' + meeting.name;
  //   try {
  //     var meetingSessionsResponce = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //         "/meeting_sessions"));

  //     List<MeetingSession> meetingSessionsList =
  //         (json.decode(meetingSessionsResponce.body) as List)
  //             .map((data) => MeetingSession.fromJson(data))
  //             .toList();

  //     var registrationSessionsResponse = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //         "/registrationsessions/${meeting.id}"));

  //     var registrationSessions =
  //         (json.decode(registrationSessionsResponse.body) as List)
  //             .map((data) => RegistrationSession.fromJson(data))
  //             .toList();

  //     var usersResponse = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"));
  //     var users = (json.decode(usersResponse.body) as List)
  //         .map((data) => User.fromJson(data))
  //         .toList();

  //     // delete previous reports directory
  //     if (await Directory(reportDirectory).exists()) {
  //       await Directory(reportDirectory).delete(recursive: true);
  //     }
  //     // create new report directory
  //     await Directory(reportDirectory).create();

  //     // Generate meeting session reports
  //     var meetingSessions = meetingSessionsList
  //         .where((element) => element.meetingId == meeting.id)
  //         .toList();

  //     var meetingNumber = meeting.name.split(' ').first;

  //     for (var i = 0; i < meetingSessions.length; i++) {
  //       var currentRegistrationSessions = <RegistrationSession>[];
  //       for (var j = 0; j < registrationSessions.length; j++) {
  //         if (registrationSessions[j].startDate.microsecondsSinceEpoch >
  //                 meetingSessions[i].startDate.microsecondsSinceEpoch &&
  //             registrationSessions[j].endDate.microsecondsSinceEpoch <
  //                 (meetingSessions[i].endDate?.microsecondsSinceEpoch ??
  //                     TimeUtil.getDateTimeNow(timeOffset)
  //                         .microsecondsSinceEpoch)) {
  //           currentRegistrationSessions.add(registrationSessions[j]);
  //         }
  //       }

  //       var sessionDirectory = reportDirectory +
  //           '/сессия_${DateFormat('HH:mm').format(meetingSessions[i].startDate)}_${meetingSessions[i].endDate == null ? "" : DateFormat('HH:mm').format(meetingSessions[i].endDate)}';
  //       // create new session directory
  //       await Directory(sessionDirectory).create();

  //       for (var j = 0; j < currentRegistrationSessions.length; j++) {
  //         Content registrationContent = Content();
  //         registrationContent
  //           ..add(TextContent("protocol_number", "№${(j + 1)}"))
  //           ..add(TextContent("meeting_name",
  //               "$meetingNumber заседании \r\n Государственного Совета-Хасэ Республики Адыгея"))
  //           ..add(TextContent("time",
  //               "${DateFormat('HH:mm').format(currentRegistrationSessions[j].endDate.toLocal())}"))
  //           ..add(TextContent("date",
  //               "${DateFormat('dd.MM.yyyy').format(currentRegistrationSessions[j].endDate.toLocal())}"))
  //           ..add(TextContent("registered_count",
  //               "${currentRegistrationSessions[j].registrations.length}"))
  //           ..add(TextContent("absent_count",
  //               "${meeting.group.groupUsers.length - currentRegistrationSessions[j].registrations.length}"));

  //         var namedRegistrationList = <RowContent>[];

  //         int index = 0;

  //         for (var groupUser in meeting.group.groupUsers) {
  //           index++;
  //           var user = users.firstWhere(
  //               (element) => element.id == groupUser.user.id,
  //               orElse: () => null);

  //           var isUserRegistred = currentRegistrationSessions[j]
  //               .registrations
  //               .any((element) => element.userId == user?.id);

  //           // add registration row
  //           if (isUserRegistred) {
  //             namedRegistrationList.add(RowContent()
  //               ..add(TextContent("number", "$index."))
  //               ..add(TextContent("fullname", user?.getFullName()))
  //               ..add(TextContent("result", "Зарегистрирован"))
  //               ..add(TextContent("place", "")));
  //           } else {
  //             namedRegistrationList.add(RowContent()
  //               ..add(TextContent("number", "$index."))
  //               ..add(TextContent("fullname", user?.getFullName()))
  //               ..add(TextContent("result", "Не зарегистрирован"))
  //               ..add(TextContent("place", "")));
  //           }
  //         }

  //         registrationContent
  //           ..add(TableContent("table", namedRegistrationList));

  //         // fill registration template
  //         final dataRegistration =
  //             await rootBundle.load('assets/templates/registration.docx');
  //         final bytesRegistration = dataRegistration.buffer.asUint8List();
  //         final docxRegistration =
  //             await DocxTemplate.fromBytes(bytesRegistration);
  //         final docRegistration =
  //             await docxRegistration.generate(registrationContent);
  //         final fileNameRegistration = sessionDirectory +
  //             '/${DateFormat('HHmm').format(currentRegistrationSessions[j].endDate)}_Регистрация_${(j + 1)}.docx';
  //         final fileRegistration = File(fileNameRegistration);
  //         if (docRegistration != null) {
  //           await fileRegistration.writeAsBytes(docRegistration);
  //         }
  //       }

  //       var questionSessionsResponse = await http.get(Uri.http(
  //           ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //           "/questionsessions/${meetingSessions[i].id}"));
  //       var questionSessions =
  //           (json.decode(questionSessionsResponse.body) as List)
  //               .map((data) => QuestionSession.fromJson(data))
  //               .toList();

  //       for (int j = 0; j < questionSessions.length; j++) {
  //         var registrationSession = currentRegistrationSessions.firstWhere(
  //             (element) =>
  //                 element.endDate.microsecondsSinceEpoch <
  //                 questionSessions[j].endDate.microsecondsSinceEpoch,
  //             orElse: () => null);

  //         var question = meeting.agenda.questions.firstWhere(
  //             (element) => element.id == questionSessions[j].questionId,
  //             orElse: () => null);
  //         var votingMode = votingModes.firstWhere(
  //             (element) => element.id == questionSessions[j].votingModeId,
  //             orElse: () => null);

  //         if (registrationSession != null && question != null) {
  //           var sessionEndDate = meetingSessions[i].endDate?.toLocal() ??
  //               TimeUtil.getDateTimeNow(timeOffset);

  //           Content votingCommonContent = Content();
  //           votingCommonContent
  //             ..add(TextContent("protocol_number", "№${(j + 1)}"))
  //             ..add(TextContent("meeting_name",
  //                 "$meetingNumber заседании \r\n Государственного Совета-Хасэ Республики Адыгея"))
  //             ..add(TextContent("question_name", "${question.name}"))
  //             ..add(TextContent(
  //                 "question_description", "${question.getReportDescription()}"))
  //             ..add(TextContent("time",
  //                 "${DateFormat('HH:mm').format(questionSessions[j].endDate.toLocal())}"))
  //             ..add(TextContent("date",
  //                 "${DateFormat('dd.MM.yyyy').format(questionSessions[j].endDate.toLocal())}"))
  //             ..add(TextContent(
  //                 "voting_mode", "${votingMode.name.toUpperCase()}"))
  //             ..add(TextContent("registered_count",
  //                 "${registrationSession.registrations.length}"))
  //             ..add(TextContent("proxy_count",
  //                 "${questionSessions[j].results.where((element) => element.proxyId != null).length}"))
  //             ..add(TextContent("voted_yes_count",
  //                 "${questionSessions[j].usersCountVotedYes}"))
  //             ..add(TextContent("voted_yes_percent",
  //                 "${((100 * questionSessions[j].usersCountVotedYes) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //             ..add(TextContent(
  //                 "voted_no_count", "${questionSessions[j].usersCountVotedNo}"))
  //             ..add(TextContent("voted_no_percent",
  //                 "${((100 * questionSessions[j].usersCountVotedNo) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //             ..add(TextContent("voted_indifferent_count",
  //                 "${questionSessions[j].usersCountVotedIndiffirent}"))
  //             ..add(TextContent("voted_indifferent_percent",
  //                 "${((100 * questionSessions[j].usersCountVotedIndiffirent) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //             ..add(TextContent(
  //                 "decision",
  //                 questionSessions[j].usersCountVotedYes >=
  //                         questionSessions[j].usersCountForSuccess
  //                     ? "ПРИНЯТО"
  //                     : "НЕ ПРИНЯТО"))
  //             ..add(TextContent(
  //                 "voted_count",
  //                 settings.votingSettings.isCountNotVotingAsIndifferent
  //                     ? "${meeting.group.chosenCount}"
  //                     : "${questionSessions[j].results.length}"))
  //             ..add(TextContent("not_voted_count",
  //                 "${meeting.group.chosenCount - questionSessions[j].results.length}"));

  //           Content votingNamedContent = Content();
  //           votingNamedContent
  //             ..add(TextContent("protocol_number", "№${(j + 1)}"));

  //           var namedVotingList = <RowContent>[];

  //           int index = 0;

  //           for (var groupUser in meeting.group.groupUsers) {
  //             index++;
  //             var user = users.firstWhere(
  //                 (element) => element.id == groupUser.user.id,
  //                 orElse: () => null);
  //             var result = questionSessions[j].results.firstWhere(
  //                 (element) => element.userId == groupUser.user.id,
  //                 orElse: () => null);

  //             var isUserRegistred = registrationSession.registrations
  //                 .any((element) => element.userId == user?.id);

  //             // add named voting row
  //             if (result?.result == 'ЗА') {
  //               namedVotingList.add(RowContent()
  //                 ..add(TextContent("number", "$index."))
  //                 ..add(TextContent("fullname", user?.getFullName()))
  //                 ..add(TextContent("result", "ЗА"))
  //                 ..add(TextContent("place", "")));
  //             } else if (result?.result == 'ПРОТИВ') {
  //               namedVotingList.add(RowContent()
  //                 ..add(TextContent("number", "$index."))
  //                 ..add(TextContent("fullname", user?.getFullName()))
  //                 ..add(TextContent("result", "ПРОТИВ"))
  //                 ..add(TextContent("place", "")));
  //             } else if (result?.result == 'ВОЗДЕРЖАЛСЯ' ||
  //                 settings.votingSettings.isCountNotVotingAsIndifferent) {
  //               namedVotingList.add(RowContent()
  //                 ..add(TextContent("number", "$index."))
  //                 ..add(TextContent("fullname", user?.getFullName()))
  //                 ..add(TextContent("result", "ВОЗДЕРЖАЛСЯ"))
  //                 ..add(TextContent("place", "")));
  //             } else {
  //               if (isUserRegistred) {
  //                 namedVotingList.add(RowContent()
  //                   ..add(TextContent("number", "$index."))
  //                   ..add(TextContent("fullname", user?.getFullName()))
  //                   ..add(TextContent("result", "Не голосовал"))
  //                   ..add(TextContent("place", "")));
  //               } else {
  //                 namedVotingList.add(RowContent()
  //                   ..add(TextContent("number", "$index."))
  //                   ..add(TextContent("fullname", user?.getFullName()))
  //                   ..add(TextContent("result", "Не зарегистрирован"))
  //                   ..add(TextContent("place", "")));
  //               }
  //             }
  //           }

  //           votingNamedContent..add(TableContent("table", namedVotingList));

  //           // fill voting common template
  //           final dataCommon =
  //               await rootBundle.load('assets/templates/votingCommon.docx');
  //           final bytesCommon = dataCommon.buffer.asUint8List();
  //           final docxCommon = await DocxTemplate.fromBytes(bytesCommon);
  //           final docCommon = await docxCommon.generate(votingCommonContent);
  //           final fileNameCommon = sessionDirectory +
  //               '/${DateFormat('HHmm').format(sessionEndDate)}_Голосование_${(j + 1)}.docx';
  //           final fileCommon = File(fileNameCommon);
  //           if (docCommon != null) {
  //             await fileCommon.writeAsBytes(docCommon);
  //           }

  //           // fill voting named template
  //           final dataNamed =
  //               await rootBundle.load('assets/templates/votingNamed.docx');
  //           final bytesNamed = dataNamed.buffer.asUint8List();
  //           final docxNamed = await DocxTemplate.fromBytes(bytesNamed);
  //           final docNamed = await docxNamed.generate(votingNamedContent);
  //           final fileNameNamed = sessionDirectory +
  //               '/${DateFormat('HHmm').format(sessionEndDate)}_Поименно_${(j + 1)}.docx';
  //           final fileNamed = File(fileNameNamed);
  //           if (docNamed != null) {
  //             await fileNamed.writeAsBytes(docNamed);
  //           }
  //         }
  //       }

  //       isReportCompleted = true;
  //     }
  //   } catch (exc) {
  //     isReportCompleted = false;
  //     Utility().showMessageOkDialog(context,
  //         title: 'Ошибка экспорта протокола',
  //         message: TextSpan(
  //           text:
  //               'В ходе экспорта протокола возникла ошибка: ${exc.toString()}',
  //         ),
  //         okButtonText: 'Ок');
  //   } finally {
  //     if (isReportCompleted == true) {
  //       Utility().showMessageOkDialog(context,
  //           title: 'Экспорт протокола',
  //           message: TextSpan(
  //             text:
  //                 'Экспорт протокола успешно завершен.\r\nДиректория отчета: $reportDirectory',
  //           ),
  //           okButtonText: 'Ок');
  //     }
  //   }
  // }

  // // Novgorod
  // Future<void> getMeetingReport(
  //   BuildContext context,
  //   Meeting meeting,
  //   Settings settings,
  //   int timeOffset,
  //   List<VotingMode> votingModes,
  // ) async {
  //   var isReportCompleted = false;
  //   var reportDirectory =
  //       settings.questionListSettings.reportsFolderPath + '/' + meeting.name;
  //   try {
  //     var meetingSessionsResponce = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //         "/meeting_sessions"));

  //     List<MeetingSession> meetingSessionsList =
  //         (json.decode(meetingSessionsResponce.body) as List)
  //             .map((data) => MeetingSession.fromJson(data))
  //             .toList();

  //     var registrationSessionsResponse = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //         "/registrationsessions/${meeting.id}"));

  //     var registrationSessions =
  //         (json.decode(registrationSessionsResponse.body) as List)
  //             .map((data) => RegistrationSession.fromJson(data))
  //             .toList();

  //     var usersResponse = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"));
  //     var users = (json.decode(usersResponse.body) as List)
  //         .map((data) => User.fromJson(data))
  //         .toList();

  //     // delete previous reports directory
  //     if (await Directory(reportDirectory).exists()) {
  //       await Directory(reportDirectory).delete(recursive: true);
  //     }
  //     // create new report directory
  //     await Directory(reportDirectory).create();

  //     // Generate meeting session reports
  //     var meetingSessions = meetingSessionsList
  //         .where((element) => element.meetingId == meeting.id)
  //         .toList();

  //     var meetingNumber = meeting.name.split(' ').first;

  //     for (var i = 0; i < meetingSessions.length; i++) {
  //       var currentRegistrationSessions = <RegistrationSession>[];
  //       for (var j = 0; j < registrationSessions.length; j++) {
  //         if (registrationSessions[j].startDate.microsecondsSinceEpoch >
  //                 meetingSessions[i].startDate.microsecondsSinceEpoch &&
  //             registrationSessions[j].endDate.microsecondsSinceEpoch <
  //                 (meetingSessions[i].endDate?.microsecondsSinceEpoch ??
  //                     TimeUtil.getDateTimeNow(timeOffset)
  //                         .microsecondsSinceEpoch)) {
  //           currentRegistrationSessions.add(registrationSessions[j]);
  //         }
  //       }

  //       var sessionDirectory = reportDirectory +
  //           '/сессия_${DateFormat('HH:mm').format(meetingSessions[i].startDate)}_${meetingSessions[i].endDate == null ? "" : DateFormat('HH:mm').format(meetingSessions[i].endDate)}';
  //       // create new session directory
  //       await Directory(sessionDirectory).create();

  //       for (var j = 0; j < currentRegistrationSessions.length; j++) {
  //         Content registrationContent = Content();
  //         registrationContent
  //           ..add(TextContent("protocol_number", "№${(j + 1)}"))
  //           ..add(TextContent("meeting_name",
  //               "$meetingNumber заседании \r\n Государственного Совета-Хасэ Республики Адыгея"))
  //           ..add(TextContent("time",
  //               "${DateFormat('HH:mm').format(currentRegistrationSessions[j].endDate.toLocal())}"))
  //           ..add(TextContent("date",
  //               "${DateFormat('dd.MM.yyyy').format(currentRegistrationSessions[j].endDate.toLocal())}"))
  //           ..add(TextContent("registered_count",
  //               "${currentRegistrationSessions[j].registrations.length}"))
  //           ..add(TextContent("absent_count",
  //               "${meeting.group.groupUsers.length - currentRegistrationSessions[j].registrations.length}"));

  //         var namedRegistrationList = <RowContent>[];

  //         int index = 0;

  //         for (var groupUser in meeting.group.groupUsers) {
  //           index++;
  //           var user = users.firstWhere(
  //               (element) => element.id == groupUser.user.id,
  //               orElse: () => null);

  //           var isUserRegistred = currentRegistrationSessions[j]
  //               .registrations
  //               .any((element) => element.userId == user?.id);

  //           // add registration row
  //           if (isUserRegistred) {
  //             namedRegistrationList.add(RowContent()
  //               ..add(TextContent("number", "$index."))
  //               ..add(TextContent("fullname", user?.getFullName()))
  //               ..add(TextContent("result", "Зарегистрирован"))
  //               ..add(TextContent("place", "")));
  //           } else {
  //             namedRegistrationList.add(RowContent()
  //               ..add(TextContent("number", "$index."))
  //               ..add(TextContent("fullname", user?.getFullName()))
  //               ..add(TextContent("result", "Не зарегистрирован"))
  //               ..add(TextContent("place", "")));
  //           }
  //         }

  //         registrationContent
  //           ..add(TableContent("table", namedRegistrationList));

  //         // fill registration template
  //         final dataRegistration =
  //             await rootBundle.load('assets/templates/registration.docx');
  //         final bytesRegistration = dataRegistration.buffer.asUint8List();
  //         final docxRegistration =
  //             await DocxTemplate.fromBytes(bytesRegistration);
  //         final docRegistration =
  //             await docxRegistration.generate(registrationContent);
  //         final fileNameRegistration = sessionDirectory +
  //             '/${DateFormat('HHmm').format(currentRegistrationSessions[j].endDate)}_Регистрация_${(j + 1)}.docx';
  //         final fileRegistration = File(fileNameRegistration);
  //         if (docRegistration != null) {
  //           await fileRegistration.writeAsBytes(docRegistration);
  //         }
  //       }

  //       var questionSessionsResponse = await http.get(Uri.http(
  //           ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //           "/questionsessions/${meetingSessions[i].id}"));
  //       var questionSessions =
  //           (json.decode(questionSessionsResponse.body) as List)
  //               .map((data) => QuestionSession.fromJson(data))
  //               .toList();

  //       for (int j = 0; j < questionSessions.length; j++) {
  //         var registrationSession = currentRegistrationSessions.firstWhere(
  //             (element) =>
  //                 element.endDate.microsecondsSinceEpoch <
  //                 questionSessions[j].endDate.microsecondsSinceEpoch,
  //             orElse: () => null);

  //         var question = meeting.agenda.questions.firstWhere(
  //             (element) => element.id == questionSessions[j].questionId,
  //             orElse: () => null);
  //         var votingMode = votingModes.firstWhere(
  //             (element) => element.id == questionSessions[j].votingModeId,
  //             orElse: () => null);

  //         if (registrationSession != null && question != null) {
  //           var sessionEndDate = meetingSessions[i].endDate?.toLocal() ??
  //               TimeUtil.getDateTimeNow(timeOffset);

  //           Content votingCommonContent = Content();
  //           votingCommonContent
  //             ..add(TextContent("protocol_number", "№${(j + 1)}"))
  //             ..add(TextContent("meeting_name",
  //                 "$meetingNumber заседании \r\n Государственного Совета-Хасэ Республики Адыгея"))
  //             ..add(TextContent("question_name", "${question.name}"))
  //             ..add(TextContent(
  //                 "question_description", "${question.getReportDescription()}"))
  //             ..add(TextContent("time",
  //                 "${DateFormat('HH:mm').format(questionSessions[j].endDate.toLocal())}"))
  //             ..add(TextContent("date",
  //                 "${DateFormat('dd.MM.yyyy').format(questionSessions[j].endDate.toLocal())}"))
  //             ..add(TextContent(
  //                 "voting_mode", "${votingMode.name.toUpperCase()}"))
  //             ..add(TextContent("registered_count",
  //                 "${registrationSession.registrations.length}"))
  //             ..add(TextContent("proxy_count",
  //                 "${questionSessions[j].results.where((element) => element.proxyId != null).length}"))
  //             ..add(TextContent("voted_yes_count",
  //                 "${questionSessions[j].usersCountVotedYes}"))
  //             ..add(TextContent("voted_yes_percent",
  //                 "${((100 * questionSessions[j].usersCountVotedYes) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //             ..add(TextContent(
  //                 "voted_no_count", "${questionSessions[j].usersCountVotedNo}"))
  //             ..add(TextContent("voted_no_percent",
  //                 "${((100 * questionSessions[j].usersCountVotedNo) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //             ..add(TextContent("voted_indifferent_count",
  //                 "${questionSessions[j].usersCountVotedIndiffirent}"))
  //             ..add(TextContent("voted_indifferent_percent",
  //                 "${((100 * questionSessions[j].usersCountVotedIndiffirent) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //             ..add(TextContent(
  //                 "decision",
  //                 questionSessions[j].usersCountVotedYes >=
  //                         questionSessions[j].usersCountForSuccess
  //                     ? "ПРИНЯТО"
  //                     : "НЕ ПРИНЯТО"))
  //             ..add(TextContent(
  //                 "voted_count",
  //                 settings.votingSettings.isCountNotVotingAsIndifferent
  //                     ? "${meeting.group.chosenCount}"
  //                     : "${questionSessions[j].results.length}"))
  //             ..add(TextContent("not_voted_count",
  //                 "${meeting.group.chosenCount - questionSessions[j].results.length}"));

  //           Content votingNamedContent = Content();
  //           votingNamedContent
  //             ..add(TextContent("protocol_number", "№${(j + 1)}"));

  //           var namedVotingList = <RowContent>[];

  //           int index = 0;

  //           for (var groupUser in meeting.group.groupUsers) {
  //             index++;
  //             var user = users.firstWhere(
  //                 (element) => element.id == groupUser.user.id,
  //                 orElse: () => null);
  //             var result = questionSessions[j].results.firstWhere(
  //                 (element) => element.userId == groupUser.user.id,
  //                 orElse: () => null);

  //             var isUserRegistred = registrationSession.registrations
  //                 .any((element) => element.userId == user?.id);

  //             // add named voting row
  //             if (result?.result == 'ЗА') {
  //               namedVotingList.add(RowContent()
  //                 ..add(TextContent("number", "$index."))
  //                 ..add(TextContent("fullname", user?.getFullName()))
  //                 ..add(TextContent("result", "ЗА"))
  //                 ..add(TextContent("place", "")));
  //             } else if (result?.result == 'ПРОТИВ') {
  //               namedVotingList.add(RowContent()
  //                 ..add(TextContent("number", "$index."))
  //                 ..add(TextContent("fullname", user?.getFullName()))
  //                 ..add(TextContent("result", "ПРОТИВ"))
  //                 ..add(TextContent("place", "")));
  //             } else if (result?.result == 'ВОЗДЕРЖАЛСЯ' ||
  //                 settings.votingSettings.isCountNotVotingAsIndifferent) {
  //               namedVotingList.add(RowContent()
  //                 ..add(TextContent("number", "$index."))
  //                 ..add(TextContent("fullname", user?.getFullName()))
  //                 ..add(TextContent("result", "ВОЗДЕРЖАЛСЯ"))
  //                 ..add(TextContent("place", "")));
  //             } else {
  //               if (isUserRegistred) {
  //                 namedVotingList.add(RowContent()
  //                   ..add(TextContent("number", "$index."))
  //                   ..add(TextContent("fullname", user?.getFullName()))
  //                   ..add(TextContent("result", "Не голосовал"))
  //                   ..add(TextContent("place", "")));
  //               } else {
  //                 namedVotingList.add(RowContent()
  //                   ..add(TextContent("number", "$index."))
  //                   ..add(TextContent("fullname", user?.getFullName()))
  //                   ..add(TextContent("result", "Не зарегистрирован"))
  //                   ..add(TextContent("place", "")));
  //               }
  //             }
  //           }

  //           votingNamedContent..add(TableContent("table", namedVotingList));

  //           // fill voting common template
  //           final dataCommon =
  //               await rootBundle.load('assets/templates/votingCommon.docx');
  //           final bytesCommon = dataCommon.buffer.asUint8List();
  //           final docxCommon = await DocxTemplate.fromBytes(bytesCommon);
  //           final docCommon = await docxCommon.generate(votingCommonContent);
  //           final fileNameCommon = sessionDirectory +
  //               '/${DateFormat('HHmm').format(sessionEndDate)}_Голосование_${(j + 1)}.docx';
  //           final fileCommon = File(fileNameCommon);
  //           if (docCommon != null) {
  //             await fileCommon.writeAsBytes(docCommon);
  //           }

  //           // fill voting named template
  //           final dataNamed =
  //               await rootBundle.load('assets/templates/votingNamed.docx');
  //           final bytesNamed = dataNamed.buffer.asUint8List();
  //           final docxNamed = await DocxTemplate.fromBytes(bytesNamed);
  //           final docNamed = await docxNamed.generate(votingNamedContent);
  //           final fileNameNamed = sessionDirectory +
  //               '/${DateFormat('HHmm').format(sessionEndDate)}_Поименно_${(j + 1)}.docx';
  //           final fileNamed = File(fileNameNamed);
  //           if (docNamed != null) {
  //             await fileNamed.writeAsBytes(docNamed);
  //           }
  //         }
  //       }

  //       isReportCompleted = true;
  //     }
  //   } catch (exc) {
  //     isReportCompleted = false;
  //     Utility().showMessageOkDialog(context,
  //         title: 'Ошибка экспорта протокола',
  //         message: TextSpan(
  //           text:
  //               'В ходе экспорта протокола возникла ошибка: ${exc.toString()}',
  //         ),
  //         okButtonText: 'Ок');
  //   } finally {
  //     if (isReportCompleted == true) {
  //       Utility().showMessageOkDialog(context,
  //           title: 'Экспорт протокола',
  //           message: TextSpan(
  //             text:
  //                 'Экспорт протокола успешно завершен.\r\nДиректория отчета: $reportDirectory',
  //           ),
  //           okButtonText: 'Ок');
  //     }
  //   }
  // }

  // // Adygea
  // Future<void> getRegistrationReport(
  //   Meeting meeting,
  //   Settings settings,
  //   List<User> users,
  //   WebSocketConnection connection,
  //   int timeOffset,
  // ) async {
  //   var registrationSession = connection.getServerState.registrationSession;

  //   var meetingSessionsResponce = await http.get(Uri.http(
  //       ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //       "/meeting_sessions"));

  //   List<MeetingSession> meetingSessionsList =
  //       (json.decode(meetingSessionsResponce.body) as List)
  //           .map((data) => MeetingSession.fromJson(data))
  //           .toList()
  //           .where((element) => element.meetingId == meeting.id)
  //           .toList();

  //   var meetingNumber = meeting.name.split(' ').first;

  //   var registrationSessionsResponse = await http.get(Uri.http(
  //       ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //       "/registrationsessions/${meeting.id}"));

  //   var registrationSessions =
  //       (json.decode(registrationSessionsResponse.body) as List)
  //           .map((data) => RegistrationSession.fromJson(data))
  //           .toList();

  //   var currentRegistrationSessions = <RegistrationSession>[];
  //   for (var j = 0; j < registrationSessions.length; j++) {
  //     if (registrationSessions[j].startDate.microsecondsSinceEpoch >
  //             meetingSessionsList.last.startDate.microsecondsSinceEpoch &&
  //         registrationSessions[j].endDate.microsecondsSinceEpoch <
  //             (meetingSessionsList.last.endDate?.microsecondsSinceEpoch ??
  //                 TimeUtil.getDateTimeNow(timeOffset).microsecondsSinceEpoch)) {
  //       currentRegistrationSessions.add(registrationSessions[j]);
  //     }
  //   }

  //   var registrationSessionIndex = currentRegistrationSessions.indexOf(
  //       currentRegistrationSessions.firstWhere(
  //           (element) => element.id == registrationSession.id,
  //           orElse: () => null));

  //   Content registrationContent = Content();
  //   registrationContent
  //     ..add(
  //         TextContent("protocol_number", "№${(registrationSessionIndex + 1)}"))
  //     ..add(TextContent("meeting_name",
  //         "$meetingNumber заседании \r\n Государственного Совета-Хасэ Республики Адыгея"))
  //     ..add(TextContent("time",
  //         "${DateFormat('HH:mm').format(registrationSession.endDate.toLocal())}"))
  //     ..add(TextContent("date",
  //         "${DateFormat('dd.MM.yyyy').format(registrationSession.endDate.toLocal())}"))
  //     ..add(TextContent("registered_count",
  //         "${connection.getServerState.usersRegistered.length}"))
  //     ..add(TextContent("absent_count",
  //         "${meeting.group.groupUsers.length - connection.getServerState.usersRegistered.length}"));

  //   var namedRegistrationList = <RowContent>[];

  //   int index = 0;

  //   for (var groupUser in meeting.group.groupUsers) {
  //     index++;
  //     var user = users.firstWhere((element) => element.id == groupUser.user.id,
  //         orElse: () => null);

  //     var isUserRegistred =
  //         connection.getServerState.usersRegistered.contains(user?.id);

  //     // add registration row
  //     if (isUserRegistred) {
  //       namedRegistrationList.add(RowContent()
  //         ..add(TextContent("number", "$index."))
  //         ..add(TextContent("fullname", user?.getFullName()))
  //         ..add(TextContent("result", "Зарегистрирован"))
  //         ..add(TextContent("place", "")));
  //     } else {
  //       namedRegistrationList.add(RowContent()
  //         ..add(TextContent("number", "$index."))
  //         ..add(TextContent("fullname", user?.getFullName()))
  //         ..add(TextContent("result", "Не зарегистрирован"))
  //         ..add(TextContent("place", "")));
  //     }
  //   }

  //   registrationContent..add(TableContent("table", namedRegistrationList));

  //   // fill registration template
  //   final dataRegistration =
  //       await rootBundle.load('assets/templates/registration.docx');
  //   final bytesRegistration = dataRegistration.buffer.asUint8List();
  //   final docxRegistration = await DocxTemplate.fromBytes(bytesRegistration);
  //   final docRegistration =
  //       await docxRegistration.generate(registrationContent);
  //   var reportDirectory =
  //       settings.questionListSettings.reportsFolderPath + '/' + meeting.name;
  //   // create reports directory if not exists
  //   if (!await Directory(reportDirectory).exists()) {
  //     await Directory(reportDirectory).create();
  //   }
  //   final fileNameRegistration = reportDirectory +
  //       '/${DateFormat('HHmm').format(registrationSession.endDate)}_Регистрация_${(registrationSessionIndex + 1)}.docx';
  //   final fileRegistration = File(fileNameRegistration);
  //   if (docRegistration != null) {
  //     await fileRegistration.writeAsBytes(docRegistration);
  //   }

  //   // print report
  //   await Process.run('unoconv', <String>[
  //     '-f',
  //     'pdf',
  //     '--export=ExportFormFields=false',
  //     '$fileNameRegistration'
  //   ]);
  //   var fileToPrint = fileNameRegistration.replaceAll('.docx', '.pdf');
  //   Process.run('lp', <String>[fileToPrint]);
  // }

  // // Adygea
  // Future<void> getVotingCommonReport(
  //   Meeting meeting,
  //   Settings settings,
  //   VotingMode votingMode,
  //   List<User> users,
  //   List<int> usersRegistered,
  //   Question question,
  //   QuestionSession questionSession,
  //   MeetingSession meetingSession,
  //   int timeOffset,
  // ) async {
  //   var currentMeetingSession = meetingSession;

  //   if (currentMeetingSession == null) {
  //     var meetingSessionsResponce = await http.get(Uri.http(
  //         ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //         "/meeting_sessions"));

  //     List<MeetingSession> meetingSessionsList =
  //         (json.decode(meetingSessionsResponce.body) as List)
  //             .map((data) => MeetingSession.fromJson(data))
  //             .toList()
  //             .where((element) => element.meetingId == meeting.id)
  //             .toList();
  //     currentMeetingSession = meetingSessionsList.last;
  //   }

  //   var currentQuestionSession = questionSession;

  //   var questionSessionsResponse = await http.get(Uri.http(
  //       ServerConnection.getHttpServerUrl(GlobalConfiguration()),
  //       "/questionsessions/${currentMeetingSession.id}"));
  //   var questionSessions = (json.decode(questionSessionsResponse.body) as List)
  //       .map((data) => QuestionSession.fromJson(data))
  //       .toList();

  //   if (currentQuestionSession == null) {
  //     if (questionSessions.length == 0) {
  //       return;
  //     }

  //     currentQuestionSession = questionSessions.last;
  //   }

  //   var meetingNumber = meeting.name.split(' ').first;
  //   var sessionIndex = questionSessions.indexOf(questionSessions.firstWhere(
  //     (element) => element.id == currentQuestionSession.id,
  //     orElse: () => null,
  //   ));

  //   Content votingCommonContent = Content();
  //   votingCommonContent
  //     ..add(TextContent("protocol_number", "№${(sessionIndex + 1)}"))
  //     ..add(TextContent("meeting_name",
  //         "$meetingNumber заседании \r\n Государственного Совета-Хасэ Республики Адыгея"))
  //     ..add(TextContent("question_name", "${question.name}"))
  //     ..add(TextContent(
  //         "question_description", "${question.getReportDescription()}"))
  //     ..add(TextContent("time",
  //         "${DateFormat('HH:mm').format(currentQuestionSession.endDate.toLocal())}"))
  //     ..add(TextContent("date",
  //         "${DateFormat('dd.MM.yyyy').format(currentQuestionSession.endDate.toLocal())}"))
  //     ..add(TextContent("voting_mode", "${votingMode.name.toUpperCase()}"))
  //     ..add(TextContent("registered_count", "${usersRegistered.length}"))
  //     ..add(TextContent("proxy_count",
  //         "${currentQuestionSession.results.where((element) => element.proxyId != null).length}"))
  //     ..add(TextContent(
  //         "voted_yes_count", "${currentQuestionSession.usersCountVotedYes}"))
  //     ..add(TextContent("voted_yes_percent",
  //         "${((100 * currentQuestionSession.usersCountVotedYes) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //     ..add(TextContent(
  //         "voted_no_count", "${currentQuestionSession.usersCountVotedNo}"))
  //     ..add(TextContent("voted_no_percent",
  //         "${((100 * currentQuestionSession.usersCountVotedNo) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //     ..add(TextContent("voted_indifferent_count",
  //         "${currentQuestionSession.usersCountVotedIndiffirent}"))
  //     ..add(TextContent("voted_indifferent_percent",
  //         "${((100 * currentQuestionSession.usersCountVotedIndiffirent) / meeting.group.chosenCount).toStringAsFixed(1)}%"))
  //     ..add(TextContent(
  //         "decision",
  //         currentQuestionSession.usersCountVotedYes >=
  //                 currentQuestionSession.usersCountForSuccess
  //             ? "ПРИНЯТО"
  //             : "НЕ ПРИНЯТО"))
  //     ..add(TextContent(
  //         "voted_count",
  //         settings.votingSettings.isCountNotVotingAsIndifferent
  //             ? "${meeting.group.chosenCount}"
  //             : "${currentQuestionSession.results.length}"))
  //     ..add(TextContent("not_voted_count",
  //         "${meeting.group.chosenCount - currentQuestionSession.results.length}"));

  //   // fill voting common template
  //   final dataCommon =
  //       await rootBundle.load('assets/templates/votingCommon.docx');
  //   final bytesCommon = dataCommon.buffer.asUint8List();
  //   final docxCommon = await DocxTemplate.fromBytes(bytesCommon);
  //   final docCommon = await docxCommon.generate(votingCommonContent);
  //   var reportDirectory =
  //       settings.questionListSettings.reportsFolderPath + '/' + meeting.name;
  //   // create reports directory if not exists
  //   if (!await Directory(reportDirectory).exists()) {
  //     await Directory(reportDirectory).create();
  //   }
  //   final fileNameCommon = reportDirectory +
  //       '/${DateFormat('HHmm').format(currentQuestionSession.endDate)}_Голосование_${(sessionIndex + 1)}.docx';
  //   final fileCommon = File(fileNameCommon);
  //   if (docCommon != null) {
  //     await fileCommon.writeAsBytes(docCommon);
  //   }

  //   // print report
  //   await Process.run('unoconv', <String>[
  //     '-f',
  //     'pdf',
  //     '--export=ExportFormFields=false',
  //     '$fileNameCommon'
  //   ]);
  //   var fileToPrint = fileNameCommon.replaceAll('.docx', '.pdf');
  //   Process.run('lp', <String>[fileToPrint]);
  // }
}
