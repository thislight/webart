import './logging.dart';
import 'dart:async' show Future,Completer,Stream,StreamController;

typedef Future CommandHandler(Command command);

final _clogger = getLogger("Command");
final _brlogger = getLogger("BroadcastResults");

class Command<T> {
  String command;
  Map<String, dynamic> args;
  BroadcastResults<T> broadcastResult;
  bool requireResult;

  Command(this.command, {this.args, this.requireResult: true}) {
    if (args == null) args = const {};
    if (requireResult) _addBroadcastResultsIfNoHas();
  }

    @deprecated
  void complete(dynamic value){
      addResult(value);
  }

  void _addBroadcastResultsIfNoHas(){
      if (broadcastResult == null){
          broadcastResult = new BroadcastResults<T>();
      }
    }

  void addResult(T value){
      _addBroadcastResultsIfNoHas();
      broadcastResult.add(value);
  }

  Future<List<T>> get allResults async{
      _addBroadcastResultsIfNoHas();
      await waitFor();
      return broadcastResult.stream.toList();
  }

  Future waitFor(){
      _clogger.finer("Being waited: $this");
      return broadcastResult.waitUntillFinish();
  }

  String toString() => "$runtimeType(results: $requireResult) $command $args -> $broadcastResult";
}


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
