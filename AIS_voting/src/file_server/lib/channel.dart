import 'controllers/document_upload_controller.dart';
import 'ais_file_server.dart';

/// This type initializes an application.
class ServicesChannel extends ApplicationChannel {
  @override
  Future prepare() async {
    RequestBody.maxSize = 1024 * 1024 * 1024;

    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/files/*').link(() => FileController('documents/'));
    router.route('/upload').link(() => DocumentUploadController());

    return router;
  }
}
