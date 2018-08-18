import 'dart:async';
import 'dart:mirrors';
import './request.dart';
import './logging.dart';
import './handler.dart';
import 'package:logging/logging.dart';


/// The base of all class-based request handler.
/// Extends it and finish method to handling request.  
/// 
/// For example:
/// ````
/// class ExampleRequestHandler extends RequestHandlerBase{
///     Future get(Request request){
///         request.ok('');
///     }
///     
///     Future options(Request request){
///         allowCORSRequest(request,{});
///     }
/// }
/// ````
/// You can use [.logger] to log useful infomation.  
/// Tips: Class-based request handler will be slower than normal handler because it used dart:mirrors
class RequestHandlerBase {
    static InstanceMirror _instance;

    Future _handler(Request request) async{
        String methodName = request.method.toLowerCase();
        InstanceMirror ins = _getInstance();
        try{
            var futureMirror = ins.invoke(new Symbol(methodName), [request]);
            if (futureMirror.hasReflectee){
                Future future = (futureMirror.reflectee as Future);
                await future;
            }
        } on NoSuchMethodError{
            request.response.notFound();
            logger.shout("No requested method: $request");
        } catch (e){
            logger.warning("A Error thown by handler",e);
        }
    }

    InstanceMirror _getInstance(){
        if (_instance == null){
            _instance = reflect(this);
        }
        return _instance;
    }

    /// Get the functional handler of the class-based request handler
    RequestHandler get handler => _handler;

    Logger get logger => getLogger(runtimeType.toString());
}
