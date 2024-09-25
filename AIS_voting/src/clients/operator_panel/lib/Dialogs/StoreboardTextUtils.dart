import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';

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
