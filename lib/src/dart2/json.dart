import './platform.dart';
import 'dart:convert' as convert;


convert.JsonCodec _codec;


get JSON {
    if (isDart2()){
        return convert.json;
    } else {
        if (_codec == null) _codec = new convert.JsonCodec();
        return _codec;
    }
}
