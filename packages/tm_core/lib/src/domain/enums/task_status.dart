enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled'),
  onHold('on_hold')
  ;

  const TaskStatus(this.value);
  final String value;

  bool get isCompleted => this == TaskStatus.completed;
  bool get isTerminal =>
      this == TaskStatus.completed ||
      this == TaskStatus.failed ||
      this == TaskStatus.cancelled;
}
