import "./request.dart" show Request,Response;
import "./logging.dart" show getLogger;
import "./layer.dart" show Layer,GoFunction;
import "package:uri_template/uri_template.dart";
import "package:logging/logging.dart" show Logger;
import "dart:async" show Future;

final Logger _logger = getLogger("Router");

/// The base of RouteSpec
abstract class BaseRouteSpec {
    /// route to target handler, if accepted, return a `true`, else return `false`
    bool accept(Request request);
}

class RouteSpec{
    UriTemplate template;
    UriParser parser;
    Function target;

    RouteSpec(String reg, this.target){
        this.template = new UriTemplate(reg);
        this.parser = new UriParser(template);
    }
    
    Future<bool> accept(Request request) async{
        if(parser.matches(request.url)){
            request.context.register("urlparam", this.contextAdapter);
            await target(request);
            return true;
        }
        return false;
    }

    Map<String,String> contextAdapter(Request request){
        return parser.parse(request.url);
    }

    String toString() => "RouterSpec@${this.hashCode}{ template=$template, target=$target }";
}

class Router {
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

    bool accept(Request request){
        bool isAccepted = false;
        for (RouteSpec spec in rlist){
            if(spec.accept(request) == true){
                isAccepted = true;
                break;
            }
        }
        return isAccepted;
    }

   Layer buildLayer(){
        return new Layer((Request request, GoFunction go) async{
            if(!(await accept(request))) {
                _logger.info("Not Handled: ${request.path}");
                Response res = request.res;
                if((res.body == null) && (res.statusCode == null)){
                    res.error(500,"No body and status code");
                }
                res.finish();
            }
        });
    }

    Layer get layer => buildLayer();

}