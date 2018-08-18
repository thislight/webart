import "./request.dart" show Request;

/// The context of request
/// 
/// Use [Context.register] to register a function
/// ````
/// class MyPlugin extends Plugin {
///     @override
///     void init(Application app){
///         app.registerCommandHandler('Application.beforeRequestHandling',(Command command){
///             var request = command['request'] as Request;
///             request.context.register("lang",(request) => request.context('urlparam')['lang']);
///         });
///     }
/// }
/// 
/// Future testHandler(Request request) async {
///     request.response.ok(request.context('lang'));
/// }
class Context {
  Request request;
  Map<String, Function> contextCreators;

  Context(this.request) {
    contextCreators = <String, Function>{};
  }

  dynamic call(String s) {
    return contextCreators[s](request);
  }

  void register(String s, Function f) => contextCreators[s] = f;
}
