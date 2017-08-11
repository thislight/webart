import "package:web_dart/web.dart";
import "package:web_dart/session_support.dart" show SessionPlugin,Session;

main(){
    var app = new Application(
        new Config(<String, dynamic>{
            "route":{
                "": _homePage,
                "hello/{name}": _helloPage,
                "query{?q}": _queryPage,
                "json{?key,lang}": _getJsonPage,
                "count": _countPage,
                "cookietest{?value}": _cookieTestPage,
            }
        })
    );
    app.use(new SessionPlugin());
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


/// This handler no work
void _countPage(Request request){
    Session session = request.context("session");
    int count;

    if (!session.storage.containsKey("count")){
        count = 0;
    } else {
        count = session["count"];
    }

    count++;
    session["count"] = count;

    request.res.ok({ "current": count});
}

/// This handler no work
void _cookieTestPage(Request request){
    String data = request.context("urlparam")["data"];
    request.context("cookies")["data"] = data;
    request.res.ok("ok");
}
