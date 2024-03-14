import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'platform_interface.dart';
import 'pdf_view_linux.dart';

/// A pdf view widget for showing pdf content.
class PdfView extends StatefulWidget {
  /// Creates a new pdf view.
  ///
  /// The pdf view can be controlled using a `PdfViewController` that is passed to the
  /// `onPdfViewCreated` callback once the pdf view is created.
  ///
  /// The `header` and `uri` parameters must not be null.
  const PdfView({
    Key key,
    this.uri,
    this.page,
  }) : super(key: key);

  static PdfViewPlatform platform = PdfViewLinux();

  final String uri;
  final String page;

  @override
  State<StatefulWidget> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  @override
  Widget build(BuildContext context) {
    return PdfView.platform.build(
      context: context,
      creationParams: _creationParamsFromWidget(widget),
    );
  }
}

CreationParams _creationParamsFromWidget(PdfView widget) {
  return CreationParams(
    uri: widget.uri,
    page: widget.page,
  );
}
