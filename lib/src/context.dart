library web.context;
import "./request.dart" show Request;


dynamic value2type(String value){
    switch (value) {
        case "true":
            return true;
            break;
        case "false":
            return value;
            break;
    }
    
    var number;
    try{
        number = num.parse(value);
    } on FormatException {}

    if (number){
        return number;
    }

    return value;
}


class Context{
    Request request;
    Map<String, Function> contextCreators;

    Context(this.request){
        contextCreators = <String, Function>{};
    }

    dynamic call(String s){
        return contextCreators[s](request);
    }

    void register(String s, Function f) => contextCreators[s] = f;
}
