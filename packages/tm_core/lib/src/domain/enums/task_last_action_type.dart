enum TaskLastActionType {
  execution('execution'),
  planning('planning'),
  reflection('reflection'),
  review('review')
  ;

  const TaskLastActionType(this.value);
  final String value;
}
