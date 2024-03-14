class TimeUtil {
  static DateTime getDateTimeNow(int clientTimeOffset) {
    return DateTime.now().add(Duration(milliseconds: clientTimeOffset));
  }
}
