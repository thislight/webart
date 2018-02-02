library web.layer;
import "dart:async" show Future;
import "package:logging/logging.dart" show Logger;
import "./logging.dart" show getLogger;

final Logger _logger = getLogger("Layer");


abstract class Layer {
    /// This class is base of all of Layers
    
    /// This method is entry of layer, must be async
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
typedef void GoFunction();
typedef void Go();


class LayerState {
    LayerChain pchain;
    int _rawPointer;
    Map<String, dynamic> memories;

    LayerState(this.pchain){
        _rawPointer = -1;
        memories = <String,dynamic>{};
        this.memories.addAll(this.pchain.global);
        _logger.info("New state created: LayerState@${hashCode}");
    }

    Function buildGoFunction(List args, [Map<Symbol, dynamic> namedArgs]){
        return () async{
            Layer l = next();
            if (l != null){
                return l.apply(args,namedArgs);
            }
        };
    }

    Future start(List args, [Map<Symbol, dynamic> namedArgs]) async{
        Function go = buildGoFunction(args,namedArgs);
        args.add(go);
        return go();
    }

    Layer next(){
        _rawPointer ++;
        if ((rawPointer + 1) > pchain.list.length){
            return null;
        }
        _logger.info("Next layer: point $rawPointer, layer $pointer, state $this");
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