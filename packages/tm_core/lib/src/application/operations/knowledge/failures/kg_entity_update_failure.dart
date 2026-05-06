sealed class KgEntityUpdateFailure {
  const KgEntityUpdateFailure();
}

final class KgEntityUpdateNotFound extends KgEntityUpdateFailure {
  const KgEntityUpdateNotFound(this.entityId);
  final String entityId;
}

final class KgEntityUpdateInvalidEntityType extends KgEntityUpdateFailure {
  const KgEntityUpdateInvalidEntityType(this.value);
  final String value;
}

final class KgEntityUpdateInvalidContent extends KgEntityUpdateFailure {
  const KgEntityUpdateInvalidContent(this.reason);
  final String reason;
}
