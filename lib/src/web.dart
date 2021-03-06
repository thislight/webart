import "dart:async";
import "./logging.dart" show getLogger, LoggingPlugin;
import "./config.dart" show Config;
import "./request.dart" show Request, buildRawResponse;
import "./plugin.dart" show ChannelSession, MessageChannel, Plugin;
import "./route.dart" show BaseRouter,RoutingPlugin;
import './cmd.dart';
import "package:shelf/shelf.dart" as shelf;
import "package:shelf/shelf_io.dart" as io;
import "package:logging/logging.dart" show Logger;

final Logger _logger = getLogger("Application");


/// The main entry of a Web Application
class Application {
  List<shelf.Middleware> middlewares;
  MessageChannel channel;
  MessageChannel channelSync;
  ChannelSession<Command> command;
  ChannelSession<Command> commandSync;
  Map<String, Set<CommandHandler>> _commandHandlers;
  BaseRouter router;
  Config C;
  bool isDebug;

  Application(this.C) {
    middlewares = <shelf.Middleware>[];
    channel = new MessageChannel("ApplicationMain");
    command = new ChannelSession(channel);
    channelSync = new MessageChannel("ApplicationMainSync", sync: true);
    commandSync = new ChannelSession(channelSync);// TODO: Remove it in 0.3
    _commandHandlers = {};
    channel.registerSession(command);
    channelSync.registerSession(commandSync);
    isDebug = true;
    this._checkIfDebug();
    this._usePreloadPlugin();
    command.stream
        .listen((data) => scheduleMicrotask(() => _handleCommand(data)));
    commandSync.stream.listen((data) => _handleCommand(data));
  }

  void _handleCommand(Command command) {
    var handlers = _commandHandlers[command.command];
    if (handlers != null && handlers.isNotEmpty){
        if (handlers.length == 1){
            handlers.first(command);
        }else{
            for (CommandHandler handler in handlers){
                handler(command);
            }
        }
    }
    if (command.includingLock){
        (command.args['lock'] as CommandLock).unlock();
        return;
    }
    if (command.requireResult){
        command.args['_broadcastResult'].end();
        return;
    }
  }

  Future _doActionBeforeHandling(Request request) async{
    var c = new Command("Application.beforeRequestHandling", args: {
      'request': request,
    }, includingLock: true);
    command.send(c);
    await (c.args['lock'] as CommandLock).lock();
    await this.router.accept(request);
  }

  Future<shelf.Response> handler(shelf.Request raw) async {
    Request request = new Request(raw, this);
    await _doActionBeforeHandling(request);
    await request.response.handle();
    return await buildRawResponse(request.response);
  }

    /// Start a server  
    /// You can set [securityContext] and [backlog] in config
  Future start(String address, int port) async {
    ready();
    return io.serve(buildHandler(), address, port,
                    securityContext: C['securityContext']??null,
                    backlog: C['backlog']??null).then((s) {
      _logger.info("Service Started. $address:$port");
      return s;
    });
  }

    /// make server ready to handle request  
    /// [Application.start] will be call it
  void ready(){
    command.send(new Command("Router.ready"));
  }

  shelf.Handler buildHandler() {
    _logger.finest("Building handler");
    shelf.Pipeline pl = const shelf.Pipeline();
    middlewares.forEach((shelf.Middleware m) {
      pl.addMiddleware(m);
    });
    return pl.addHandler(this.handler);
  }

    /// Use a [Plugin] in server
  void use(Plugin p) {
    _logger.info("Using ${p.toString()}");
    p.init(this);
  }

  void _usePreloadPlugin() {
    use(new RoutingPlugin());
    use(new LoggingPlugin());
  }

  void _checkIfDebug() {
    _logger.config("Debug mode: ${C['debug'] ?? false}");
    if (C['debug'] == false) isDebug = false;
  }

  void registerCommandHandler(String c, CommandHandler handler) {
      if (_commandHandlers[c] == null) _commandHandlers[c] = new Set();
    _commandHandlers[c].add(handler);
  }
}
