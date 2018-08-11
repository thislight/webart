import './plugin.dart' show Plugin;
import "package:logging/logging.dart";
import 'package:webart/src/web.dart';

class SimpleStringFormatter{
  static String format(LogRecord r) =>
      "[${r.loggerName}][${r.time.toIso8601String()}][${r.level.toString()}] ${r.message}";
}


Logger getLogger(String name) {
  var logger = new Logger(name);
  if (_isInDebug){
    logger.level = Level.ALL;
  }
  return logger;
}

bool _isInDebug = false;

class LoggingPlugin extends Plugin {
  @override
  void init(Application app) {
    hierarchicalLoggingEnabled = true;
    if (app.isDebug) {
      _isInDebug = true;
    }
    Logger.root.onRecord.listen((LogRecord r) => print(SimpleStringFormatter.format(r)));
  }
}
