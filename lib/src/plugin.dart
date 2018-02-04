library web.plugin;
import "./web.dart" show Application;
import 'dart:async' show Future;

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


dynamic originBack(Function h) => (List args) async{
    await h(args);
    return args;
};
