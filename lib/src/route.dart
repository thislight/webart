import "./request.dart" show Request,Response;
import "./logging.dart" show getLogger;
import "./layer.dart" show Layer;
import "package:uri_template/uri_template.dart";

final logger = getLogger("Router");

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
        this.template = new UriTemplate(getExampleFullURI(reg));
        this.parser = new UriParser(template);
    }
    
    bool accept(Request request){
        String path = getExampleFullURI(request.path);
        if(parser.matches(Uri.parse(path))){
            request.context.register("urlparam", this.contextAdapter);
            return true;
        }
        return false;
    }

    static String getExampleFullURI(String part){
        return "http://example.com$part";
    }

    Map<String,String> contextAdapter(Request request){
        return parser.parse(Uri.parse(getExampleFullURI(request.path)));
    }
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
            if(spec.accept(request)){
                isAccepted = true;
                break;
            }
        }
        return isAccepted;
    }

    Layer buildLayer(){
        return new Layer((Request request){
            if(!accept(request)){
                Response res = request.res;
                if((res.body == null) && (res.statusCode == null)){
                    res.notFound();
                }
            }
        });
    }

    Layer get layer => buildLayer();

}