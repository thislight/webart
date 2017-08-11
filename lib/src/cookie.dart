library web.support.cookie;
import "package:shelf_redis_session_store/shelf_cookie.dart" show cookieMiddleware;
import "./plugin.dart" show Plugin;
import "./layer.dart" show FunctionalLayer, Go;
import "./request.dart" show Request;
import 'web.dart' show Application;


final FunctionalLayer CookieLayer = new FunctionalLayer((Request req, Go go){
    req.context.register("cookies", (Request req) => req.raw.context["cookies"]);
    go();
})
    ..setName("CookieLayer");


/// Plugin for cookie support
/// * The plugin is broken!!!! DO NOT USE IT NOW! *  
/// Because the cookie part of "shelf_redis_session_store" is no use.  
/// Before anyone incluing me fix it, it will leave preload plugin.  
/// :-( thisLight 2017/08/11
/// 
/// You can get cookies from "cookies" in [Context], for example `request.context("cookies")`.
/// 
/// But this type is [Map<String, Cookie>] not [Map<String, String>] ([Cookie] class from [dart:io]).
/// 
/// the key of this cookie plugin implements by [shelf_redis_session_store](https://pub.dartlang.org/packages/shelf_redis_session_store).
/// 
/// This plugin is preload plugin, will use when [Application] init.
/// 
/// You don't need use it by yourself, if you do, maybe something happened(Who care?)
class CookiePlugin extends Plugin{
    
    @override
    void init(Application app) {
      app.middlewares.add(cookieMiddleware());
      app.lman.chain.add(CookieLayer);
    }
}
