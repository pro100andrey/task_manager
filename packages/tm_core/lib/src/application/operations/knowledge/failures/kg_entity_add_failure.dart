sealed class KgEntityAddFailure {
  const KgEntityAddFailure();
}

final class KgEntityAddProjectNotFound extends KgEntityAddFailure {
  const KgEntityAddProjectNotFound(this.projectId);
  final String projectId;
}

final class KgEntityAddNameAlreadyExists extends KgEntityAddFailure {
  const KgEntityAddNameAlreadyExists(this.normalizedName);
  final String normalizedName;
}

final class KgEntityAddInvalidEntityType extends KgEntityAddFailure {
  const KgEntityAddInvalidEntityType(this.value);
  final String value;
}

final class KgEntityAddInvalidName extends KgEntityAddFailure {
  const KgEntityAddInvalidName(this.reason);
  final String reason;
}

final class KgEntityAddInvalidContent extends KgEntityAddFailure {
  const KgEntityAddInvalidContent(this.reason);
  final String reason;
}
