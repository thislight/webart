# web.dart
  A lightweight web framework for Dart.

## WARNING: Although supported dart 2, please do not use that
Dart 2 has bad performance because of Strong Mode, it just like Dart 1's Checked Mode...
Dart 2 is slower than Dart 1.24.3 ~60%.
Use the versiones end of `-dart1c` to use this library with Dart 1, such as `0.3.0-dart1c`

## Features
- Web server (Thanks to [shelf](https://pub.dartlang.org/packages/shelf))
- Plugin
- Router
- Context

## Usage
This example show the basic usage of web.dart

````yaml
  webart:
    git: https://gitlab.com/thislight/web.dart.git
````

Or

````yaml
  webart: any
````

Code:

````dart
import "package:webart/web.dart";

main(){
    // Create app
    Application app = new Application(
        new Config(<String, dynamic>{
            "debug": true,
            "route":{
                "": helloWorldHandler,
            }
        })
    );

    // Start app
    app.start("127.0.0.1", 8088);
}

// Define handler
Future helloWorldHandler(Request request) async{
    request.res.ok("Hello World");
}
````

## Document
Currently, API documents aren't finished. But you can get an overview of this library.  

Documents will be built when new changes are pushed and on 4:00 (UTC+8) of everyday.

[The document of branch master](https://thislight.gitlab.io/web.dart/doc/api)


[The document of branch develop](https://thislight.gitlab.io/web.dart/develop/doc/api)

## LICENSE
Copyright 2017 thisLight

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
