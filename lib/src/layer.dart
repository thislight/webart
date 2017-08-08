library web.layer;
import "dart:async" show Future;

abstract class Layer {
    /// This class is base of all of Layers
    /// [Layer.apply] must be async
    void apply(List args, [Map<Symbol, dynamic> namedArgs]);

    factory Layer(Function f){
        /// Return a [FunctionalLayer]
        return new FunctionalLayer(f);
    }
}


class FunctionalLayer implements Layer {
    Function function;

    FunctionalLayer(this.function);

    Future run(List args, [Map<Symbol, dynamic> namedArgs]) async{
        if (args == null) {
            args = [];
        }
        if (namedArgs != null) {
            await Function.apply(function, args, namedArgs);
        } else {
            await Function.apply(function, args);
        }
    }

    Future apply(List args, [Map<Symbol, dynamic> namedArgs]) async{
        await this.run(args,namedArgs);
    }

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
        this.memories.addAll(this.pchain.global);
    }

    Future start(List args, [Map<Symbol, dynamic> namedArgs]) async{
        forEach((Layer layer) async{
            await layer.apply(args,namedArgs);
        });
    }

    Layer next(){
        _rawPointer ++;
        if ((rawPointer + 1) > pchain.list.length){
            return null;
        }
        return pointer;
    }

    Future forEach(LayerForEachHandler h) async{
        while (true) {
            var layer = next();
            if (layer){
                await h(layer);
            } else {
                break;
            }
        }
    }

    Layer get pointer => pchain.list[rawPointer];

    int get rawPointer => _rawPointer;
}