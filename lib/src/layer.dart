import "dart:async" show Future;
import "package:logging/logging.dart" show Logger;
import "./logging.dart" show getLogger;

final Logger _logger = getLogger("Layer");

/// This class is base of all of Layers  
/// If you want to make own layer, extend this class  
/// For example:  
/// ````
/// class MyLayer extend Layer {
///     @override
///     Future apply(List args, [Map<Symbol, dynamic> namedArgs]){
///         // Do something here
///     }
/// }
/// ````
/// If you need a simple way to build a layer, see [FunctionalLayer]  
abstract class Layer {
    /// The entry of layer, must be async
    Future apply(List args, [Map<Symbol, dynamic> namedArgs]);
}


class FunctionalLayer implements Layer {
    Function function;
    String _name;

    FunctionalLayer.withName(this._name,this.function);

    FunctionalLayer(this.function){
        _name = "FunctionalLayer";
    }

    String get name => _name;
        set name(String v) => _name = v;
    
    void setName(String v) => name = v;

    Future run(List args, [Map<Symbol, dynamic> namedArgs]) async{
        if (args == null) {
            args = [];
        }
        if (namedArgs != null) {
            return Function.apply(function, args, namedArgs);
        } else {
            return Function.apply(function, args);
        }
    }

    Future apply(List args, [Map<Symbol, dynamic> namedArgs]) async{
        return this.run(args,namedArgs);
    }

    String toString() => "$name@$hashCode { function=$function }";

}


class LayerManager {
    LayerChain chain;

    LayerManager(){
        chain = new LayerChain.empty();
    }

    LayerState createState() => chain.newState;
    LayerState get newState => createState();
}


class LayerChain {
    List<Layer> list;
    Map<String, dynamic> global;

    LayerChain(this.list,[Map<String, dynamic> map]){
        if (map == null) {
            global = <String, dynamic>{};
        }
    }

    factory LayerChain.empty(){
        return new LayerChain(<Layer>[]);
    }

    void add(Layer layer) => list.add(layer);

    void addAll(Iterable<Layer> iterable) => list.addAll(iterable);

    void insert(int index, Layer layer) => list.insert(index, layer);

    void insertAll(int startIndex, Iterable<Layer> iter) => list.insertAll(
        startIndex, iter
        );
    
    LayerState createState() => new LayerState(this);
    LayerState get newState => createState();

}


typedef void LayerForEachHandler(Layer layer);


class LayerState {
    LayerChain pchain;
    int _rawPointer;
    Map<String, dynamic> memories;

    LayerState(this.pchain){
        _rawPointer = -1;
        memories = <String,dynamic>{};
        this.memories.addAll(this.pchain.global);
        _logger.finest("New state created: LayerState@${hashCode}");
    }

    Future start(List args, [Map<Symbol, dynamic> namedArgs]) async{
        await _untilNull<Layer>(next, (Layer l) async => l.apply(args,namedArgs));
    }

    Layer next(){
        _rawPointer ++;
        if ((rawPointer + 1) > pchain.list.length){
            return null;
        }
        _logger.finest("Next layer: point $rawPointer, layer $pointer, state $this");
        return pointer;
    }

    Future forEach(LayerForEachHandler h) async{
        await pchain.list.forEach((Layer layer) async {
            next();
            await h(layer);
        });
    }

    Layer get pointer => pchain.list[rawPointer];

    int get rawPointer => _rawPointer;
}


typedef Future _DataMapper<T>(T data);


Future _untilNull<T>(Function f1,_DataMapper<T> f2) async{
    for(;;){
        dynamic v1 = Function.apply(f1,[]);
        if (v1 != null){
            await f2(v1);
        } else {
            break;
        }
    }
}
