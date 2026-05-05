enum TaskCompletionPolicy {
  allChildren('all_children'),
  anyChild('any_child'),
  manual('manual')
  ;

  const TaskCompletionPolicy(this.value);
  final String value;
}
