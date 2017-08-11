library web.support.session;
import "package:flake_uuid/flake_uuid.dart";
import "layer.dart" show FunctionalLayer,Go;
import "plugin.dart" show Plugin;
import "request.dart" show Request;
import "dart:io" show Cookie;
import "web.dart" show Application;
import "logging.dart" show getLogger;
import "package:logging/logging.dart" show Logger;


final Logger _logger = getLogger("Session");


const String _SESSIONID = "sessionId";


const String _CONTEXTNAME = "session";


class Session{
    Map<String, dynamic> storage;
    String _id;

    Session(this._id,this.storage);

    Session.randomId(this.storage){
        this._id = flake128.nextHex();
    }

    dynamic operator[](String key) => storage[key];
    void operator[]=(String key, dynamic val) => storage[key] = val;

    String get id => _id;
}


abstract class SessionAdapter{
    Session getById(String id);
    void removeById(String id);
    Session create();
    bool has(String id);
}


class SessionManager{
    SessionAdapter adapter;

    SessionManager(this.adapter);

    Session get(String id){
        return adapter.getById(id);
    }

    void remove(String id){
        adapter.removeById(id);
    }

    Session create() => adapter.create();

    Session operator[](String id) => get(id);
}


class DefaultSessionAdapter extends SessionAdapter{
    Map<String,Session> storage;

    DefaultSessionAdapter(this.storage);

    DefaultSessionAdapter.empty() : this({});

    @override
    Session create() {
      Session s = new Session.randomId({});
      storage[s.id] = s;
      return s;
    }

    @override
    Session getById(String id) {
      return storage[id];
    }

    @override
    bool has(String id) {
      return storage.containsKey(id);
    }

    @override
    void removeById(String id){
        storage.remove(id);
    }
}


final FunctionalLayer SessionLayer = new FunctionalLayer.withName("SessionLayer", (Request req, Go go){
    SessionManager manager = req.state.memories["sessionManager"];
    Map<String, Cookie> cookies = req.context("cookies");
    Session sess;
    if (!cookies.containsKey(_SESSIONID)){
        sess = manager.create();
        cookies[_SESSIONID] = new Cookie(_SESSIONID, sess.id);
        _logger.info("New Session ${sess.id}");
    } else {
        sess = manager.get(cookies[_SESSIONID].value);
        _logger.info("Session ${sess.id}");
    }

    req.context.register(_CONTEXTNAME,(_) => sess);

    go();
});


/// *DON'T USE IT NOW!*  
/// Because this plugin required the Cookie Plugin, but that is broken.  
/// if has any plugin can register a context "cookies" that will return a [Map<String, Cookie>], this plugin will work again.
/// :) thisLight 2017/08/11
/// 
/// Apply change of session support to [Application].
/// Must use after [CookiePlugin]([CookiePlugin] will be used when [Application] init).  
/// It is not a preload plugin, you must use it by yourself.  
/// For example:
/// ````dart
/// Application app = new Application(...);
/// app.use(new SessionPlugin());
/// ````
/// 
/// This plugin will get a [SessionAdapter] from config item "sessionAdapter", if no set,
/// will use [DefaultSessionAdapter], it store values to memories by dart's [Map] object.
/// 
/// You can get [Session] object in handlers.  
/// For example:
/// ````dart
/// void exampleHandler(Request req){
///     Session session = req.context("session");
///     ...Do Something Else...
/// }
/// ````
class SessionPlugin extends Plugin{
    void init(Application app){
        SessionAdapter adapter;
        if (app.C.rawMap.containsKey("sessionAdapter")){
            adapter = app.C.rawMap["sessionAdapter"];
        } else {
            adapter = new DefaultSessionAdapter.empty();
        }

        SessionManager manager = new SessionManager(adapter);

        app.lman.chain.global["sessionManager"] = manager;

        app.lman.chain.add(SessionLayer);
    }
}


// TODO : implement RedisSessionAdapter
// class RedisSessionAdapter extends SessionAdapter{}
