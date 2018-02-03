library web.plugin;
import "./web.dart" show Application;
import 'dart:async' show Future;

abstract class Plugin{
    void init(Application app);
}


typedef void _OnGotFunctionHandler(Function f);


class _FutureEvent{
    _OnGotFunctionHandler _onGotFunctionHandler;
    _FutureEvent(this._onGotFunctionHandler);

    Future then(Function f) async => await this._onGotFunctionHandler(f);
}


class EventBus{
    static final Map<String,List<Function>> _map = new Map();

    static _FutureEvent on(String event){
        if (_map[event]==null){
            _map[event] = new List();
        }
        return new _FutureEvent((f) async{
            List p = await happen("eventbus.newEventHandlerWillBeAdded",[event,f],defReturn: [null,f]);
            _map[event].add(p[1]);
        });
    }

    static dynamic _happen(String event,List args,{defReturn: null}) async{
        if (_map[event]==null) return defReturn;
        if (args == null) args = [];
        for (Function f in _map[event]){
            args = await f(args);
        }
        return args;
    }

    static dynamic happen(String event,List args,{dynamic defReturn: null}) async{
        var v = await _happen(event, args,defReturn: defReturn);
        await _happen("eventbus.newEventHappened", [event]);
        return v;
    }

    static renew(){
        _map.clear();
    }
    
    static print(){
        print("--- Raw Event Bus Output ---");
        print("Current event bus has ${_map.keys.length} event.");
        _map.forEach((k,v){
            print(k);
            v.forEach((val) => print(v));
        });
        print("--- Output End ---");
    }
    
}
