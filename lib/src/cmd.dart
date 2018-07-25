import 'dart:async' show Future,Completer;

typedef Future CommandHandler(Command command);

class Command {
  String command;
  Map<String, dynamic> args;
  Completer completer;
  Future get future => completer.future;

  Command(this.command, {this.args, bool resultRequired: false}) {
    if (args == null) args = const {};
    if (resultRequired){
      completer = new Completer();
    }
  }

  void complete(dynamic value){
    if (completer != null){
      completer.complete(value);
    }
  }

  String toString() => "Command $command $args -> $completer";
}
