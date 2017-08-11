library web.logging;
import "package:logging/logging.dart";
import "package:bwu_log/bwu_log.dart";
import "./layer.dart" show FunctionalLayer,GoFunction;
import "./request.dart" show Request;

class SimpleStringFormatter implements FormatterBase<String> {
    String call(LogRecord r) => "[${r.loggerName}][${r.time.toIso8601String()}][${r.level.toString()}] ${r.message}";
}


final PrintAppender appender = new PrintAppender(new SimpleStringFormatter());


Logger getLogger(String name){
    var logger = new Logger(name);
    appender.attachLogger(logger);
    return logger;
}


final HandlerLogger = getLogger("handler");


final FunctionalLayer LoggingLayer = new FunctionalLayer((Request req, GoFunction go){
    HandlerLogger.info("${req.method} ${req.path}");
    go();
})
    ..setName("LoggingLayer");
