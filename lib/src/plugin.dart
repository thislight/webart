import "./web.dart" show Application;
import './logging.dart';
import 'dart:async';

abstract class Plugin{
    void init(Application app);
}


typedef void _OnGotFunctionHandler(String event,EventHandler f);


typedef List<dynamic> EventHandler(List<dynamic> args);


class _FutureEvent{
    _OnGotFunctionHandler _onGotFunctionHandler;
    String _event;
    _FutureEvent(this._event, this._onGotFunctionHandler);

    Future then(Function f) async => await this._onGotFunctionHandler(_event, f);
}


@deprecated
class _EventBus{
    Map<String,List<EventHandler>> _map;

    _EventBus(){
        _map = {};
    }

    _FutureEvent on(String event){
        return new _FutureEvent(event,(String e,EventHandler f){
            if (_map[e]==null){
                _map[e] = [];
            }
            happen("eventbus.newEventHandlerWillBeAdded",[event,f]);
            _map[e].add(f);
        });
    }

    dynamic _happen(String event,List args,{defReturn: null}) async{
        if (_map[event]==null) return defReturn;
        if (args == null) args = [];
        for (EventHandler f in _map[event]){
            args = await f(args);
        }
        return args;
    }

    dynamic happen(String event,List args,{dynamic defReturn: null}) async{
        var v = await _happen(event, args,defReturn: defReturn);
        await _happen("eventbus.newEventHappened", [event]);
        return v;
    }

    void renew(){
        _map.clear();
    }
    
    void printInfo(){
        print("--- Raw Event Bus Output ---");
        print("Current event bus has ${_map.keys.length} event.");
        _map.forEach((k,v){
            print("$k:");
            v.forEach((val) => print("  $v"));
        });
        print("--- Output End ---");
    }
    
}


final _EventBus EventBus = new _EventBus();


final _mclog = getLogger("MessageChannel");


/// A Channel based on [Stream] can share message among Plugin and main program.  
/// All of [MessageChannel] will be cached, same `name` can get the same [MessageChannel]
class MessageChannel<T>{
  static final Map<String,MessageChannel> _channels = {};

  String name;
  Stream<T> stream;
  StreamController<T> controller;
  Map<String,ChannelSession> _sessions;
  
  MessageChannel._init(this.name){
    _mclog.info("MessageChannel $name is created");
    controller = new StreamController<T>.broadcast();
    _sessions = {};
    stream = controller.stream;
    _channels[name] = this;
    stream.listen((data){
      if (data is ChannelSessionMessage){
        _handleSessionMessage(data);
      }
    });
  }

  /// Handling recviced [ChannelSessionMessage], routing to [ChannelSession]
  _handleSessionMessage(ChannelSessionMessage data){
    _mclog.finest("Recvice a ChannelSessionMessage $data");
    var key = data.key;
    if (_sessions.containsKey(key)){
      _sessions[key].input.add(data);
    }
  }

  /// If the channel of `name` is cached, return the cached one, if not, return a new one.
  factory MessageChannel(String name){
    if(!_channels.containsKey(name)) return new MessageChannel._init(name);
    return _channels[name];
  }

  /// Add a value to stream
  void send(T v){
    _mclog.finest("Send a message $v");
    controller.add(v);
  }

  /// Register a [ChannelSession] to [MessageChannel]  
  /// [MessageChannel] use `key` of [ChannelSeesion] to distinguish [ChannelSeesion]
  void registerSession(ChannelSession session){
    _mclog.finest("ChannelSession $session is registered to $name");
    _sessions[session.key] = session;
  }

  ChannelSession getSession(String key) => _sessions[key];

  String toString() => "$name";
}


class ChannelSession<T>{
  MessageChannel<ChannelSessionMessage<T>> messageChannel;
  String key;
  StreamController<ChannelSessionMessage<T>> input;
  Stream<T> stream;

  ChannelSession(this.messageChannel){
    key = hashCode.toString();
    input = new StreamController.broadcast();
    stream = _buildInputStream();
  }

  _buildInputStream(){
    return input.stream.transform(
      new StreamTransformer<ChannelSessionMessage<T>,T>.fromHandlers(
      handleData: (ChannelSessionMessage<T> message,EventSink<T> sink){
        sink.add(message.message);
      }
    ));
  }

  void send(T v){   
    messageChannel.send(new ChannelSessionMessage<T>(this.key,v));
  }

  String toString() => "${messageChannel}:$key";
}


class ChannelSessionMessage<T>{
  String key;
  T message;

  ChannelSessionMessage(this.key,this.message);

  String toString() => "$key|$message";
}


dynamic originBack(Function h) => (List args) async{
    await h(args);
    return args;
};
