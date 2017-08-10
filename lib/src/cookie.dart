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


class CookiePlugin extends Plugin{
    
    @override
    void init(Application app) {
      app.middlewares.add(cookieMiddleware());
      app.lman.chain.add(CookieLayer);
    }
}
