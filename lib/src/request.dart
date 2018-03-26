library web.request;
import "dart:convert" show JSON;
import "package:shelf/shelf.dart" as shelf;
import "./layer.dart" show LayerState;
import "./context.dart" show Context;
import "./web.dart" show Application;
import "./config.dart" show Config;
import "dart:async" show Future;
import "./logging.dart" show getLogger;
import 'package:logging/logging.dart' show Logger;
import './handler.dart';

final Logger _logger = getLogger("Request");


class Request{
     shelf.Request _raw;
     Response _res;
     LayerState _state;
     Application _app;
     Context _context;

     Request(this._raw,this._state,this._app){
         _res = new Response(this);
         _context = new Context(this);
     }

     shelf.Request get raw => _raw;
     
     LayerState get state => _state;

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

     String get path => raw.handlerPath;

     String toString() => "Request@$hashCode { method=$method, url=$url, path=$path }";

     String get handlerPath => raw.handlerPath;

     Future on(String method, RequestHandler handler) async{
         if (method.toLowerCase() == this.method.toLowerCase()){
            await handler(this);
         }
     }

     bool only(List<String> allowedMethods){
         allowedMethods.map((String e) => e.toLowerCase());
         if (allowedMethods.contains(this.method.toLowerCase())){
             return true;
         } else {
             this.res.error(400);
             return false;
         }
     }
}


class Response{
    String body;
    Request request;
    int statusCode;
    Map<String, String> headers = {};
    List<String> acceptedMethods = ['Get','Post','Options','Head'];
    RequestHandler _handler;

    Response(this.request){
        headers['Content-Type'] = 'plain/html';
        headers['Server'] = 'Dart, web.dart, shelf';
    }

    Future<shelf.Response> done() async{
        await handle();
        if (isEmpty){
            notFound();
        }
        if (request.only(["options"]) && isEmpty){
           headers['Allow'] = acceptedMethods.join(', '); 
           headers['Content-Length'] = "0";
           ok('');
        }
        return new shelf.Response(statusCode, body: body, headers: headers);
    }

    void ok(var body){
        statusCode = 200;
        this.body = preprocessBody(body);
    }

    void forbidden([var body]) => error(403,body);

    void notFound([var body]) => error(404,body);

    void error(int code, [var body]){
        statusCode = code;
        getTargetPage(body);
    }

    Future getTargetPage([var body]) async{
        if (body == null){
            this.body = await request.app.getErrorPage(statusCode);
        } else {
            this.body = preprocessBody(body);
        }
    }

    dynamic preprocessBody(var body){
        if (body is String){
            return body;
        } else {
            headers['Content-Type'] = "application/json";
            return JSON.encode(body);
        }
    }

    bool get isEmpty => (statusCode == null) && (body == null);

    void handleWith(RequestHandler h){
        if (_handler != null) return;
        if (h == null) h = (Request req) async => req.res.notFound();
        _logger.info("Request@${request.url} will be handled by RequestHandler@$h");
        _handler = h;
    }

    Future handle() async {
        await _handler(request);
    }
}