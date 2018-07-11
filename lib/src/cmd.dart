import 'dart:async' show Future;

typedef Future CommandHandler(Command command);

class Command {
  String command;
  Map<String, dynamic> args;

  Command(this.command, {this.args}) {
    if (args == null) args = const {};
  }

  String toString() => "Command $command -> $args";
}
