import 'dart:convert';
import 'dart:io';
import 'package:ais_utils/agenda_util.dart';
import 'package:ais_utils/dialogs.dart';
import 'package:charset/charset.dart';
import 'package:csv/csv.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ais_model/ais_model.dart';
import 'package:uuid/uuid.dart';

class AgendaListUtil {
  static const String fileExtension = 'txt';
  static final RegExp fileNameTrimmer = RegExp('');
  static List<dynamic> firstRow = <String>[];

  static String _agendaFilePath = '';

  static final QuestionListSettings settings = QuestionListSettings();
  static List<Question> questions = <Question>[];
  static Question _newQuestionStub = Question();

  static late BuildContext _context;
  static late Function _setState;

  static init(BuildContext context, Function setState) {
    _context = context;
    _setState = setState;

    //init settings
    settings.firstQuestion.defaultGroupName = 'Повестка';
    settings.firstQuestion.descriptionCaption1 = 'Содержание вопроса';
    settings.firstQuestion.descriptionCaption2 = 'Кто вносит';
    settings.firstQuestion.descriptionCaption3 = 'Докладчики';
    settings.firstQuestion.descriptionCaption4 = 'Ответственный за подготовку';

    settings.mainQuestion.defaultGroupName = 'Вопрос';
    settings.mainQuestion.descriptionCaption1 = 'Содержание вопроса';
    settings.mainQuestion.descriptionCaption2 = 'Кто вносит';
    settings.mainQuestion.descriptionCaption3 = 'Докладчики';
    settings.mainQuestion.descriptionCaption4 = 'Ответственный за подготовку';

    settings.additionalQiestion.defaultGroupName = 'Доп. вопрос';
    settings.additionalQiestion.descriptionCaption1 = 'Содержание вопроса';
    settings.additionalQiestion.descriptionCaption2 = 'Кто вносит';
    settings.additionalQiestion.descriptionCaption3 = 'Докладчики';
    settings.additionalQiestion.descriptionCaption4 =
        'Ответственный за подготовку';

    // init new question stub
    _newQuestionStub = Question(
        name: 'Новый вопрос',
        descriptions: createQuestionDescription(settings.mainQuestion));
  }

  DragAndDropItem getNewQuestionDrugAndDropStub() {
    return DragAndDropItem(
      child: Column(children: [
        Container(
          height: 6,
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.fromLTRB(40, 0, 0, 0),
          child: Text(
            _newQuestionStub.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 6,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 55,
          margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: AgendaUtil.getQuestionDescriptionText(
            _newQuestionStub,
            14,
            isAutoSize: true,
            textAlign: TextAlign.left,
            showHiddenSections: true,
          ),
        ),
      ]),
    );
  }

  static void loadCsvQuestions(String agendaFilePath) {
    _agendaFilePath = agendaFilePath;

    if (_agendaFilePath.isEmpty) {
      questions = <Question>[];
      return;
    }

    final agendaFile = File(_agendaFilePath);

    // Получаем папки с документами
    var documentFolders = <Directory>[];
    for (var fileOrDir in agendaFile.parent.listSync()) {
      if (fileOrDir is Directory) {
        documentFolders.add(fileOrDir);
      }
    }
    var agenFileBytes = agendaFile.readAsBytesSync();
    var agendaFileContent =
        String.fromCharCodes(agenFileBytes.buffer.asUint16List());

    List<List<dynamic>> tableQuestions = const CsvToListConverter().convert(
      agendaFileContent,
      fieldDelimiter: ',',
      eol: '\r\n',
    );
    var agendaQuestions = <Question>[];

    for (int i = 0; i < tableQuestions.length; i++) {
      if (i == 0) {
        firstRow = tableQuestions[i];
        continue;
      }

      // Вычисляем порядковый номер вопроса
      var questionOrder = i - 1;

      // Загружаем описание вопроса
      var tableQuestion = tableQuestions[i];
      var questionDescriptions = <QuestionDescriptionItem>[];
      for (int j = 0; j < tableQuestion.length; j++) {
        if (j == 0 || j == 1 || j == 2 || questionDescriptions.length >= 4) {
          continue;
        }

        var descriptionItem = QuestionDescriptionItem(
            caption: (tableQuestions[0].length > j
                    ? tableQuestions[0][j]
                    : createQuestionDescription(
                            settings.mainQuestion)[questionDescriptions.length]
                        .caption) +
                ':',
            text: tableQuestion[j].toString(),
            showInReports: true,
            showOnStoreboard: true);
        questionDescriptions.add(descriptionItem);
      }

      // Загружаем файлы вопроса
      var questionFiles = <QuestionFile>[];
      var documentFolderContents = <FileSystemEntity>[];
      Directory documentFolder = Directory('');

      var folderName = tableQuestion[1].toString();

      if (documentFolders.any(
          (element) => path.basename(element.path) == folderName.toString())) {
        documentFolder = documentFolders.firstWhere(
            (element) => path.basename(element.path) == folderName.toString());

        documentFolderContents = documentFolder.listSync();
        documentFolderContents.sort((a, b) => a.path.compareTo(b.path));
      }

      // Загружаем описания файлов вопросов
      Map<String, dynamic> filesDescriptions = <String, dynamic>{};
      if (documentFolderContents
          .any((element) => path.basename(element.path) == 'Описание.txt')) {
        FileSystemEntity descriptionFile = documentFolderContents.firstWhere(
            (element) => path.basename(element.path) == 'Описание.txt');

        var descriptionsBytes = File(descriptionFile.path).readAsBytesSync();
        var descriptionsFileContent =
            String.fromCharCodes(descriptionsBytes.buffer.asUint16List());
        Map<String, dynamic> filesDescriptions =
            json.decode(descriptionsFileContent.substring(1));
      }

      for (var fileOrDir in documentFolderContents) {
        if (fileOrDir is File && path.extension(fileOrDir.path) == '.pdf') {
          String fileDescription =
              filesDescriptions[path.basename(fileOrDir.path)] ??
                  path.basenameWithoutExtension(fileOrDir.path);

          if (fileDescription.startsWith(fileNameTrimmer)) {
            fileDescription = fileDescription.replaceFirst(fileNameTrimmer, '');
          }

          var questionFile = QuestionFile(
            realPath: path.dirname(fileOrDir.path),
            fileName: path.basename(fileOrDir.path),
            version: Uuid().v4(),
            description: fileDescription,
          );
          questionFiles.add(questionFile);
        }
      }

      // Создаем вопрос
      var question = Question(
        id: int.parse(folderName.replaceAll(' д', '')),
        name: int.tryParse(tableQuestion[1].toString()) == null
            ? settings.additionalQiestion.defaultGroupName
            : questionOrder == 0
                ? settings.firstQuestion.defaultGroupName
                : settings.mainQuestion.defaultGroupName,
        folder: folderName,
        orderNum: questionOrder,
        descriptions: questionDescriptions,
        files: questionFiles,
      );

      agendaQuestions.add(question);
    }

    if (firstRow.length > 4) {
      settings.firstQuestion.descriptionCaption1 = firstRow[1];
      settings.mainQuestion.descriptionCaption1 = firstRow[1];
      settings.additionalQiestion.descriptionCaption1 = firstRow[1];

      settings.firstQuestion.descriptionCaption2 = firstRow[2];
      settings.mainQuestion.descriptionCaption2 = firstRow[2];
      settings.additionalQiestion.descriptionCaption2 = firstRow[2];

      settings.firstQuestion.descriptionCaption3 = firstRow[3];
      settings.mainQuestion.descriptionCaption3 = firstRow[3];
      settings.additionalQiestion.descriptionCaption3 = firstRow[3];

      settings.firstQuestion.descriptionCaption4 = firstRow[4];
      settings.mainQuestion.descriptionCaption4 = firstRow[4];
      settings.additionalQiestion.descriptionCaption4 = firstRow[4];
    }

    questions = agendaQuestions;

    _setState(() {});
  }

  static List<QuestionDescriptionItem> createQuestionDescription(
      QuestionGroupSettings group) {
    return <QuestionDescriptionItem>[
      QuestionDescriptionItem(
          caption: group.descriptionCaption1,
          showOnStoreboard: group.showCaption1OnStoreboard,
          showInReports: group.showCaption1InReports),
      QuestionDescriptionItem(
          caption: group.descriptionCaption2,
          showOnStoreboard: group.showCaption2OnStoreboard,
          showInReports: group.showCaption2InReports),
      QuestionDescriptionItem(
          caption: group.descriptionCaption3,
          showOnStoreboard: group.showCaption3OnStoreboard,
          showInReports: group.showCaption3InReports),
      QuestionDescriptionItem(
          caption: group.descriptionCaption4,
          showOnStoreboard: group.showCaption4OnStoreboard,
          showInReports: group.showCaption4InReports)
    ];
  }

  static Future<Question?> onNewItemAdd(int itemIndex) async {
    _setState(() {
      questions.insert(itemIndex, _newQuestionStub);
    });

    var noButtonPressed = false;
    var title = 'Добавить вопрос';
    String selectedOption = "Основной вопрос";

    await Utility().showYesNoOptionsDialog(
      _context,
      title: title,
      text: 'Вы уверены, что хотите ${title.toLowerCase()}?',
      options: <String>[
        "Первый вопрос",
        "Основной вопрос",
        "Дополнительный вопрос",
      ],
      yesButtonText: 'Да',
      yesCallBack: (String option) {
        _setState(() {
          questions.remove(_newQuestionStub);
        });

        selectedOption = option;
        Navigator.of(_context).pop();
      },
      noButtonText: 'Нет',
      noCallBack: () {
        _setState(() {
          questions.remove(_newQuestionStub);
        });

        noButtonPressed = true;
        Navigator.of(_context).pop();
      },
    );

    var settingsGroup = settings.mainQuestion;

    if (noButtonPressed) {
      return null;
    }

    if (selectedOption == "Первый вопрос") {
      settingsGroup = settings.firstQuestion;
    }
    if (selectedOption == "Основной вопрос") {
      settingsGroup = settings.mainQuestion;
    }
    if (selectedOption == "Дополнительный вопрос") {
      settingsGroup = settings.additionalQiestion;
    }

    // new item
    if (itemIndex == -1) {
      itemIndex = questions.length;
    }

    var newQuestion = Question();
    newQuestion.orderNum = itemIndex;
    newQuestion.name = settingsGroup.defaultGroupName;
    newQuestion.descriptions = createQuestionDescription(settingsGroup);
    newQuestion.files = <QuestionFile>[];

    questions.insert(itemIndex, newQuestion);
    normalizeList(true);

    // create folder for new question
    Directory('${File(_agendaFilePath).parent.path}\\${newQuestion.folder}')
        .createSync();

    // create description file
    var descriptionFile = File(
        '${File(_agendaFilePath).parent.path}\\${newQuestion.folder}\\Описание.txt');
    descriptionFile.createSync();

    var descriptionInfo = <String, dynamic>{};
    descriptionFile.writeAsBytes(
      const Utf16Encoder().encodeUtf16Le(json.encode(descriptionInfo), true),
    );

    return newQuestion;
  }

  static Future<void> saveQuestionList() async {
    List<List<dynamic>> rows = <List<dynamic>>[];

    rows.add(firstRow);

    for (int i = 0; i < questions.length; i++) {
      rows.add(<String>[
        "",
        questions[i].folder,
        "",
        questions[i].descriptions.length > 0
            ? questions[i].descriptions[0].text ?? ""
            : "",
        questions[i].descriptions.length > 1
            ? questions[i].descriptions[1].text ?? ""
            : "",
        questions[i].descriptions.length > 2
            ? questions[i].descriptions[2].text ?? ""
            : "",
        questions[i].descriptions.length > 3
            ? questions[i].descriptions[3].text ?? ""
            : "",
      ]);
    }

    var fileContent = const ListToCsvConverter(
      fieldDelimiter: ',',
      eol: '\r\n',
      delimitAllFields: true,
    ).convert(rows);

    File agendaFile = File(_agendaFilePath);

    agendaFile.writeAsBytes(
      const Utf16Encoder().encodeUtf16Le(fileContent, true),
    );

    _setState(() {});
  }

  static void normalizeList(bool isReverseDirection) {
    var folders = File(_agendaFilePath).parent.listSync();

    if (isReverseDirection) {
      for (int i = questions.length - 1; i >= 0; i--) {
        var foundFolder = folders.firstWhere(
            (element) =>
                path.basename(element.path) == questions[i].folder.toString(),
            orElse: () => Directory(''));

        bool isFolderExists =
            foundFolder is Directory && foundFolder.path != '';

        // rename existing folder
        var fixedFolderName = getGetFolderName(i);
        if (questions[i].folder != fixedFolderName && isFolderExists) {
          foundFolder
              .renameSync('${foundFolder.parent.path}\\$fixedFolderName');
        }

        questions[i].id = getQuestionNumber(i);
        questions[i].orderNum = i;
        questions[i].folder = fixedFolderName;
      }
    } else {
      for (int i = 0; i < questions.length; i++) {
        var foundFolder = folders.firstWhere(
            (element) =>
                path.basename(element.path) == questions[i].folder.toString(),
            orElse: () => Directory(''));

        bool isFolderExists =
            foundFolder is Directory && foundFolder.path != '';

        // rename existing folder
        var fixedFolderName = getGetFolderName(i);
        if (questions[i].folder != fixedFolderName && isFolderExists) {
          foundFolder
              .renameSync('${foundFolder.parent.path}\\$fixedFolderName');
        }

        questions[i].id = getQuestionNumber(i);
        questions[i].orderNum = i;
        questions[i].folder = fixedFolderName;
      }
    }
  }

  static void normalizeFiles(Question question, bool isReverseDirection) {
    var files = Directory(
            '${File(_agendaFilePath).parent.path}\\${getGetFolderName(questions.indexOf(question))}')
        .listSync();

    if (isReverseDirection) {
      for (int i = question.files.length - 1; i >= 0; i--) {
        var foundFile = files.firstWhere(
            (element) =>
                path.basename(element.path) == question.files[i].fileName,
            orElse: () => File(''));

        bool isFileExists = foundFile is File && foundFile.path != '';

        // rename existing file
        var fixedFileName = getFileName(question.folder, i + 1);
        if (question.files[i].fileName != fixedFileName && isFileExists) {
          foundFile.renameSync('${foundFile.parent.path}\\$fixedFileName');
        }

        question.files[i].fileName = fixedFileName;
      }
    } else {
      for (int i = 0; i < question.files.length; i++) {
        var foundFile = files.firstWhere(
            (element) =>
                path.basename(element.path) == question.files[i].fileName,
            orElse: () => File(''));

        bool isFileExists = foundFile is File && foundFile.path != '';

        // rename existing file
        var fixedFileName = getFileName(question.folder, i + 1);

        if (questions[i].folder != fixedFileName && isFileExists) {
          foundFile.renameSync('${foundFile.parent.path}\\$fixedFileName');
        }

        question.files[i].fileName = fixedFileName;
      }
    }

    // update description file
    var descriptionInfo = <String, dynamic>{};

    for (int i = 0; i < question.files.length; i++) {
      descriptionInfo.putIfAbsent(
          question.files[i].fileName, () => question.files[i].description);
    }

    File('${File(_agendaFilePath).parent.path}\\${question.folder}\\Описание.txt')
        .writeAsBytes(
      const Utf16Encoder().encodeUtf16Le(json.encode(descriptionInfo), true),
    );
  }

  static String getFileName(String folder, int fileIndex) {
    if (folder.contains('д')) {
      return "Вопрос${folder.replaceFirst(' ', '')}_файл${(fileIndex).toString().padLeft(2, '0')}.pdf";
    }
    return "Вопрос${folder.toString().padLeft(2, '0')}_файл${(fileIndex).toString().padLeft(2, '0')}.pdf";
  }

  static String getGetFolderName(int index) {
    var fixedFolderName = getQuestionNumber(index).toString();

    if (questions[index].name == settings.additionalQiestion.defaultGroupName) {
      fixedFolderName += ' д';
    }

    return fixedFolderName;
  }

  static int getQuestionNumber(int index) {
    var questionNumber = index;

    var additionalQuestionCount = questions
        .sublist(0, index)
        .where((element) => (element.folder?.contains(' д') == true))
        .length;
    if (questions[index].name == settings.additionalQiestion.defaultGroupName) {
      return additionalQuestionCount + 1;
    }

    return questionNumber - additionalQuestionCount;
  }

  static void onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    var newFolderName = Uuid().v4();

    var questionFolderName = getGetFolderName(oldItemIndex);
    var question = questions[oldItemIndex];
    questions.remove(question);

    var questionDirectory =
        Directory('${File(_agendaFilePath).parent.path}\\$questionFolderName');

    // set question directory temporary name
    if (questionDirectory.existsSync()) {
      questionDirectory
          .renameSync('${questionDirectory.parent.path}\\$newFolderName');
    }

    question.orderNum = newItemIndex;

    questions.insert(newItemIndex, question);

    normalizeList(oldItemIndex > newItemIndex);

    // set question directory name back
    var tempQuestionDirectory =
        Directory('${questionDirectory.parent.path}\\$newFolderName');

    if (tempQuestionDirectory.existsSync()) {
      tempQuestionDirectory.renameSync(
          '${questionDirectory.parent.path}\\${getGetFolderName(newItemIndex)}');
    }
  }

  static void onFilesReorder(Question question, int oldItemIndex,
      int oldListIndex, int newItemIndex, int newListIndex) {
    var newFileName = Uuid().v4();

    var file = question.files[oldItemIndex];
    question.files.remove(file);

    var fileFile = File(
        '${File(_agendaFilePath).parent.path}\\${question.folder}\\${file.fileName}');

    // set file temporary name
    if (fileFile.existsSync()) {
      fileFile.renameSync(
          '${File(_agendaFilePath).parent.path}\\${question.folder}\\$newFileName');
    }

    question.files.insert(newItemIndex, file);

    normalizeFiles(question, oldItemIndex > newItemIndex);

    // set file name back
    var tempFileFile = File(
        '${File(_agendaFilePath).parent.path}\\${question.folder}\\$newFileName');

    if (tempFileFile.existsSync()) {
      var fixedFileName = getFileName(question.folder, newItemIndex + 1);

      tempFileFile.renameSync(
          '${File(_agendaFilePath).parent.path}\\${question.folder}\\$fixedFileName');
    }
  }
}
