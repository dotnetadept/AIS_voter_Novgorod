import 'package:flutter/widgets.dart';

class CreationParams {
  CreationParams({
    this.uri,
    this.page,
  });

  final String uri;
  final String page;

  @override
  String toString() {
    return '$runtimeType(uri: $uri, page: $page)';
  }
}

abstract class PdfViewPlatform {
  Widget build({
    int id,
    BuildContext context,
    CreationParams creationParams,
  });
}
