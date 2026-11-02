enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  completed,
  withdrawn;

  bool get isActive => this == pending || this == accepted;

  bool get isFinal => allowedTransitions(this).isEmpty;
}

const _transitions = <ApplicationStatus, Set<ApplicationStatus>>{
  ApplicationStatus.pending: {ApplicationStatus.accepted, ApplicationStatus.rejected, ApplicationStatus.withdrawn},
  ApplicationStatus.accepted: {ApplicationStatus.completed, ApplicationStatus.rejected, ApplicationStatus.withdrawn},
};

bool canTransition(ApplicationStatus from, ApplicationStatus to) => _transitions[from]?.contains(to) ?? false;

Set<ApplicationStatus> allowedTransitions(ApplicationStatus from) => {
  for (final to in ApplicationStatus.values)
    if (canTransition(from, to)) to,
};
