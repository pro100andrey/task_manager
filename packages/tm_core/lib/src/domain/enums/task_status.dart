enum TaskStatus {
  pending('pending'),
  inProgress('inProgress'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled'),
  onHold('onHold')
  ;

  const TaskStatus(this.value);
  final String value;
}
