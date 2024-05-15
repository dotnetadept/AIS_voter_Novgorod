import 'vissonic_command.dart';
import 'vissonic_basic_command.dart';

// represents single vissonic mic with it's state
// contains local and server values with timestamps for logging
// only server values counts as real mic values
// inits with _isEnabledState == null
// cause we don't recieve any mic state at initialization
class TerminalMic {
  String terminalId;
  int micId;

  bool isUnblockedMic = false;
  bool? _isEnabled;
  bool _isWaiting = false;
  bool _isSound = false;
  int _timeOffset = 0;
  String startTime = getDateTimeNow(0).toIso8601String();

  TerminalMic(this.terminalId, this.micId, this.startTime);

  static DateTime getDateTimeNow(int clientTimeOffset) {
    return DateTime.now().add(Duration(milliseconds: clientTimeOffset));
  }

  void setIsEnabled(bool? isEnabled) {
    _isEnabled = isEnabled;
  }

  void setIsWaiting(bool isWaiting) {
    _isWaiting = isWaiting;
  }

  bool getIsWaiting() {
    return _isWaiting;
  }

  void setIsSound(bool isSound) {
    // if sound enabled then state enabled anyway
    if (isSound) {
      setIsEnabled(true);
    }

    // if sound changed waiting is over anyway
    setIsWaiting(false);

    _isSound = isSound;

    // set start time
    startTime = getDateTimeNow(_timeOffset).toIso8601String();
  }

  bool getIsSound() {
    return _isSound;
  }

  List<VissonicCommand> processSetMicSound(bool isSound) {
    var commands = <VissonicCommand>[];

    // change sound if it not same or mic waiting
    if (_isSound != isSound || _isWaiting == true) {
      // enable mic state of disabled mics before set sound
      if (isSound) {
        var stateCommand = processSetMicEnabled(true);
        if (stateCommand != null) {
          commands.add(stateCommand);
        }
      }
      // set mic sound
      commands.add(VissonicBasicCommand.setMicSound(micId.toString(), isSound));
    }

    return commands;
  }

  VissonicCommand? processSetMicEnabled(bool isEnabled) {
    VissonicCommand? command;

    // do not set state on same for optimization purposes
    if (_isEnabled != isEnabled) {
      command = VissonicBasicCommand.setMicEnabled(micId.toString(), isEnabled);
    }

    return command;
  }

  TerminalMic.fromJson(Map<String, dynamic> json)
      //storeboard and deputy
      : terminalId = json['terminalId'],
        micId = json['micId'],
        isUnblockedMic = json['isUnblockedMic'],
        _timeOffset = json['timeOffset'],
        _isEnabled = null,
        _isWaiting = false,
        _isSound = false;
}
