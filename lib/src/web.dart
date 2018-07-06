import "dart:async" show Future;
import "./layer.dart";
import "./logging.dart" show getLogger;
import "./config.dart" show Config;
import "./request.dart" show Request, buildRawResponse;
import "./plugin.dart" show Plugin, MessageChannel;
import "./route.dart" show Router,RouteSpec;
import "package:shelf/shelf.dart" as shelf;
import "package:shelf/shelf_io.dart" as io;
import "package:logging/logging.dart" show Logger;


final Logger _logger = getLogger("Application");


class Application {
    LayerManager lman;
    List<shelf.Middleware> middlewares;
    MessageChannel channel;
    Router router;
    Config C;
    bool isDebug = false;

    Application(this.C){
        lman = new LayerManager();
        middlewares = <shelf.Middleware>[];
        channel = new MessageChannel("ApplicationMain");
        this._initRouter();
        this._loadConfigsRoute();
        this._usePreloadPlugin();
        this._checkIfDebug();
    }

    Future<shelf.Response> handler(shelf.Request raw) async{
        LayerState currState = lman.newState;
        Request request = new Request(raw,currState,this);
        await currState.start([request]);
        return await buildRawResponse(request.response);
    }

    Future start(String address, int port) async{
        return io.serve(buildHandler(),address,port);
    }

    buildHandler(){
        _logger.info("Building handler");
        var pl = const shelf.Pipeline();
        middlewares.forEach((shelf.Middleware m){
            pl = pl.addMiddleware(m);
        });
            pl = pl.addHandler(this.handler);
        return pl;
    }

    void use(Plugin p){
        _logger.info("Using Plugin@${p.hashCode}");
        p.init(this);
    }

    void _addRouteLayer(){
        lman.chain.add(router.layer);
    }

    void _loadRouteSpecFromConfig(){
        C["routes"].forEach((String key,Function target){
            router.add(key, target);
        });
    }

    void _loadConfigsRoute(){
        if (C.rawMap.containsKey("routes")){
            _loadRouteSpecFromConfig();
        }
    }

    void _initRouter(){
        this.router = C['router']!=null ? C['router'] : new Router(<RouteSpec>[]);
    }

    void _usePreloadPlugin(){
        _addRouteLayer();
    }

    void _checkIfDebug(){
      if (C['debug'] == true) isDebug = true;
    }
}