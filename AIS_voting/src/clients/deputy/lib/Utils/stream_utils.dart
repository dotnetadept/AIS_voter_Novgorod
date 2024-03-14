import 'dart:io';
import 'package:global_configuration/global_configuration.dart';

class StreamUtils {
  Future<void> closeBrowser() async {
    final stopwatch = Stopwatch();
    stopwatch.start();

    try {
      var closeBrowserParams = GlobalConfiguration()
          .getValue('close_browser_command_params')
          .toString()
          .split(';');

      await Process.run(GlobalConfiguration().getValue('close_browser_command'),
          closeBrowserParams);
    } catch (exc) {
      print('${DateTime.now()} Close Chrome Exception: $exc\n');
    } finally {
      stopwatch.stop();
      print('browser stop:${stopwatch.elapsedMilliseconds} ms');
    }
  }

  void startStream() async {
    final stopwatch = Stopwatch();
    stopwatch.start();

    try {
      var startBrowserParams = GlobalConfiguration()
          .getValue('start_browser_command_params')
          .toString()
          .split(';');

      String playerFilePath =
          'file:/${GlobalConfiguration().getValue('folder_path')}/data/flutter_assets/assets/streamPlayer/deputyPlayer.html';
      startBrowserParams.insert(0, playerFilePath);
      Process.run(GlobalConfiguration().getValue('start_browser_command'),
          startBrowserParams);
    } catch (exc) {
      print('${DateTime.now()} Start Chrome Exception: $exc\n');
    } finally {
      stopwatch.stop();
      print('browser start:${stopwatch.elapsedMilliseconds} ms');
    }
  }
}
