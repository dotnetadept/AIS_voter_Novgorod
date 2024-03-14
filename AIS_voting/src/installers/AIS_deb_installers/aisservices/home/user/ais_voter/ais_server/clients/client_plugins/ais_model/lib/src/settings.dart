import 'dart:convert';

class Settings {
  SettingsPallete palletteSettings;
  OperatorSchemeSettings operatorSchemeSettings;
  ManagerSchemeSettings managerSchemeSettings;
  VotingSettings votingSettings;
  StoreboardSettings storeboardSettings;
  SoundSettings soundSettings;
  LicenseSettings licenseSettings;

  Settings() {
    palletteSettings = SettingsPallete();
    operatorSchemeSettings = OperatorSchemeSettings();
    managerSchemeSettings = ManagerSchemeSettings();
    votingSettings = VotingSettings();
    storeboardSettings = StoreboardSettings();
    soundSettings = SoundSettings();
    licenseSettings = LicenseSettings();
  }

  Map toJson() => {
        'palletteSettings': json.encode(palletteSettings.toJson()),
        'operatorSchemeSettings': json.encode(operatorSchemeSettings.toJson()),
        'managerSchemeSettings': json.encode(managerSchemeSettings.toJson()),
        'votingSettings': json.encode(votingSettings.toJson()),
        'storeboardSettings': json.encode(storeboardSettings.toJson()),
        'soundSettings': json.encode(soundSettings.toJson()),
        'licenseSettings': json.encode(licenseSettings.toJson()),
      };

  Settings.fromJson(Map<String, dynamic> json)
      : palletteSettings = json['palletteSettings'] == null
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
        votingSettings = json['votingSettings'] == null
            ? VotingSettings()
            : VotingSettings.fromJson(jsonDecode(json['votingSettings'])),
        storeboardSettings = json['storeboardSettings'] == null
            ? StoreboardSettings()
            : StoreboardSettings.fromJson(
                jsonDecode(json['storeboardSettings'])),
        soundSettings = json['soundSettings'] == null
            ? SoundSettings()
            : SoundSettings.fromJson(jsonDecode(json['soundSettings'])),
        licenseSettings = json['licenseSettings'] == null
            ? LicenseSettings()
            : LicenseSettings.fromJson(jsonDecode(json['licenseSettings']));
}

class SettingsPallete {
  int backgroundColor;
  int schemeBackgroundColor;
  int cellColor;
  int alternateCellColor;
  String alternateRowNumbers;
  int alternateRowPadding;
  String paddingRowNumbers;

  int cellTextColor;
  int cellBorderColor;

  int unRegistredColor;
  int registredColor;
  int voteYesColor;
  int voteNoColor;
  int voteIndifferentColor;
  int askWordColor;
  int onSpeechColor;

  int buttonTextColor;

  int iconOnlineColor;
  int iconOfflineColor;
  int iconDocumentsDownloadedColor;
  int iconDocumentsNotDownloadedColor;

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
  bool inverseScheme;
  bool controlSound;

  int cellWidth;
  int cellBorder;
  int cellInnerPadding;
  int cellOuterPaddingVertical;
  int cellOuterPaddingHorisontal;

  bool isShortNamesUsed;
  int cellTextSize;

  String overflowOption;
  int textMaxLines;
  bool showOverflow;

  int iconSize;

  OperatorSchemeSettings() {
    inverseScheme = false;
    controlSound = true;
    cellWidth = 200;
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
        'cellWidth': cellWidth,
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
        cellWidth = json['cellWidth'],
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
  bool inverseScheme;
  bool controlSound;

  int cellWidth;
  int cellBorder;
  int cellInnerPadding;
  int cellOuterPaddingVertical;
  int cellOuterPaddingHorisontal;

  bool isShortNamesUsed;
  int cellTextSize;
  String overflowOption;
  int textMaxLines;
  bool showOverflow;

  int deputyFontSize;
  int deputyNumberFontSize;
  int deputyCaptionFontSize;
  int deputyFilesListHeight;

  int iconSize;

  ManagerSchemeSettings() {
    inverseScheme = false;
    controlSound = true;
    cellWidth = 200;
    cellBorder = 1;
    cellInnerPadding = 10;
    cellOuterPaddingVertical = 20;
    cellOuterPaddingHorisontal = 10;
    isShortNamesUsed = false;
    cellTextSize = 14;
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
        'cellWidth': cellWidth,
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
        'deputyFontSize': deputyFontSize,
        'deputyNumberFontSize': deputyNumberFontSize,
        'deputyCaptionFontSize': deputyCaptionFontSize,
        'deputyFilesListHeight': deputyFilesListHeight,
      };

  ManagerSchemeSettings.fromJson(Map<String, dynamic> json)
      : inverseScheme = json['inverseScheme'],
        controlSound = json['controlSound'],
        cellWidth = json['cellWidth'],
        cellBorder = json['cellBorder'],
        cellInnerPadding = json['cellInnerPadding'],
        cellOuterPaddingVertical = json['cellOuterPaddingVertical'],
        cellOuterPaddingHorisontal = json['cellOuterPaddingHorisontal'],
        isShortNamesUsed = json['isShortNamesUsed'],
        cellTextSize = json['cellTextSize'],
        overflowOption = json['overflowOption'],
        textMaxLines = json['textMaxLines'],
        showOverflow = json['showOverflow'],
        iconSize = json['iconSize'],
        deputyFontSize = json['deputyFontSize'],
        deputyNumberFontSize = json['deputyNumberFontSize'],
        deputyCaptionFontSize = json['deputyCaptionFontSize'],
        deputyFilesListHeight = json['deputyFilesListHeight'];
}

class VotingSettings {
  bool isVotingFixed;
  int defaultRegistrationInterval;
  int defaultVotingInterval;
  int defaultShowResultInterval;
  String defaultNewQuestionName;
  String defaultFirstQuestionName;
  String defaultFirstQuestionVotingName;
  String defaultQuestionNumberPrefix;
  bool isFirstQuestionUseNumber;
  String reportsFolderPath;

  int defaultVotingModeId;

  VotingSettings() {
    isVotingFixed = true;
    defaultRegistrationInterval = 300;
    defaultVotingInterval = 300;
    defaultShowResultInterval = 10;
    defaultNewQuestionName = 'Вопрос';
    defaultFirstQuestionName = 'Процедурные вопросы';
    defaultFirstQuestionVotingName = 'процедурным вопросам';
    defaultQuestionNumberPrefix = '';
    isFirstQuestionUseNumber = false;
    defaultVotingModeId = null;
    reportsFolderPath = '';
  }

  Map toJson() => {
        'isVotingFixed': isVotingFixed,
        'defaultRegistrationInterval': defaultRegistrationInterval,
        'defaultVotingInterval': defaultVotingInterval,
        'defaultShowResultInterval': defaultShowResultInterval,
        'defaultNewQuestionName': defaultNewQuestionName,
        'defaultFirstQuestionName': defaultFirstQuestionName,
        'defaultFirstQuestionVotingName': defaultFirstQuestionVotingName,
        'defaultQuestionNumberPrefix': defaultQuestionNumberPrefix,
        'isFirstQuestionUseNumber': isFirstQuestionUseNumber,
        'defaultVotingModeId': defaultVotingModeId,
        'reportsFolderPath': reportsFolderPath,
      };

  VotingSettings.fromJson(Map<String, dynamic> json)
      : isVotingFixed = json['isVotingFixed'],
        defaultRegistrationInterval = json['defaultRegistrationInterval'],
        defaultVotingInterval = json['defaultVotingInterval'],
        defaultShowResultInterval = json['defaultShowResultInterval'],
        defaultNewQuestionName = json['defaultNewQuestionName'],
        defaultFirstQuestionName = json['defaultFirstQuestionName'],
        defaultFirstQuestionVotingName = json['defaultFirstQuestionVotingName'],
        defaultQuestionNumberPrefix = json['defaultQuestionNumberPrefix'],
        isFirstQuestionUseNumber = json['isFirstQuestionUseNumber'],
        defaultVotingModeId = json['defaultVotingModeId'],
        reportsFolderPath = json['reportsFolderPath'];
}

class StoreboardSettings {
  int backgroundColor;
  int textColor;

  int height;
  int width;
  int padding;

  String meetingDescriptionTemplate;
  int speakerInterval;
  int breakInterval;

  int meetingDescriptionFontSize;
  int meetingFontSize;
  int groupFontSize;

  int customCaptionFontSize;
  int customTextFontSize;

  int resultItemsFontSize;
  int resultTotalFontSize;
  int timersFontSize;

  int questionNameFontSize;
  int questionDescriptionFontSize;
  bool justifyQuestionDescription;
  //int questionDescriptionMaxLinesOnDiscus;
  //int questionDescriptionMaxLinesOnVoting;

  int clockFontSize;
  bool clockFontBold;

  int detailsAnimationDuration;
  int detailsRowsCount;
  int detailsFontSize;

  StoreboardSettings() {
    backgroundColor = 0xff010066;
    textColor = 0xffffffff;
    height = 300;
    width = 420;
    padding = 10;
    meetingDescriptionTemplate = '''Очередное
пленарное заседание
Законодательного собрания
Краснодарского Края шестого созыва''';
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
    //questionDescriptionMaxLinesOnDiscus = 13;
    //questionDescriptionMaxLinesOnVoting = 9;

    clockFontSize = 14;
    clockFontBold = false;

    detailsAnimationDuration = 3;
    detailsRowsCount = 10;
    detailsFontSize = 18;
  }

  Map toJson() => {
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'height': height,
        'width': width,
        'padding': padding,
        'meetingDescriptionTemplate': meetingDescriptionTemplate,
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
        //'questionDescriptionMaxLinesOnDiscus':
        //    questionDescriptionMaxLinesOnDiscus,
        //'questionDescriptionMaxLinesOnVoting':
        //    questionDescriptionMaxLinesOnVoting,

        'clockFontSize': clockFontSize,
        'clockFontBold': clockFontBold,

        'detailsAnimationDuration': detailsAnimationDuration,
        'detailsRowsCount': detailsRowsCount,
        'detailsFontSize': detailsFontSize,
      };

  StoreboardSettings.fromJson(Map<String, dynamic> json)
      : backgroundColor = json['backgroundColor'],
        textColor = json['textColor'],
        height = json['height'],
        width = json['width'],
        padding = json['padding'],
        //
        meetingDescriptionTemplate = json['meetingDescriptionTemplate'],
        speakerInterval = json['speakerInterval'],
        breakInterval = json['breakInterval'],
        //
        meetingDescriptionFontSize = json['meetingDescriptionFontSize'],
        meetingFontSize = json['meetingFontSize'],
        groupFontSize = json['groupFontSize'],
        //
        customCaptionFontSize = json['customCaptionFontSize'],
        customTextFontSize = json['customTextFontSize'],
        //
        resultItemsFontSize = json['resultItemsFontSize'],
        resultTotalFontSize = json['resultTotalFontSize'],
        timersFontSize = json['timersFontSize'],
        //
        questionNameFontSize = json['questionNameFontSize'],
        questionDescriptionFontSize = json['questionDescriptionFontSize'],
        justifyQuestionDescription = json['justifyQuestionDescription'],
        //questionDescriptionMaxLinesOnDiscus =
        //    json['questionDescriptionMaxLinesOnDiscus'],
        //questionDescriptionMaxLinesOnVoting =
        //    json['questionDescriptionMaxLinesOnVoting'],
        clockFontSize = json['clockFontSize'],
        clockFontBold = json['clockFontBold'],
        //
        detailsAnimationDuration = json['detailsAnimationDuration'],
        detailsRowsCount = json['detailsRowsCount'],
        detailsFontSize = json['detailsFontSize'];

  int getContentWidth() {
    return width - padding * 2;
  }
}

class LicenseSettings {
  String licenseKey;
  RegExp licenseKeyRegex;

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

class SoundSettings {
  String registrationStart;
  String registrationEnd;
  String votingStart;
  String votingEnd;
  String hymnStart;
  String hymnEnd;
  String defaultStreamUrl;

  SoundSettings() {
    registrationStart = '';
    registrationEnd = '';
    votingStart = '';
    votingEnd = '';
    hymnStart = '';
    hymnEnd = '';
    defaultStreamUrl = '';
  }

  Map toJson() => {
        'registrationStart': registrationStart,
        'registrationEnd': registrationEnd,
        'votingStart': votingStart,
        'votingEnd': votingEnd,
        'hymnStart': hymnStart,
        'hymnEnd': hymnEnd,
        'defaultStreamUrl': defaultStreamUrl,
      };

  SoundSettings.fromJson(Map<String, dynamic> json)
      : registrationStart = json['registrationStart'],
        registrationEnd = json['registrationEnd'],
        votingStart = json['votingStart'],
        votingEnd = json['votingEnd'],
        hymnStart = json['hymnStart'],
        hymnEnd = json['hymnEnd'],
        defaultStreamUrl = json['defaultStreamUrl'];
}
