import "dart:async";
import "./layer.dart";
import "./logging.dart" show getLogger, LoggingPlugin;
import "./config.dart" show Config;
import "./request.dart" show Request, buildRawResponse;
import "./plugin.dart" show ChannelSession, MessageChannel, Plugin;
import "./route.dart" show BaseRouter, RoutingPlugin;
import './cmd.dart';
import "package:shelf/shelf.dart" as shelf;
import "package:shelf/shelf_io.dart" as io;
import "package:logging/logging.dart" show Logger;


final Logger _logger = getLogger("Application");


class Application {
    LayerManager lman;
    List<shelf.Middleware> middlewares;
    MessageChannel channel;
    ChannelSession<Command> command;
    Map<String,CommandHandler> _commandHandlers;
    BaseRouter router;
    Config C;
    bool isDebug;

    Application(this.C){
        lman = new LayerManager();
        middlewares = <shelf.Middleware>[];
        channel = new MessageChannel("ApplicationMain");
        command = new ChannelSession(channel);
        _commandHandlers = {};
        channel.registerSession(command);
        isDebug = true;
        this._checkIfDebug();
        this._usePreloadPlugin();
        command.stream.listen((data) => scheduleMicrotask(() => _handleCommand(data)));
    }

    _handleCommand(Command command){
      var handler = _commandHandlers[command.command];
      if (handler != null) handler(command);
    }

    Future<shelf.Response> handler(shelf.Request raw) async{
        LayerState currState = lman.newState;
        Request request = new Request(raw,currState,this);
        await currState.start([request]);
        return await buildRawResponse(request.response);
    }

    Future start(String address, int port) async{
        command.send(
          new Command("Router.ready")
        );
        return io.serve(buildHandler(),address,port).then((s){
          _logger.info("Service Started. $address:$port");
          return s;
        });
    }

    buildHandler(){
        _logger.finest("Building handler");
        var pl = const shelf.Pipeline();
        middlewares.forEach((shelf.Middleware m){
            pl = pl.addMiddleware(m);
        });
            pl = pl.addHandler(this.handler);
        return pl;
    }

    void use(Plugin p){
        _logger.info("Using ${p.toString()}");
        p.init(this);
    }

    void _usePreloadPlugin(){
        use(new RoutingPlugin());
        use(new LoggingPlugin());
    }

    void _checkIfDebug(){
      _logger.config("Debug mode: ${C['debug']}");
      if (C['debug'] == false) isDebug = false;
    }

    void registerCommandHandler(String c, CommandHandler handler){
      _commandHandlers[c] = handler;
    }
}
