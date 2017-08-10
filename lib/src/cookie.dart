import "package:shelf_redis_session_store/shelf_cookie.dart" show cookieMiddleware;
import "./plugin.dart" show Plugin;
import "./layer.dart" show FunctionalLayer, Go;
import "./request.dart" show Request;
import "package:shelf/shelf.dart" as shelf;
import 'web.dart' show Application;


final FunctionalLayer CookieLayer = new FunctionalLayer((Request req, Go go){
    shelf.Request rawReq = req.raw;
    req.context.register("cookies", rawReq.context["cookies"]);
    go();
})
    ..setName("CookieLayer");


/// Plugin for cookie support
/// You can get cookies from "cookies" in [Context], for example `request.context("cookies")`
/// But this type is [Map<String, Cookie>] not [Map<String, String>]
/// the key of this cookie plugin implements by [shelf_redis_session_store](https://pub.dartlang.org/packages/shelf_redis_session_store)
class CookiePlugin extends Plugin{
    
    @override
    void init(Application app) {
      app.middlewares.add(cookieMiddleware());
      app.lman.chain.add(CookieLayer);
    }
}
