// represents single command to vissonic server
class VissonicCommand {
  final List<int> _command;
  final List<int> _responce;

  VissonicCommand(this._command, this._responce);

  List<int> getComand() {
    return _command;
  }

  bool isSame(List<int> responce) {
    var result = false;

    if (responce.length == _responce.length &&
        responce[0] == _responce[0] &&
        responce[1] == _responce[1] &&
        responce[2] == _responce[2] &&
        responce[3] == _responce[3] &&
        responce[4] == _responce[4]) {
      result = true;
    }

    return result;
  }
}
