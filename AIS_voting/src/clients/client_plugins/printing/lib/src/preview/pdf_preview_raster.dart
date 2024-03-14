/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import '../printing.dart';
import '../printing_info.dart';
import '../raster.dart';
import 'pdf_preview.dart';
import 'pdf_preview_page.dart';

/// Raster PDF documents
mixin PdfPreviewRaster on State<PdfPreview> {
  static const _updateTime = Duration(milliseconds: 300);

  /// Configured page format
  PdfPageFormat get pageFormat;

  /// Is the print horizontal
  bool? horizontal;

  /// Resulting pages
  final List<PdfPreviewPage> pages = <PdfPreviewPage>[];

  /// Printing subsystem information
  PrintingInfo? info;

  /// Error message
  Object? error;

  /// Dots per inch
  double dpi = 10;

  var _rastering = false;

  Timer? _previewUpdate;

  @override
  void dispose() {
    _previewUpdate?.cancel();
    super.dispose();
  }

  /// Computed page format
  PdfPageFormat get computedPageFormat => horizontal != null
      ? (horizontal! ? pageFormat.landscape : pageFormat.portrait)
      : pageFormat;

  /// Rasterize the document
  void raster() {
    _previewUpdate?.cancel();
    _previewUpdate = Timer(_updateTime, () {
      final mq = MediaQuery.of(context);
      dpi = (min(mq.size.width - 16, widget.maxPageWidth ?? double.infinity)) *
          mq.devicePixelRatio /
          computedPageFormat.width *
          72;

      _raster();
    });
  }

  Future<void> _raster() async {
    if (_rastering) {
      return;
    }
    _rastering = true;

    Uint8List _doc;

    final _info = info;
    if (_info != null && !_info.canRaster) {
      assert(() {
        if (kIsWeb) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: Exception(
                'Unable to find the `pdf.js` library.\nPlease follow the installation instructions at https://github.com/DavBfr/dart_pdf/tree/master/printing#installing'),
            library: 'printing',
            context: ErrorDescription('while rendering a PDF'),
          ));
        }

        return true;
      }());

      _rastering = false;
      return;
    }

    try {
      _doc = await widget.build(computedPageFormat);
    } catch (exception, stack) {
      InformationCollector? collector;

      assert(() {
        collector = () sync* {
          yield StringProperty('PageFormat', computedPageFormat.toString());
        };
        return true;
      }());

      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'printing',
        context: ErrorDescription('while generating a PDF'),
        informationCollector: collector,
      ));
      setState(() {
        error = exception;
        _rastering = false;
      });
      return;
    }

    if (error != null) {
      setState(() {
        error = null;
      });
    }

    try {
      var pageNum = 0;
      await for (final PdfRaster page in Printing.raster(
        _doc,
        dpi: dpi,
        pages: widget.pages,
      )) {
        if (!mounted) {
          _rastering = false;
          return;
        }
        setState(() {
          if (pages.length <= pageNum) {
            pages.add(PdfPreviewPage(
              page: page,
              pdfPreviewPageDecoration: widget.pdfPreviewPageDecoration,
              pageMargin: widget.previewPageMargin,
            ));
          } else {
            pages[pageNum] = PdfPreviewPage(
              page: page,
              pdfPreviewPageDecoration: widget.pdfPreviewPageDecoration,
              pageMargin: widget.previewPageMargin,
            );
          }
        });

        pageNum++;
      }

      pages.removeRange(pageNum, pages.length);
    } catch (exception, stack) {
      InformationCollector? collector;

      assert(() {
        collector = () sync* {
          yield StringProperty('PageFormat', computedPageFormat.toString());
        };
        return true;
      }());

      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'printing',
        context: ErrorDescription('while rastering a PDF'),
        informationCollector: collector,
      ));

      setState(() {
        error = exception;
      });
    }

    _rastering = false;
  }
}
