import 'dart:async' show Future;
import "package:webart/web.dart";


main(){
    var app = new Application(
        new Config(<String, dynamic>{
            'debug': true,
            "routes":{
                "hello/{name}": helloPage,
                "query{?q}": queryPage,
                "json{?key,lang}": getJsonPage,
                "class":(new MyRequestHandler()).handler,
                "": homePage,
            }
        })
    );
    app.start("127.0.0.1", 8088);
}

Future homePage(Request request) async{
    request.res.ok("This is home");
}

Future helloPage(Request request) async{
    String name = request.context("urlparam")["name"];
    request.res.ok("Hello, $name");
}

Future queryPage(Request request) async{
    if (request.only(["get"])){
        String qstr = request.context("urlparam")["q"];
        request.res.ok("You are finding $qstr");
    }
}

Future getJsonPage(Request request) async{
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
    await request.on("get",(_) async => request.res.ok({ "result": data[param["key"]][param["lang"]]}));
}

class MyRequestHandler extends RequestHandlerBase{
    String data = "OK";

    Future get(Request request) async{
        logger.info("GET FROM MYREQUESTHANDLER");
        request.res.ok(data);
    }

    Future post(Request request) async{
        data = await request.body;
        logger.info("POST TO MYREQUESTHANDLER");
        request.res.ok(data);
    }
}

