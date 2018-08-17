import 'dart:async';
import 'dart:mirrors';
import './request.dart';
import './logging.dart';
import './handler.dart';
import 'package:logging/logging.dart';


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
        } catch (e) {
            logger.severe('A Error thrown by handler.',e);
        }
    }

    InstanceMirror _getInstance(){
        if (_instance == null){
            _instance = reflect(this);
        }
        return _instance;
    }

    RequestHandler get handler => _handler;

    Logger get logger => getLogger(runtimeType.toString());
}
