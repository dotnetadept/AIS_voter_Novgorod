enum SystemState {
  None,
  MeetingPreparation,
  MeetingPreparationComplete,
  MeetingStarted,
  Registration,
  RegistrationComplete,
  QuestionLocked,
  QuestionVoting,
  QuestionVotingComplete,
  AskWordQueue,
  AskWordQueueCompleted,
  MeetingCompleted,
}

enum StoreboardState {
  None,
  CustomText,
  Speaker,
  Break,
  Template,
  History,
  Started,
  Completed,
}

class SystemStateHelper {
  static bool isStarted(SystemState? systemState) {
    if (systemState != null &&
        systemState != SystemState.None &&
        systemState != SystemState.MeetingPreparation &&
        systemState != SystemState.MeetingPreparationComplete &&
        systemState != SystemState.MeetingCompleted) {
      return true;
    }

    return false;
  }

  static bool isPreparation(SystemState? systemState) {
    if (systemState != SystemState.None &&
        systemState == SystemState.MeetingPreparation) {
      return true;
    }

    return false;
  }
}
