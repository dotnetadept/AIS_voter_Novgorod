import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:aqueduct/aqueduct.dart';
import 'package:mime/mime.dart';
import 'package:services/services.dart';
import 'package:http_server/http_server.dart';

class DocumentUploadController extends ResourceController {
  DocumentUploadController() {
    acceptedContentTypes = [ContentType('multipart', 'form-data')];
  }

  @Operation.post()
  Future<Response> postForm() async {
    final transformer = MimeMultipartTransformer(
        request.raw.headers.contentType.parameters['boundary']);
    final bodyStream =
        Stream.fromIterable([await request.body.decode<List<int>>()]);
    final parts = await transformer.bind(bodyStream).toList();

    if (parts.length == 3) {
      // Parse agendaName param
      var agendaFolderName = utf8
          .decode(await parts[0].cast<Uint8List>().asBroadcastStream().first);
      // Parse folderName param
      var folderName = utf8
          .decode(await parts[1].cast<Uint8List>().asBroadcastStream().first);
      // Parse fileName param
      var fileName = parts[2]
          .headers
          .values
          .last
          .replaceAll('form-data; name=\"file\"; filename=\"', '');
      fileName = fileName.substring(0, fileName.length - 1);
      // Save uploaded file
      var multipart = HttpMultipartFormData.parse(parts[2]);
      final content = multipart.cast<List<int>>().asBroadcastStream();
      final filePath =
          'documents/' + agendaFolderName + '/' + folderName + '/' + fileName;

      File(filePath).createSync(recursive: true);

      final sink = File(filePath).openWrite();
      await for (List<int> item in content) {
        sink.add(item);
      }

      await sink.flush();
      await sink.close();
    }

    return Response.ok({});
  }
}
