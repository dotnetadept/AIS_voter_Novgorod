import 'platform_interface.dart';

/// A [PdfViewPlatformController] that uses a method channel to control the pdf_view.
class MethodChannelPdfViewPlatform {
  static Map<String, dynamic> creationParamsToMap(
      CreationParams creationParams) {
    return <String, dynamic>{
      'uri': creationParams.uri,
      'page': creationParams.page,
    };
  }
}
