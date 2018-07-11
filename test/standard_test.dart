import 'dart:async';
import 'package:test/test.dart';
import 'package:webart/web.dart';
import 'package:http/http.dart' as http;

const PORT = 8088;
const BASEURI = "http://127.0.0.1:$PORT";
const TEST1 = "$BASEURI/test1";
const TEST2 = "$BASEURI/test2/test?q=";

@TestOn("vm")
void main(){
  var logger = getLogger("TestCase");
  logger.warning(
    "This is STANDARD TESTS, it require a network interface "
    "to run a real HTTP Server."
  );
  group("standard tests", (){
    Application app;
    setUpAll(() async{
      app = await getApp();
    });

    test("handler can be requested", () async{
      http.Response responsePost = await http.post(TEST1);
      assert(responsePost.statusCode == 200);
      assert(responsePost.body == "POST");
    });

    test("get 404 when handler not found", () async{
      http.Response response = await http.get("$BASEURI/mustBeNotFound");
      assert(response.statusCode == 404);
    });

    test("uri template and context are working",() async{
      http.Response response = await http.get(TEST2+"test");
      assert(response.statusCode == 200);
      assert(response.body == "PASS");
    });
  });
}

getApp() async{
  var app = new Application(new Config({
    'debug': true,
    'routes': {
      'test1': test1Handler,
      'test2/test{?q}': uriTemplateSmokeTestHandler,
    }
  }));
  await app.start("127.0.0.1", PORT);
  return app;
}

Future test1Handler(Request request) async{
  await request.on("POST",(request) async => request.response.ok("POST"));
}

Future uriTemplateSmokeTestHandler(Request request) async{
  if (!request.only(['GET'])) request.response.forbidden();
  String q = request.context("urlparam")["q"];
  if (q == "test") request.response.ok("PASS");
}
