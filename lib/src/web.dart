library web;
import "dart:io" show File;
import "dart:async" show Future;
import "./layer.dart";
import "./logging.dart" show LoggingLayer;
import "./config.dart" show Config;
import "./request.dart" show Request;
import "./plugin.dart" show Plugin;
import "package:shelf/shelf.dart" as shelf;
import "package:shelf/shelf_io.dart" as io;


class Application {
    LayerManager lman;
    List<shelf.Middleware> middlewares;
    Config C;

    Application(this.C){
        lman = new LayerManager();
        middlewares = <shelf.Middleware>[];
        this._initLayer();
    }

    shelf.Response handler(shelf.Request raw){
        LayerState currState = lman.newState;
        Request request = new Request(raw,currState,this);
        currState.start([request]);
        return request.response.done();
    }

    Future<String> getErrorPage(int code) async {
        var key = code.toString();
        String filePath = C["errorPages"][key];
        return await (new File(filePath)).readAsString();
    }

    void _initLayer(){
        lman.chain.add(LoggingLayer);
    }

    Future start(String address, int port) async{
        return io.serve(buildHandler(),address,port);
    }

    buildHandler(){
        var pl = new shelf.Pipeline();
        middlewares.forEach((shelf.Middleware m){
            pl.addMiddleware(m);
        });
            pl.addHandler(this.handler);
        return pl;
    }

    void use(Plugin p){
        p.init(this);
    }
}