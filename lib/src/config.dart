library web.config;
import 'dart:async' show Future;
import "dart:convert" show JSON;
import "package:yaml/yaml.dart" show loadYaml;
import "dart:io" show File;

class Config {
    Map<String, dynamic> rawMap;

    Config(this.rawMap);

    factory Config.json(String s){
        var conf = new Config({});
        conf.getFromJson(s);
        return conf;
    }

    factory Config.yaml(String s){
        var conf = new Config({});
        conf.getFromYaml(s);
        return conf;
    }

    factory Config.file(File f){
        var conf = new Config({});
        if (f.uri.toFilePath().endsWith(".json")) {
            conf.getFromJsonFile(f);
        } else {
            conf.getFromYamlFile(f);
        }
        return conf;
    }

    dynamic operator [](String key) => rawMap[key];
    operator []=(String key, var value) => rawMap[key] = value;

    void getFromYaml(String s){
        var r = loadYaml(s);
        rawMap.addAll(r);
    }

    void getFromJson(String s){
        var r = JSON.decode(s);
        rawMap.addAll(r);
    }

    Future getFromJsonFile(File f) async{
        getFromJson(await f.readAsString());
    }

    Future getFromYamlFile(File f) async{
        getFromYaml(await f.readAsString());
    }
}