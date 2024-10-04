import 'package:ais_model/ais_model.dart';

class AgendaListUtil {
  static int getQuestionNumber(
      int index, List<String> questions, QuestionListSettings settings) {
    RegExp regExp = new RegExp(
        r'("[^"]*"),("?[^"]+"?),("[^"]*"),("[^"]*"),("[^"]*"),("[^"]*"),("[^"]*")');

    var additionalQuestionCount = questions
        .sublist(0, index)
        .where((element) =>
            (regExp.firstMatch(element)?.group(2)?.contains(' д') == true))
        .length;
    if (regExp.firstMatch(questions[index])?.group(3) ==
        settings.additionalQiestion.defaultGroupName) {
      return additionalQuestionCount + 1;
    }

    return index - additionalQuestionCount;
  }

  static String getFileName(String folder, int fileIndex) {
    if (folder.contains('д')) {
      return "Вопрос${folder.replaceFirst(' ', '')}_файл${(fileIndex).toString().padLeft(2, '0')}.pdf";
    }
    return "Вопрос${folder.toString().padLeft(2, '0')}_файл${(fileIndex).toString().padLeft(2, '0')}.pdf";
  }
}
