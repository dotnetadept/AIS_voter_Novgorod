import 'package:global_configuration/global_configuration.dart';
import '../State/AppState.dart';
import '../State/WebSocketConnection.dart';

class Utils {
  bool getIsAskWordButtonDisabled() {
    if (AppState().getServerState().isStreamStarted == true &&
        AppState().getServerState().showAskWordButton != true) {
      return true;
    }

    return false;
  }

  bool showToManager() {
    return AppState().getServerState().showToManager == true;
  }

  bool showBottomPanel() {
    return !getIsAskWordButtonDisabled() ||
        AppState().getServerState().streamControl == 'user';
  }
}
