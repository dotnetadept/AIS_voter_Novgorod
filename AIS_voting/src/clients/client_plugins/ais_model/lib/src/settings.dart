import 'dart:convert';
import 'package:enum_to_string/enum_to_string.dart';

class Settings {
  late int id;
  late String name;
  late bool isSelected;
  late DateTime createdDate;
  late SettingsPallete palletteSettings;
  late OperatorSchemeSettings operatorSchemeSettings;
  late ManagerSchemeSettings managerSchemeSettings;
  late TableViewSettings tableViewSettings;
  late DeputySettings deputySettings;
  late ReportSettings reportSettings;
  late VotingSettings votingSettings;
  late StoreboardSettings storeboardSettings;
  late QuestionListSettings questionListSettings;
  late FileSettings fileSettings;
  late SignalsSettings signalsSettings;
  late IntervalsSettings intervalsSettings;
  late LicenseSettings licenseSettings;

  Settings() {
    name = 'Настройки';
    isSelected = false;
    createdDate = DateTime.now();
    palletteSettings = SettingsPallete();
    operatorSchemeSettings = OperatorSchemeSettings();
    managerSchemeSettings = ManagerSchemeSettings();
    tableViewSettings = TableViewSettings();
    deputySettings = DeputySettings();
    reportSettings = ReportSettings();
    votingSettings = VotingSettings();
    storeboardSettings = StoreboardSettings();
    questionListSettings = QuestionListSettings();
    fileSettings = FileSettings();
    signalsSettings = SignalsSettings();
    intervalsSettings = IntervalsSettings();
    licenseSettings = LicenseSettings();
  }

  Map toJson() => {
        'id': id,
        'name': name,
        'isSelected': isSelected,
        'createdDate': createdDate.toIso8601String(),
        'palletteSettings': json.encode(palletteSettings.toJson()),
        'operatorSchemeSettings': json.encode(operatorSchemeSettings.toJson()),
        'managerSchemeSettings': json.encode(managerSchemeSettings.toJson()),
        'tableViewSettings': json.encode(tableViewSettings.toJson()),
        'deputySettings': json.encode(deputySettings.toJson()),
        'reportSettings': json.encode(reportSettings.toJson()),
        'votingSettings': json.encode(votingSettings.toJson()),
        'storeboardSettings': json.encode(storeboardSettings.toJson()),
        'questionListSettings': json.encode(questionListSettings.toJson()),
        'fileSettings': json.encode(fileSettings.toJson()),
        'signalsSettings': json.encode(signalsSettings.toJson()),
        'intervalsSettings': json.encode(intervalsSettings.toJson()),
        'licenseSettings': json.encode(licenseSettings.toJson()),
      };

  Settings.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        isSelected = json['isSelected'],
        createdDate = DateTime.parse(json['createdDate']),
        palletteSettings = json['palletteSettings'] == null
            ? SettingsPallete()
            : SettingsPallete.fromJson(jsonDecode(json['palletteSettings'])),
        operatorSchemeSettings = json['operatorSchemeSettings'] == null
            ? OperatorSchemeSettings()
            : OperatorSchemeSettings.fromJson(
                jsonDecode(json['operatorSchemeSettings'])),
        managerSchemeSettings = json['managerSchemeSettings'] == null
            ? ManagerSchemeSettings()
            : ManagerSchemeSettings.fromJson(
                jsonDecode(json['managerSchemeSettings'])),
        tableViewSettings = json['tableViewSettings'] == null
            ? TableViewSettings()
            : TableViewSettings.fromJson(jsonDecode(json['tableViewSettings'])),
        deputySettings = json['deputySettings'] == null
            ? DeputySettings()
            : DeputySettings.fromJson(jsonDecode(json['deputySettings'])),
        reportSettings = json['reportSettings'] == null
            ? ReportSettings()
            : ReportSettings.fromJson(jsonDecode(json['reportSettings'])),
        votingSettings = json['votingSettings'] == null
            ? VotingSettings()
            : VotingSettings.fromJson(jsonDecode(json['votingSettings'])),
        storeboardSettings = json['storeboardSettings'] == null
            ? StoreboardSettings()
            : StoreboardSettings.fromJson(
                jsonDecode(json['storeboardSettings'])),
        questionListSettings = json['questionListSettings'] == null
            ? QuestionListSettings()
            : QuestionListSettings.fromJson(
                jsonDecode(json['questionListSettings'])),
        fileSettings = json['fileSettings'] == null
            ? FileSettings()
            : FileSettings.fromJson(jsonDecode(json['fileSettings'])),
        signalsSettings = json['signalsSettings'] == null
            ? SignalsSettings()
            : SignalsSettings.fromJson(jsonDecode(json['signalsSettings'])),
        intervalsSettings = json['intervalsSettings'] == null
            ? IntervalsSettings()
            : IntervalsSettings.fromJson(jsonDecode(json['intervalsSettings'])),
        licenseSettings = json['licenseSettings'] == null
            ? LicenseSettings()
            : LicenseSettings.fromJson(jsonDecode(json['licenseSettings']));

  @override
  String toString() {
    return name;
  }
}

class SettingsPallete {
  late int backgroundColor;
  late int schemeBackgroundColor;
  late int cellColor;
  late int alternateCellColor;
  late String alternateRowNumbers;
  late int alternateRowPadding;
  late String paddingRowNumbers;

  late int cellTextColor;
  late int cellBorderColor;

  late int unRegistredColor;
  late int registredColor;
  late int voteYesColor;
  late int voteNoColor;
  late int voteIndifferentColor;
  late int voteResetColor;
  late int askWordColor;
  late int onSpeechColor;

  late int buttonTextColor;

  late int iconOnlineColor;
  late int iconOfflineColor;
  late int iconDocumentsDownloadedColor;
  late int iconDocumentsNotDownloadedColor;

  SettingsPallete() {
    backgroundColor = 0xff9e9e9e;
    schemeBackgroundColor = 0x3dffffff;
    cellColor = 0x1f000000;
    alternateCellColor = 0x2f000000;
    alternateRowNumbers = '';
    alternateRowPadding = 10;
    paddingRowNumbers = '';
    cellTextColor = 0xff000000;
    cellBorderColor = 0x8a000000;

    unRegistredColor = 0xffffffff;
    registredColor = 0xff2196f3;
    voteYesColor = 0xff59f0ae;
    voteNoColor = 0xffff8a80;
    voteIndifferentColor = 0xfff040fb;
    voteResetColor = 0xff9e9e9e;
    askWordColor = 0xffffeb3b;
    onSpeechColor = 0xffb39ddb;

    buttonTextColor = 0xffffffff;

    iconOnlineColor = 0xff4caf50;
    iconOfflineColor = 0xfff44336;
    iconDocumentsDownloadedColor = 0xff4caf50;
    iconDocumentsNotDownloadedColor = 0xfff44336;
  }

  Map toJson() => {
        'backgroundColor': backgroundColor,
        'schemeBackgroundColor': schemeBackgroundColor,
        'cellColor': cellColor,
        'alternateCellColor': alternateCellColor,
        'alternateRowNumbers': alternateRowNumbers,
        'alternateRowPadding': alternateRowPadding,
        'paddingRowNumbers': paddingRowNumbers,
        'cellTextColor': cellTextColor,
        'cellBorderColor': cellBorderColor,
        'unRegistredColor': unRegistredColor,
        'registredColor': registredColor,
        'voteYesColor': voteYesColor,
        'voteNoColor': voteNoColor,
        'voteIndifferentColor': voteIndifferentColor,
        'voteResetColor': voteResetColor,
        'askWordColor': askWordColor,
        'onSpeechColor': onSpeechColor,
        'buttonTextColor': buttonTextColor,
        'iconOnlineColor': iconOnlineColor,
        'iconOfflineColor': iconOfflineColor,
        'iconDocumentsDownloadedColor': iconDocumentsDownloadedColor,
        'iconDocumentsNotDownloadedColor': iconDocumentsNotDownloadedColor,
      };

  SettingsPallete.fromJson(Map<String, dynamic> json)
      : backgroundColor = json['backgroundColor'],
        schemeBackgroundColor = json['schemeBackgroundColor'],
        cellColor = json['cellColor'],
        alternateCellColor = json['alternateCellColor'],
        alternateRowNumbers = json['alternateRowNumbers'],
        alternateRowPadding = json['alternateRowPadding'],
        paddingRowNumbers = json['paddingRowNumbers'],
        cellTextColor = json['cellTextColor'],
        cellBorderColor = json['cellBorderColor'],
        unRegistredColor = json['unRegistredColor'],
        registredColor = json['registredColor'],
        voteYesColor = json['voteYesColor'],
        voteNoColor = json['voteNoColor'],
        voteIndifferentColor = json['voteIndifferentColor'],
        voteResetColor = json['voteResetColor'],
        askWordColor = json['askWordColor'],
        onSpeechColor = json['onSpeechColor'],
        buttonTextColor = json['buttonTextColor'],
        iconOnlineColor = json['iconOnlineColor'],
        iconOfflineColor = json['iconOfflineColor'],
        iconDocumentsDownloadedColor = json['iconDocumentsDownloadedColor'],
        iconDocumentsNotDownloadedColor =
            json['iconDocumentsNotDownloadedColor'];
}

class OperatorSchemeSettings {
  late bool inverseScheme;
  late bool controlSound;
  //bool controlSoundServer;
  late bool showLegend;
  late bool showTribune;
  late bool showStatePanel;
  late bool useTableView;

  late int cellWidth;
  late int cellManagementWidth;
  late int cellTribuneWidth;
  late int cellBorder;
  late int cellInnerPadding;
  late int cellOuterPaddingVertical;
  late int cellOuterPaddingHorisontal;

  late bool isShortNamesUsed;
  late int cellTextSize;

  late String overflowOption;
  late int textMaxLines;
  late bool showOverflow;

  late int iconSize;

  OperatorSchemeSettings() {
    inverseScheme = false;
    controlSound = true;
    //controlSoundServer = true;
    showLegend = true;
    showTribune = true;
    showStatePanel = true;
    useTableView = true;
    cellWidth = 200;
    cellManagementWidth = 200;
    cellTribuneWidth = 200;
    cellBorder = 1;
    cellInnerPadding = 10;
    cellOuterPaddingVertical = 10;
    cellOuterPaddingHorisontal = 10;
    isShortNamesUsed = false;
    cellTextSize = 14;

    overflowOption = 'Растягивать ячейку по высоте текста';
    textMaxLines = 3;
    showOverflow = true;
    iconSize = 22;
  }

  Map toJson() => {
        'inverseScheme': inverseScheme,
        'controlSound': controlSound,
        //'controlSoundServer': controlSoundServer,
        'showLegend': showLegend,
        'showTribune': showTribune,
        'showStatePanel': showStatePanel,
        'useTableView': useTableView,
        'cellWidth': cellWidth,
        'cellManagementWidth': cellManagementWidth,
        'cellTribuneWidth': cellTribuneWidth,
        'cellBorder': cellBorder,
        'cellInnerPadding': cellInnerPadding,
        'cellOuterPaddingVertical': cellOuterPaddingVertical,
        'cellOuterPaddingHorisontal': cellOuterPaddingHorisontal,
        'isShortNamesUsed': isShortNamesUsed,
        'cellTextSize': cellTextSize,
        'overflowOption': overflowOption,
        'textMaxLines': textMaxLines,
        'showOverflow': showOverflow,
        'iconSize': iconSize,
      };

  OperatorSchemeSettings.fromJson(Map<String, dynamic> json)
      : inverseScheme = json['inverseScheme'],
        controlSound = json['controlSound'],
        //controlSoundServer = json['controlSoundServer'],
        showLegend = json['showLegend'],
        showTribune = json['showTribune'],
        showStatePanel = json['showStatePanel'],
        useTableView = json['useTableView'],
        cellWidth = json['cellWidth'],
        cellManagementWidth = json['cellManagementWidth'],
        cellTribuneWidth = json['cellTribuneWidth'],
        cellBorder = json['cellBorder'],
        cellInnerPadding = json['cellInnerPadding'],
        cellOuterPaddingVertical = json['cellOuterPaddingVertical'],
        cellOuterPaddingHorisontal = json['cellOuterPaddingHorisontal'],
        isShortNamesUsed = json['isShortNamesUsed'],
        cellTextSize = json['cellTextSize'],
        overflowOption = json['overflowOption'],
        textMaxLines = json['textMaxLines'],
        showOverflow = json['showOverflow'],
        iconSize = json['iconSize'];
}

class ManagerSchemeSettings {
  late bool inverseScheme;
  late bool controlSound;
  //bool controlSoundServer;
  late bool showLegend;
  late bool showTribune;
  late bool showStatePanel;
  late bool useTableView;

  late int cellWidth;
  late int cellManagementWidth;
  late int cellTribuneWidth;
  late int cellBorder;
  late int cellInnerPadding;
  late int cellOuterPaddingVertical;
  late int cellOuterPaddingHorisontal;

  late bool isShortNamesUsed;
  late int cellTextSize;
  late String cellTextAlign;
  late String overflowOption;
  late int textMaxLines;
  late bool showOverflow;

  late int deputyFontSize;
  late int deputyNumberFontSize;
  late int deputyCaptionFontSize;
  late int deputyFilesListHeight;

  late int iconSize;

  ManagerSchemeSettings() {
    inverseScheme = false;
    controlSound = true;
    //controlSoundServer = true;
    showLegend = true;
    showTribune = true;
    showStatePanel = true;
    useTableView = true;
    cellWidth = 200;
    cellManagementWidth = 200;
    cellTribuneWidth = 200;
    cellBorder = 1;
    cellInnerPadding = 10;
    cellOuterPaddingVertical = 20;
    cellOuterPaddingHorisontal = 10;
    isShortNamesUsed = false;
    cellTextSize = 14;
    cellTextAlign = 'Слева';
    overflowOption = 'Растягивать ячейку по высоте текста';
    textMaxLines = 3;
    showOverflow = true;
    iconSize = 22;
    deputyFontSize = 22;
    deputyNumberFontSize = 22;
    deputyCaptionFontSize = 26;
    deputyFilesListHeight = 350;
  }

  Map toJson() => {
        'inverseScheme': inverseScheme,
        'controlSound': controlSound,
        //'controlSoundServer': controlSoundServer,
        'showLegend': showLegend,
        'showTribune': showTribune,
        'showStatePanel': showStatePanel,
        'useTableView': useTableView,
        'cellWidth': cellWidth,
        'cellManagementWidth': cellManagementWidth,
        'cellTribuneWidth': cellTribuneWidth,
        'cellBorder': cellBorder,
        'cellInnerPadding': cellInnerPadding,
        'cellOuterPaddingVertical': cellOuterPaddingVertical,
        'cellOuterPaddingHorisontal': cellOuterPaddingHorisontal,
        'isShortNamesUsed': isShortNamesUsed,
        'cellTextSize': cellTextSize,
        'cellTextAlign': cellTextAlign,
        'overflowOption': overflowOption,
        'textMaxLines': textMaxLines,
        'showOverflow': showOverflow,
        'iconSize': iconSize,
        'deputyFontSize': deputyFontSize,
        'deputyNumberFontSize': deputyNumberFontSize,
        'deputyCaptionFontSize': deputyCaptionFontSize,
        'deputyFilesListHeight': deputyFilesListHeight,
      };

  ManagerSchemeSettings.fromJson(Map<String, dynamic> json)
      : inverseScheme = json['inverseScheme'],
        controlSound = json['controlSound'],
        //controlSoundServer = json['controlSoundServer'],
        showLegend = json['showLegend'],
        showTribune = json['showTribune'],
        showStatePanel = json['showStatePanel'],
        useTableView = json['useTableView'],
        cellWidth = json['cellWidth'],
        cellManagementWidth = json['cellManagementWidth'],
        cellTribuneWidth = json['cellTribuneWidth'],
        cellBorder = json['cellBorder'],
        cellInnerPadding = json['cellInnerPadding'],
        cellOuterPaddingVertical = json['cellOuterPaddingVertical'],
        cellOuterPaddingHorisontal = json['cellOuterPaddingHorisontal'],
        isShortNamesUsed = json['isShortNamesUsed'],
        cellTextSize = json['cellTextSize'],
        cellTextAlign = json['cellTextAlign'],
        overflowOption = json['overflowOption'],
        textMaxLines = json['textMaxLines'],
        showOverflow = json['showOverflow'],
        iconSize = json['iconSize'],
        deputyFontSize = json['deputyFontSize'],
        deputyNumberFontSize = json['deputyNumberFontSize'],
        deputyCaptionFontSize = json['deputyCaptionFontSize'],
        deputyFilesListHeight = json['deputyFilesListHeight'];
}

class TableViewSettings {
  late int columnsCount;
  late String cellTextAlign;
  late bool showLegend;

  late List<HeaderItem> headerItems;
  late List<IconItem> iconItems;

  TableViewSettings() {
    columnsCount = 4;
    cellTextAlign = 'Слева';
    showLegend = true;
    headerItems = <HeaderItem>[];
    iconItems = <IconItem>[];
  }

  Map toJson() => {
        'columnsCount': columnsCount,
        'cellTextAlign': cellTextAlign,
        'showLegend': showLegend,
        'headerItems': headerItems.map((item) => item.toJson()).toList(),
        'iconItems': iconItems,
      };

  TableViewSettings.fromJson(Map<String, dynamic> json)
      : columnsCount = json['columnsCount'],
        cellTextAlign = json['cellTextAlign'],
        showLegend = json['showLegend'],
        headerItems = json['headerItems'] == null
            ? List<HeaderItem>()
            : List<dynamic>.from(json['headerItems'])
                .map((i) => HeaderItem.fromJson(i))
                .toList(),
        iconItems = json['iconItems'];
}

class HeaderItem {
  late String name;
  late HeaderItemValue value;
  late int orderNum;
  late bool isVisible;

  HeaderItem({
    required String name,
    required HeaderItemValue value,
    required int orderNum,
    required bool isVisible,
  }) {
    this.name = name;
    this.value = value;
    this.orderNum = orderNum;
    this.isVisible = isVisible;
  }

  Map toJson() => {
        'name': name,
        'value': EnumToString.convertToString(value),
        'orderNum': orderNum,
        'isVisible': isVisible,
      };

  HeaderItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        value = EnumToString.fromString(HeaderItemValue.values, json['value']),
        orderNum = json['orderNum'],
        isVisible = json['isVisible'];
}

enum HeaderItemValue {
  QuorumCount,
  AllCount,
  ChosenCount,
  OnlineCount,
  OfflineCount,
  RegistredCount,
  UnRegistredCount,
  VotedYes,
  VotedNo,
  VotedIndifferent,
  VotedTotal
}

class IconItem {
  late IconType type;
  late IconDisplayPosition position;

  IconItem() {
    type = IconType.OnlineStatus;
    position = IconDisplayPosition.Left;
  }

  Map toJson() => {
        'type': type,
        'position': position,
      };

  IconItem.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        position = json['position'];
}

enum IconType {
  OnlineStatus,
  RegistredStatus,
  AskWordOrder,
  FilesStatus,
  MicStatus,
  DisplayStatus,
}

enum IconDisplayPosition {
  Left,
  Right,
  None,
}

class DeputySettings {
  late bool showQuestionsOnPreparation;
  late bool showQuestionsForRegistred;
  late bool useTempAskWordQueue;

  DeputySettings() {
    showQuestionsOnPreparation = true;
    showQuestionsForRegistred = true;
    useTempAskWordQueue = true;
  }

  Map toJson() => {
        'showQuestionsOnPreparation': showQuestionsOnPreparation,
        'showQuestionsForRegistred': showQuestionsForRegistred,
        'useTempAskWordQueue': useTempAskWordQueue,
      };

  DeputySettings.fromJson(Map<String, dynamic> json)
      : showQuestionsOnPreparation = json['showQuestionsOnPreparation'],
        showQuestionsForRegistred = json['showQuestionsForRegistred'],
        useTempAskWordQueue = json['useTempAskWordQueue'] ?? false;
}

class ReportSettings {
  late bool isLastResultsOnly;
  late String reportFooter;

  ReportSettings() {
    isLastResultsOnly = false;
    reportFooter = '';
  }

  Map toJson() => {
        'isLastResultsOnly': isLastResultsOnly,
        'reportFooter': reportFooter,
      };

  ReportSettings.fromJson(Map<String, dynamic> json)
      : isLastResultsOnly = json['isLastResultsOnly'],
        reportFooter = json['reportFooter'];
}

class VotingSettings {
  late bool isVotingFixed;
  late bool isCountNotVotingAsIndifferent;
  late int defaultShowResultInterval;
  late int? defaultVotingModeId;
  late String votingRegim;

  VotingSettings() {
    isVotingFixed = true;
    isCountNotVotingAsIndifferent = false;
    defaultShowResultInterval = 10;
    defaultVotingModeId = null;
    votingRegim = 'Открытое';
  }

  Map toJson() => {
        'isVotingFixed': isVotingFixed,
        'isCountNotVotingAsIndifferent': isCountNotVotingAsIndifferent,
        'defaultShowResultInterval': defaultShowResultInterval,
        'defaultVotingModeId': defaultVotingModeId,
        'votingRegim': votingRegim,
      };

  VotingSettings.fromJson(Map<String, dynamic> json)
      : isVotingFixed = json['isVotingFixed'],
        isCountNotVotingAsIndifferent = json['isCountNotVotingAsIndifferent'],
        defaultShowResultInterval = json['defaultShowResultInterval'],
        defaultVotingModeId = json['defaultVotingModeId'],
        votingRegim = json['votingRegim'];
}

class StoreboardSettings {
  late int backgroundColor;
  late int textColor;
  late int decisionAcceptedColor;
  late int decisionDeclinedColor;

  late int height;
  late int width;

  late int paddingLeft;
  late int paddingTop;
  late int paddingRight;
  late int paddingBottom;

  late String meetingDescriptionTemplate;
  late String noDataText;
  late int speakerInterval;
  late int breakInterval;

  late int meetingDescriptionFontSize;
  late int meetingFontSize;
  late int groupFontSize;

  late int customCaptionFontSize;
  late int customTextFontSize;

  late int resultItemsFontSize;
  late int resultTotalFontSize;
  late int timersFontSize;

  late int questionNameFontSize;
  late int questionDescriptionFontSize;
  late bool justifyQuestionDescription;

  late int clockFontSize;
  late bool clockFontBold;

  late int detailsAnimationDuration;
  late int detailsRowsCount;
  late int detailsFontSize;

  StoreboardSettings() {
    backgroundColor = 0xff010066;
    textColor = 0xffffffff;
    decisionAcceptedColor = 0xff59f0ae;
    decisionDeclinedColor = 0xffff8a80;

    height = 300;
    width = 420;

    paddingLeft = 10;
    paddingTop = 10;
    paddingRight = 10;
    paddingBottom = 10;

    meetingDescriptionTemplate = '';
    noDataText = 'н/д';
    speakerInterval = 5;
    breakInterval = 1800;

    meetingDescriptionFontSize = 16;
    meetingFontSize = 16;
    groupFontSize = 16;

    customCaptionFontSize = 18;
    customTextFontSize = 16;

    resultItemsFontSize = 18;
    resultTotalFontSize = 24;
    timersFontSize = 24;

    questionNameFontSize = 14;
    questionDescriptionFontSize = 12;
    justifyQuestionDescription = true;

    clockFontSize = 14;
    clockFontBold = false;

    detailsAnimationDuration = 3;
    detailsRowsCount = 10;
    detailsFontSize = 18;
  }

  Map toJson() => {
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'decisionAcceptedColor': decisionAcceptedColor,
        'decisionDeclinedColor': decisionDeclinedColor,
        'height': height,
        'width': width,
        'paddingLeft': paddingLeft,
        'paddingTop': paddingTop,
        'paddingRight': paddingRight,
        'paddingBottom': paddingBottom,
        'meetingDescriptionTemplate': meetingDescriptionTemplate,
        'noDataText': noDataText,
        'speakerInterval': speakerInterval,
        'breakInterval': breakInterval,
        'meetingDescriptionFontSize': meetingDescriptionFontSize,
        'meetingFontSize': meetingFontSize,
        'groupFontSize': groupFontSize,
        'customCaptionFontSize': customCaptionFontSize,
        'customTextFontSize': customTextFontSize,
        'resultItemsFontSize': resultItemsFontSize,
        'resultTotalFontSize': resultTotalFontSize,
        'timersFontSize': timersFontSize,
        'questionNameFontSize': questionNameFontSize,
        'questionDescriptionFontSize': questionDescriptionFontSize,
        'justifyQuestionDescription': justifyQuestionDescription,
        'clockFontSize': clockFontSize,
        'clockFontBold': clockFontBold,
        'detailsAnimationDuration': detailsAnimationDuration,
        'detailsRowsCount': detailsRowsCount,
        'detailsFontSize': detailsFontSize
      };

  StoreboardSettings.fromJson(Map<String, dynamic> json)
      : backgroundColor = json['backgroundColor'],
        textColor = json['textColor'],
        decisionAcceptedColor = json['decisionAcceptedColor'],
        decisionDeclinedColor = json['decisionDeclinedColor'],
        height = json['height'],
        width = json['width'],
        paddingLeft = json['paddingLeft'],
        paddingTop = json['paddingTop'],
        paddingRight = json['paddingRight'],
        paddingBottom = json['paddingBottom'],
        meetingDescriptionTemplate = json['meetingDescriptionTemplate'],
        noDataText = json['noDataText'],
        speakerInterval = json['speakerInterval'],
        breakInterval = json['breakInterval'],
        meetingDescriptionFontSize = json['meetingDescriptionFontSize'],
        meetingFontSize = json['meetingFontSize'],
        groupFontSize = json['groupFontSize'],
        customCaptionFontSize = json['customCaptionFontSize'],
        customTextFontSize = json['customTextFontSize'],
        resultItemsFontSize = json['resultItemsFontSize'],
        resultTotalFontSize = json['resultTotalFontSize'],
        timersFontSize = json['timersFontSize'],
        questionNameFontSize = json['questionNameFontSize'],
        questionDescriptionFontSize = json['questionDescriptionFontSize'],
        justifyQuestionDescription = json['justifyQuestionDescription'],
        clockFontSize = json['clockFontSize'],
        clockFontBold = json['clockFontBold'],
        detailsAnimationDuration = json['detailsAnimationDuration'],
        detailsRowsCount = json['detailsRowsCount'],
        detailsFontSize = json['detailsFontSize'];

  int getContentWidth() {
    return width - paddingLeft - paddingRight;
  }
}

class QuestionListSettings {
  late String reportsFolderPath;
  late String agendaFileExtension;
  late String fileNameTrimmer;

  late QuestionGroupSettings firstQuestion;
  late QuestionGroupSettings mainQuestion;
  late QuestionGroupSettings additionalQiestion;

  QuestionListSettings() {
    reportsFolderPath = '';

    agendaFileExtension = 'txt';
    fileNameTrimmer = '[0-9][0-9][\\s]';

    firstQuestion = QuestionGroupSettings();
    mainQuestion = QuestionGroupSettings();
    additionalQiestion = QuestionGroupSettings();
  }

  Map toJson() => {
        'reportsFolderPath': reportsFolderPath,
        'agendaFileExtension': agendaFileExtension,
        'fileNameTrimmer': fileNameTrimmer,
        'firstQuestion': json.encode(firstQuestion.toJson()),
        'mainQuestion': json.encode(mainQuestion.toJson()),
        'additionalQiestion': json.encode(additionalQiestion.toJson()),
      };

  QuestionListSettings.fromJson(Map<String, dynamic> json)
      : reportsFolderPath = json['reportsFolderPath'],
        agendaFileExtension = json['agendaFileExtension'],
        fileNameTrimmer = json['fileNameTrimmer'],
        firstQuestion = json['firstQuestion'] == null
            ? QuestionGroupSettings()
            : QuestionGroupSettings.fromJson(jsonDecode(json['firstQuestion'])),
        mainQuestion = json['mainQuestion'] == null
            ? QuestionGroupSettings()
            : QuestionGroupSettings.fromJson(jsonDecode(json['mainQuestion'])),
        additionalQiestion = json['additionalQiestion'] == null
            ? QuestionGroupSettings()
            : QuestionGroupSettings.fromJson(
                jsonDecode(json['additionalQiestion']));
}

class QuestionGroupSettings {
  late String defaultGroupName;

  late bool isUseNumber;
  late bool showNumberBeforeName;

  late String descriptionCaption1;
  late bool showCaption1InReports;
  late bool showCaption1OnStoreboard;
  late String descriptionCaption2;
  late bool showCaption2InReports;
  late bool showCaption2OnStoreboard;
  late String descriptionCaption3;
  late bool showCaption3InReports;
  late bool showCaption3OnStoreboard;
  late String descriptionCaption4;
  late bool showCaption4InReports;
  late bool showCaption4OnStoreboard;

  late String storeboardStub;

  QuestionGroupSettings() {
    defaultGroupName = '';

    isUseNumber = false;
    showNumberBeforeName = false;

    descriptionCaption1 = '';
    showCaption1InReports = false;
    showCaption1OnStoreboard = false;
    descriptionCaption2 = '';
    showCaption2InReports = false;
    showCaption2OnStoreboard = false;
    descriptionCaption3 = '';
    showCaption3InReports = false;
    showCaption3OnStoreboard = false;
    descriptionCaption4 = '';
    showCaption4InReports = false;
    showCaption4OnStoreboard = false;

    storeboardStub = '';
  }

  Map toJson() => {
        'defaultGroupName': defaultGroupName,
        'isUseNumber': isUseNumber,
        'showNumberBeforeName': showNumberBeforeName,
        'descriptionCaption1': descriptionCaption1,
        'showCaption1InReports': showCaption1InReports,
        'showCaption1OnStoreboard': showCaption1OnStoreboard,
        'descriptionCaption2': descriptionCaption2,
        'showCaption2InReports': showCaption2InReports,
        'showCaption2OnStoreboard': showCaption2OnStoreboard,
        'descriptionCaption3': descriptionCaption3,
        'showCaption3InReports': showCaption3InReports,
        'showCaption3OnStoreboard': showCaption3OnStoreboard,
        'descriptionCaption4': descriptionCaption4,
        'showCaption4InReports': showCaption4InReports,
        'showCaption4OnStoreboard': showCaption4OnStoreboard,
        'storeboardStub': storeboardStub,
      };

  QuestionGroupSettings.fromJson(Map<String, dynamic> json)
      : defaultGroupName = json['defaultGroupName'],
        isUseNumber = json['isUseNumber'],
        showNumberBeforeName = json['showNumberBeforeName'],
        descriptionCaption1 = json['descriptionCaption1'],
        showCaption1InReports = json['showCaption1InReports'],
        showCaption1OnStoreboard = json['showCaption1OnStoreboard'],
        descriptionCaption2 = json['descriptionCaption2'],
        showCaption2InReports = json['showCaption2InReports'],
        showCaption2OnStoreboard = json['showCaption2OnStoreboard'],
        descriptionCaption3 = json['descriptionCaption3'],
        showCaption3InReports = json['showCaption3InReports'],
        showCaption3OnStoreboard = json['showCaption3OnStoreboard'],
        descriptionCaption4 = json['descriptionCaption4'],
        showCaption4InReports = json['showCaption4InReports'],
        showCaption4OnStoreboard = json['showCaption4OnStoreboard'],
        storeboardStub = json['storeboardStub'];
}

class FileSettings {
  late String ip;
  late int port;
  late String downloadPath;
  late String uploadPath;

  late int queueSize;
  late int queueInterval;

  FileSettings() {
    ip = '127.0.0.1';
    port = 27152;
    downloadPath = 'files';
    uploadPath = 'upload';
    queueSize = 3;
    queueInterval = 3000;
  }

  Map toJson() => {
        'ip': ip,
        'port': port,
        'downloadPath': downloadPath,
        'uploadPath': uploadPath,
        'queueSize': queueSize,
        'queueInterval': queueInterval,
      };

  FileSettings.fromJson(Map<String, dynamic> json)
      : ip = json['ip'],
        port = json['port'],
        downloadPath = json['downloadPath'],
        uploadPath = json['uploadPath'],
        queueSize = json['queueSize'],
        queueInterval = json['queueInterval'];
}

class LicenseSettings {
  late String licenseKey;
  late RegExp licenseKeyRegex;

  LicenseSettings() {
    licenseKey = 'xxxxx-xxxxx-xxxxx-xxxxx-xxxxx';
    licenseKeyRegex =
        RegExp(r'\d\d\d\d\d-\d\d\d\d\d-\d\d\d\d\d-\d\d\d\d\d-\d\d\d\d\d');
  }

  Map toJson() => {
        'licenseKey': licenseKey,
      };

  LicenseSettings.fromJson(Map<String, dynamic> json)
      : licenseKey = json['licenseKey'];
}

class SignalsSettings {
  late bool isOperatorPlaySound;
  late bool isStoreboardPlaySound;
  late String hymnStart;
  late String hymnEnd;
  late double systemVolume;

  SignalsSettings() {
    isOperatorPlaySound = false;
    isStoreboardPlaySound = false;
    hymnStart = '';
    hymnEnd = '';
    systemVolume = 100.0;
  }

  Map toJson() => {
        'isOperatorPlaySound': isOperatorPlaySound,
        'isStoreboardPlaySound': isStoreboardPlaySound,
        'hymnStart': hymnStart,
        'hymnEnd': hymnEnd,
        'systemVolume': systemVolume,
      };

  SignalsSettings.fromJson(Map<String, dynamic> json)
      : isOperatorPlaySound = json['isOperatorPlaySound'],
        isStoreboardPlaySound = json['isStoreboardPlaySound'],
        hymnStart = json['hymnStart'],
        hymnEnd = json['hymnEnd'],
        systemVolume = json['systemVolume'];
}

class IntervalsSettings {
  late int defaultRegistrationIntervalId;
  late int defaultVotingIntervalId;
  late int defaultSpeakerIntervalId;
  late int defaultAskWordQueueIntervalId;

  IntervalsSettings() {
    defaultRegistrationIntervalId = 0;
    defaultVotingIntervalId = 0;
    defaultSpeakerIntervalId = 0;
    defaultAskWordQueueIntervalId = 0;
  }

  Map toJson() => {
        'defaultRegistrationIntervalId': defaultRegistrationIntervalId,
        'defaultVotingIntervalId': defaultVotingIntervalId,
        'defaultSpeakerIntervalId': defaultSpeakerIntervalId,
        'defaultAskWordQueueIntervalId': defaultAskWordQueueIntervalId
      };

  IntervalsSettings.fromJson(Map<String, dynamic> json)
      : defaultRegistrationIntervalId = json['defaultRegistrationIntervalId'],
        defaultVotingIntervalId = json['defaultVotingIntervalId'],
        defaultSpeakerIntervalId = json['defaultSpeakerIntervalId'],
        defaultAskWordQueueIntervalId = json['defaultAskWordQueueIntervalId'];
}
