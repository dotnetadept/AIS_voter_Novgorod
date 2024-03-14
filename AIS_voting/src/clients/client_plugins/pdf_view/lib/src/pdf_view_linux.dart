import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'method_channel.dart';
import 'platform_interface.dart';

class PdfViewLinux implements PdfViewPlatform {
  @override
  Widget build({
    int id,
    BuildContext context,
    CreationParams creationParams,
  }) {
    return GtkView(
      viewType: 'plugins.flutter.io/pdfview',
      creationParams:
          MethodChannelPdfViewPlatform.creationParamsToMap(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
      // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
      //   new Factory<OneSequenceGestureRecognizer>(
      //     () => new EagerGestureRecognizer(),
      //   ),
      // ].toSet(),
    );
  }
}
