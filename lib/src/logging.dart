library web.logging;
import "package:logging/logging.dart";
import "package:bwu_log/bwu_log.dart";
import "./layer.dart" show Layer;
import "./request.dart" show Request;

class SimpleStringFormatter implements FormatterBase<String> {
    String call(LogRecord r) => """[${r.loggerName}][${r.time.toIso8601String()}][${r.level.toString()}]{
        ${r.message}
        ${r.error}
        ${r.stackTrace}
    }
    """;
}


final InMemoryListAppender appender = new InMemoryListAppender(new SimpleStringFormatter());


Logger getLogger(String name){
    var logger = new Logger(name);
    appender.attachLogger(logger);
    return logger;
}


final HandlerLogger = getLogger("handler");


final Layer LoggingLayer = new Layer((Request req){
    HandlerLogger.info("${req.method} ${req.path}");
});