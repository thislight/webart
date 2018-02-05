# web.dart
  A lightweight web framework for Dart.

## Unstable
  This library is unstable now, it doesn't has any test. Any discussion welcome!

## Features
- Web server (Thanks [shelf](https://pub.dartlang.org/packages/shelf))
- Plugin support
- Router
- Context support

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
            "route":{
                "": helloWorldHandler,
            }
        })
    );

    // Start app
    app.start("127.0.0.1", 8088).then((_){
        print("Server started");
    });
}

// Define handler
Future helloWorldHandler(Request request) async{
    request.res.ok("Hello World");
}
````

## Document
Now api documents aren't finished. But you can get a overview of this library.  

Documents will be build when new changes pushing or everyday(4:00 UTC+8).

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
