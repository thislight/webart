import "./request.dart" show Request;
import "./logging.dart" show getLogger;
import './handler.dart';
import "package:uri_template/uri_template.dart";
import "package:logging/logging.dart" show Logger;
import "dart:async" show Future;
import "./plugin.dart" show Plugin;
import './web.dart' show Application;

final Logger _logger = getLogger("Router");


/// The base of RouteSpec
abstract class BaseRouteSpec {
    /// Routing to target handler. if accepted, return a [true] else return `null`
    Future<bool> accept(Request request);
}


class RouteSpec implements BaseRouteSpec{
    UriTemplate template;
    UriParser parser;
    String templateString;
    RequestHandler target;

    RouteSpec(String reg, this.target){
        this.template = new UriTemplate(reg);
        this.parser = new UriParser(template);
        this.templateString = reg;
    }
    
    Future<bool> accept(Request request) async{
        var path = request.url.path;
        if (path == templateString) return true;
        if(parser.matches(request.url)){
            request.context.register("urlparam", this.contextAdapter);
            if (templateString == "" && path != "") return false;
            return true;
        }
        return false;
    }

    Map<String,String> contextAdapter(Request request){
        return parser.parse(request.url);
    }

    String toString() => "RouterSpec@${this.hashCode}{ template=$template, target=$target }";
}


abstract class BaseRouter<T extends BaseRouteSpec>{
    void addSpec(T spec);
    Future<bool> accept(Request request);
}


class Router implements BaseRouter<RouteSpec>{
    List<RouteSpec> rlist;

    Router(this.rlist);

    factory Router.fromList(List<List> list){
        var r = new Router([]);
        list.forEach((List l){
            var reg,target;
            reg = l[0];
            target = l[1];
            r.add(reg,target);
        });
        return r;
    }

    void addSpec(RouteSpec spec){
        _logger.finer("New RouteSpec added: $spec");
        rlist.add(spec);
    }

    void add(String reg, Function target){
        addSpec(new RouteSpec(reg, target));
    }

    Future<bool> accept(Request request) async{
        bool isAccepted = false;
        for (RouteSpec spec in rlist){
            var pass = await spec.accept(request);
            if(pass){
                request.res.handleWith(spec.target);
                isAccepted = true;
                break;
            }
        }
        return isAccepted;
    }
}


class RoutingPlugin implements Plugin{
  void init(Application app){
    if (app.router == null){
      app.router = app.C['router'] ?? new Router(<RouteSpec>[]);
      app.registerCommandHandler("Router.ready", (_) async{
        _logger.finest("Router.ready be touched");
        if (app.router is Router){
          (app.C['routes'] as Map<String,Function>).forEach(
            (k,v) => app.router.addSpec(new RouteSpec(k, v))
          );
        }
      });
    }
  }
}
