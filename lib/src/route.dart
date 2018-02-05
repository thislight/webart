import "./request.dart" show Request;
import "./logging.dart" show getLogger;
import "./layer.dart" show FunctionalLayer,Layer;
import './handler.dart';
import "package:uri_template/uri_template.dart";
import "package:logging/logging.dart" show Logger;
import "dart:async" show Future;
import "./plugin.dart" show EventBus;

final Logger _logger = getLogger("Router");


/// The base of RouteSpec
abstract class BaseRouteSpec {
    /// Routing to target handler. if accepted, return a [RequestHandler] else return `null`
    Future<RequestHandler> accept(Request request);
}


class RouteSpec implements BaseRouteSpec{
    UriTemplate template;
    UriParser parser;
    RequestHandler target;

    RouteSpec(String reg, this.target){
        this.template = new UriTemplate(reg);
        this.parser = new UriParser(template);
    }
    
    Future<RequestHandler> accept(Request request) async{
        if(parser.matches(request.url)){
            request.context.register("urlparam", this.contextAdapter);
            await target(request);
            return target;
        }
        return null;
    }

    Map<String,String> contextAdapter(Request request){
        return parser.parse(request.url);
    }

    String toString() => "RouterSpec@${this.hashCode}{ template=$template, target=$target }";
}


abstract class BaseRouter{
    void addSpec(BaseRouteSpec spec);
    Future<bool> accept(Request request);
    Layer get layer;
}


class Router implements BaseRouter{
    List<RouteSpec> rlist;

    Router(this.rlist);

    factory Router.fromList(List list){
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
        rlist.add(spec);
    }

    void add(String reg, Function target){
        addSpec(new RouteSpec(reg, target));
    }

    Future<bool> accept(Request request) async{
        bool isAccepted = false;
        for (RouteSpec spec in rlist){
            var handler = await spec.accept(request);
            if(handler != null){
                request.res.handleWith(handler);
                isAccepted = true;
                break;
            }
        }
        return isAccepted;
    }

   FunctionalLayer buildLayer(){
        return new FunctionalLayer.withName("RoutingLayer",(Request request) async{
            if(!(await accept(request))) {
                _logger.info("Not Handled: ${request.path}");
                await EventBus.happen("router.handlerNotHandled", [request]);
            }
        });
    }

    FunctionalLayer get layer => buildLayer();

}