import 'dart:async' show Future;
import "package:webart/web.dart";


main(){
    var app = new Application(
        new Config(<String, dynamic>{
            "route":{
                "hello/{name}": _helloPage,
                "query{?q}": _queryPage,
                "json{?key,lang}": _getJsonPage,
                "": _homePage,
            }
        })
    );
    app.start("127.0.0.1", 8088).then((_){
        print("Server started");
    });
}

Future _homePage(Request request) async{
    request.res.ok("This is home");
}

Future _helloPage(Request request) async{
    String name = request.context("urlparam")["name"];
    request.res.ok("Hello, $name");
}

Future _queryPage(Request request) async{
    if (request.only(["get"])){
        String qstr = request.context("urlparam")["q"];
        request.res.ok("You are finding $qstr");
    }
}

Future _getJsonPage(Request request) async{
    Map data = {
        "data1": {
            "zh": "你好",
            "en": "Hello",
        },
        "data2": {
            "zh": "再见",
            "en": "Godbye",
        }
    };
    Map<String, String> param = request.context("urlparam");
    request.on("get",(_) async => request.res.ok({ "result": data[param["key"]][param["lang"]]}));
}

