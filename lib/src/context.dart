import "./request.dart" show Request;

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
