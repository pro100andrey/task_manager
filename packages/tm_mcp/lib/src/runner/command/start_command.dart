import 'dart:async';

import 'package:args/command_runner.dart';

class StartCommand extends Command<int> {
  StartCommand();

  @override
  String get description => 'Start the task manager';

  @override
  String get name => 'start';

  @override
  FutureOr<int>? run() => 0;
}
