import './logging.dart';
import 'dart:async' show Future,Completer,Stream,StreamController;

typedef Future CommandHandler(Command command);

final _clogger = getLogger("Command");
final _brlogger = getLogger("BroadcastResults");

class Command {
  String command;
  Map<String, dynamic> args;
  bool requireResult;
  bool includingLock;

  Command(this.command, {this.args, this.requireResult: false, bool this.includingLock: false}) {
    if (args == null) args = const {};
    if (requireResult) _addBroadcastResultsIfNoHas();
    if (includingLock) args['lock'] = new CommandLock();
  }

    @deprecated
  void complete(dynamic value){
      addResult(value);
  }

  void _addBroadcastResultsIfNoHas(){
      if (args['_broadcastResult'] == null){
          args['_broadcastResult'] = new BroadcastResults();
      }
    }

  void addResult<T>(T value){
      _addBroadcastResultsIfNoHas();
      args['_broadcastResult'].add(value);
  }

  Future<List<T>> getAllResults<T>() async{
      _addBroadcastResultsIfNoHas();
      await waitFor();
      return args['_broadcastResult'].stream.toList();
  }

  Future waitFor(){
      _clogger.finer("Being waited: $this");
      return args['_broadcastResult'].waitUntillFinish();
  }

  String toString() => "$runtimeType(results: $requireResult) $command $args -> ${args['_broadcastResult'] ?? ''}/${args['lock'] ?? ''}";
}


/// Recvice many results by [Stream]
class BroadcastResults<T> {
    StreamController<T> controller;
    Stream<T> get stream => controller.stream;
    Completer _completer;

    BroadcastResults(){
        _completer = new Completer();
        controller = new StreamController<T>();
    }

    void add(T value){
        _brlogger.fine("$value is added to $this");
        controller.add(value);
    }

    Future waitUntillFinish() async{
        return _completer.future;
    }

    void end(){
        _brlogger.finer("$this is Ending");
        _completer.complete();
    }

    String toString() => "$runtimeType: $controller($stream) -> $_completer";
}


/// A future-based lock for waiting some important code run, like singal value
class CommandLock {
    int count;
    Completer _completer;

    CommandLock(){
        count = 0;
        _completer = new Completer();
    }

    Future lock(){
        count++;
        return _completer.future;
    }

    void unlock(){
        count--;
        if (count <= 0)
            _completer.complete();
    }

    String toString() => "$runtimeType(isLocked: ${!_completer.isCompleted})";
}
