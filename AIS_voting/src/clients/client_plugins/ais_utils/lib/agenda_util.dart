import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';

class AgendaUtil {
  static Widget getQuestionDescriptionText(
    Question question,
    double size, {
    bool isAutoSize = false,
    double lineHeight = 1,
    Color textColor = Colors.black87,
    TextAlign textAlign = TextAlign.left,
    double numberFontSize = 22,
    bool withQuestionNumber = false,
    bool showHiddenSections = false,
    List<QuestionGroupSettings> listSettings = null,
  }) {
    if (question == null || question.descriptions == null) {
      return Container();
    }
    var message = <TextSpan>[];

    if (withQuestionNumber) {
      String questionNumber = question.name;

      for (int i = 0; i < listSettings.length; i++) {
        String numberPart =
            question.name.replaceFirst(listSettings[i].defaultGroupName, '');

        var number = int.tryParse(numberPart.trim());

        if (number != null) {
          questionNumber = number.toString();
          break;
        }
      }

      message.add(TextSpan(
          text: questionNumber + '. ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: numberFontSize,
          )));
    }
    for (var description in question.descriptions) {
      if (!description.showOnStoreboard) {
        if (!showHiddenSections) {
          continue;
        }
      }

      message.add(TextSpan(
          text: description.caption,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: !description.showOnStoreboard && showHiddenSections
                ? textColor.withOpacity(0.6)
                : textColor,
          )));
      if (description.caption != null && description.caption.isNotEmpty) {
        message.add(TextSpan(
          text: ' ',
        ));
      }
      message.add(TextSpan(
          text: description.text,
          style: TextStyle(
            color: !description.showOnStoreboard && showHiddenSections
                ? textColor.withOpacity(0.6)
                : textColor,
          )));

      if (description != question.descriptions.last) {
        message.add(TextSpan(text: '\n'));
      }
    }

    if (!isAutoSize) {
      return RichText(
        text: TextSpan(
            style: TextStyle(
              fontSize: size,
              color: textColor,
              height: lineHeight,
            ),
            children: message),
      );
    }

    return AutoSizeText.rich(
      TextSpan(
          style: TextStyle(
            fontSize: size,
            color: textColor,
            height: lineHeight,
          ),
          children: message),
      minFontSize: 0.2,
      stepGranularity: 0.1,
      softWrap: true,
    );
  }

  static String getQuestionDescription(
    Question question, {
    bool isAutoSize = false,
    bool withQuestionNumber = false,
    bool showHiddenSections = false,
    List<QuestionGroupSettings> listSettings = null,
  }) {
    String result = '';
    if (question == null || question.descriptions == null) {
      return result;
    }

    if (withQuestionNumber) {
      String questionNumber = question.name;

      for (int i = 0; i < listSettings.length; i++) {
        String numberPart =
            question.name.replaceFirst(listSettings[i].defaultGroupName, '');

        var number = int.tryParse(numberPart.trim());

        if (number != null) {
          questionNumber = number.toString();
          break;
        }
      }

      result += questionNumber + '. ';
    }
    for (var description in question.descriptions) {
      if (!description.showOnStoreboard) {
        if (!showHiddenSections) {
          continue;
        }
      }

      result += description.caption;

      if (description.caption != null && description.caption.isNotEmpty) {
        result += ' ';
      }

      result += description.text;

      if (description != question.descriptions.last) {
        result += '\n';
      }
    }

    return result;
  }
}

class StoreboardTextUtils {
  Settings _settings;
  StoreboardTextUtils(this._settings);

  Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  int textLinesCount(String text, int maxLines) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                fontSize: _settings
                    .storeboardSettings.questionDescriptionFontSize
                    .toDouble())),
        maxLines: maxLines,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    textPainter.layout(
        maxWidth: _settings.storeboardSettings.getContentWidth().toDouble());

    List<LineMetrics> lines = textPainter.computeLineMetrics();
    return lines.length;
  }

  bool isExceedsLinesCount(String text, int maxLines) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                fontSize: _settings
                    .storeboardSettings.questionDescriptionFontSize
                    .toDouble())),
        maxLines: maxLines,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    textPainter.layout(
        maxWidth: _settings.storeboardSettings.getContentWidth().toDouble());

    return textPainter.didExceedMaxLines;
  }
}
