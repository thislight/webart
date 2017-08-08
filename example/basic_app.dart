import "package:web.dart/web.dart";
import "dart:async" show Future;

Future main() async{
    var app = new Application(
        new Config(<String, dynamic>{
            "route":{
                "/": _homePage,
                "/hello{?name}": _helloPage,
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
