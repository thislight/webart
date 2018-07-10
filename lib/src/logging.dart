import './plugin.dart' show Plugin;
import "package:logging/logging.dart";
import "package:bwu_log/bwu_log.dart";
import 'package:webart/src/web.dart';

class SimpleStringFormatter implements FormatterBase<String> {
    String call(LogRecord r) => "[${r.loggerName}][${r.time.toIso8601String()}][${r.level.toString()}] ${r.message}";
}


class CustomPrintAppender extends Appender<String>{
  CustomPrintAppender(FormatterBase<String> fb): super(fb);

  @override
  void append(LogRecord record, Formatter<String> formatter) {
    print(formatter(record));
  }
}


final CustomPrintAppender appender = new CustomPrintAppender(new SimpleStringFormatter());


Logger getLogger(String name){
    var logger = new Logger(name);
    appender.attachLogger(logger);
    return logger;
}


class LoggingPlugin extends Plugin{
  @override
  void init(Application app) {
    if (app.isDebug){
      Logger.root.level = Level.ALL;
    }
  }
}
