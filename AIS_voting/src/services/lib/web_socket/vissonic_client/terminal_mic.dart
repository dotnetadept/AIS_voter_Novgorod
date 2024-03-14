class TerminalMic {
  String terminalId;
  int micId;
  bool isUnblockedMic;

  TerminalMic(this.terminalId, this.micId, this.isUnblockedMic);

  Map toJson() => {
        'terminalId': terminalId,
        'micId': micId,
        'isUnblockedMic': isUnblockedMic,
      };
}
