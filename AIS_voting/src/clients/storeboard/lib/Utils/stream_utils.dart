import 'dart:io';
import 'package:global_configuration/global_configuration.dart';

class StreamUtils {
  Future<void> closeBrowser() async {
    try {
      Process.run(
          GlobalConfiguration().getValue('close_browser_command'),
          GlobalConfiguration()
              .getValue('close_browser_command_params')
              .toString()
              .split(';'));
    } catch (exc) {
      print('${DateTime.now()} Close Chrome Exception: $exc\n');
    }
  }

  Future<void> startStream() async {
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
    }
  }

  Future<void> refreshStream() async {
    await closeBrowser();
    await startStream();
  }
}
