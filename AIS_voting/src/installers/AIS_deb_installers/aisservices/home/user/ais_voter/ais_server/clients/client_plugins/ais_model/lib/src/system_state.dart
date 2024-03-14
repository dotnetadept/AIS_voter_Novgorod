enum SystemState {
  Idle,
  MeetingPreparation,
  MeetingPreparationComplete,
  MeetingStarted,
  Registration,
  RegistrationComplete,
  QuestionLocked,
  MeetingIdle,
  QuestionVoting,
  QuestionVotingComplete,
  MeetingCompleted,
  Stream,
}

class SystemStateHelper {
  static bool isStarted(SystemState systemState) {
    if (systemState != null &&
        systemState != SystemState.Idle &&
        systemState != SystemState.MeetingPreparation &&
        systemState != SystemState.MeetingPreparationComplete &&
        systemState != SystemState.MeetingCompleted) {
      return true;
    }

    return false;
  }

  static bool isPreparation(SystemState systemState) {
    if (systemState != null && systemState == SystemState.MeetingPreparation) {
      return true;
    }

    return false;
  }
}
