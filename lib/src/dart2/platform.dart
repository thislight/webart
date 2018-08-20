import 'dart:io' show Platform,Process,ProcessResult;

bool _isSuckDart2 = true;

bool isDart2(){
    if (_isSuckDart2 == null){
        _isSuckDart2 = _checkIsDart2();
    }
    return _isSuckDart2;
}

bool _checkIsDart2(){
    String exe = Platform.resolvedExecutable;
    ProcessResult process = Process.runSync(exe, ['--version']);
    return int.parse((process.stdout as String).substring(17,19)) >= 2;
}
