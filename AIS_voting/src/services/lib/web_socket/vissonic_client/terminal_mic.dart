class TerminalMic {
  String terminalId;
  int micId;
  bool isUnblockedMic;
  int timeOffset;

  TerminalMic(
    this.terminalId,
    this.micId,
    this.isUnblockedMic,
    this.timeOffset,
  );

  Map toJson() => {
        'terminalId': terminalId,
        'micId': micId,
        'isUnblockedMic': isUnblockedMic,
        'timeOffset': timeOffset,
      };
}
