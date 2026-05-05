enum TaskContextState {
  active('active'),
  backlog('backlog'),
  inReview('in_review'),
  archived('archived')
  ;

  const TaskContextState(this.value);
  final String value;
}
