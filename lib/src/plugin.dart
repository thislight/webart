import "./web.dart" show Application;
import './logging.dart';
import 'dart:async';

abstract class Plugin{
    void init(Application app);
}


final _mclog = getLogger("MessageChannel");


/// A Channel based on [Stream] can share message among Plugin and main program.  
/// All of [MessageChannel] will be cached, same `name` can get the same [MessageChannel]
class MessageChannel<T>{
  static final Map<String,MessageChannel> _channels = {};

  String name;
  Stream<T> stream;
  StreamController<T> controller;
  Map<String,ChannelSession> _sessions;
  
  MessageChannel._init(this.name,{bool sync: false}){
    _mclog.info("MessageChannel $name is created");
    controller = new StreamController<T>.broadcast(sync: sync);
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
  /// argument `sync` will only take effect when the channel is non-cached
  factory MessageChannel(String name, {bool sync: false}){
    if(!_channels.containsKey(name)) return new MessageChannel._init(name,sync: sync);
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
