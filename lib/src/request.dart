import "dart:convert" show JSON;
import "package:shelf/shelf.dart" as shelf;
import "./context.dart" show Context;
import "./web.dart" show Application;
import "./config.dart" show Config;
import "dart:async" show Future;
import "./logging.dart" show getLogger;
import 'package:logging/logging.dart' show Logger;
import './handler.dart';
import './cmd.dart';

final Logger _logger = getLogger("Request");

class Request {
  shelf.Request _raw;
  Response _res;
  Application _app;
  Context _context;

  Request(this._raw, this._app) {
    _res = new Response(this);
    _context = new Context(this);
  }

  shelf.Request get raw => _raw;

  Application get app => _app;

  Context get context => _context;

  Map<String, String> get headers => raw.headers;

  String get method => raw.method;

  String get mimeType => raw.mimeType;

  Uri get url => raw.url;

  Future<String> get body => raw.readAsString();

  dynamic asJson() async => JSON.decode(await body);

  Response get response => _res;
  Response get res => response;

  Config get C => app.C;

  String get path => url.path;

  String toString() => "Request@$hashCode { method=$method, path=/$path }";

  String get handlerPath => raw.handlerPath;

  Future on(String method, RequestHandler handler) async {
    if (method.toLowerCase() == this.method.toLowerCase()) {
      await handler(this);
    }
  }

  bool only(List<String> allowedMethods) {
    allowedMethods.map((String e) => e.toLowerCase());
    if (allowedMethods.contains(this.method.toLowerCase())) {
      return true;
    } else {
      this.res.error(400);
      return false;
    }
  }
}

class Response {
  String body;
  Request request;
  int statusCode;
  Map<String, String> headers = {};
  List<String> acceptedMethods = ['Get', 'Post', 'Options', 'Head'];
  RequestHandler _handler;

  Response(this.request) {
    headers['Encoding'] = "UTF-8";
  }

  void ok(var body) {
    statusCode = 200;
    this.body = preprocessBody(body);
  }

  void forbidden([var body]) => error(403, body);

  void notFound([var body]) => error(404, body);

  void error(int code, [var body]) {
    statusCode = code;
    getTargetPage(body);
  }

  Future getTargetPage([var body]) async {
    if (body != null) {
      body = preprocessBody(body);
    } else {
      if (request.app.isDebug) {
        body = '''
            Request: $request
            Status code: $statusCode
            Headlers: $headers
            Accepted methods: $acceptedMethods
            Handler = $_handler
            ''';
      } else {
        body = '';
      }
    }
  }

  String preprocessBody(var body) {
    if (body is String) {
      if (body.contains("<html>") && body.contains("</html>") && body.contains("<body>") && body.contains("</body>")) {
          headers['Content-Type'] = "text/html";
      } else if (body.length > 0) {
          headers['Content-Type'] = "text/plain";   
      }
      return body;
    } else {
      headers['Content-Type'] = "application/json";
      return JSON.encode(body);
    }
  }

  bool get isEmpty => (statusCode == null) && (body == null);

  void handleWith(RequestHandler h) {
    _logger
        .finest("$request will be handled by $h");
    _handler = h;
  }

  Future handle() async {
    request.app.commandSync.send(
        new Command('Request.beforeHandling', args: {'request': request}));
    if (_handler == null) {
      _logger.shout("Not handled: ${this.request}");
      notFound();
      return new Future.value();
    }
    await _handler(request);
  }
}

Future<shelf.Response> buildRawResponse(Response response) async {
  await response.handle();
  if (response.isEmpty) {
    response.notFound();
  }
  if ((response.request.method.toLowerCase() == "options") &&
      response.statusCode == 404) {
    response.headers['Allow'] = response.acceptedMethods.map((s) => s.toUpperCase()).join(', ');
    response.headers['Content-Length'] = "0";
    if (response.request.app.C['allow_global_cors'] ?? false)
        _applyAccessControlAllowHeaders(response);
    response.ok('');
  }
  var raw = new shelf.Response(response.statusCode,
      body: response.body, headers: response.headers);
  return raw;
}


void _applyAccessControlAllowHeaders(Response response){
    response.headers['Access-Control-Allow-Origin'] = "*";
    response.headers['Access-Control-Allow-Headers'] = response.request.headers['Access-Control-Request-Headers'] ?? const ['Content-Type'].join(', ');
    response.headers['Access-Control-Allow-Methods'] = response.headers['Allow'] ?? response.acceptedMethods.map((s) => s.toUpperCase()).join(', ');
}

void allowCORSRequest(Request request, Map<String,String> exHeaders){
    request.on("options", (request){
        _applyAccessControlAllowHeaders(request.response);
        request.response.ok('');
    });
}
