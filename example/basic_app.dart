import "package:web.dart/web.dart";


main(){
    var app = new Application(
        new Config(<String, dynamic>{
            "route":{
                "": _homePage,
                "hello/{name}": _helloPage,
                "query{?q}": _queryPage,
                "json{?key,lang}": _getJsonPage,
            }
        })
    );
    app.start("127.0.0.1", 8088).then((_){
        print("Server started");
    });
}

void _homePage(Request request){
    request.res.ok("This is home");
}

void _helloPage(Request request){
    String name = request.context("urlparam")["name"];
    request.res.ok("Hello, $name");
}

void _queryPage(Request request){
    if (request.only(["get"])){
        String qstr = request.context("urlparam")["q"];
        request.res.ok("You are finding $qstr");
    }
}

void _getJsonPage(Request request){
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
    request.on("get",(_) => request.res.ok({ "result": data[param["key"]][param["lang"]]}));
}

