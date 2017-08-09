# web.dart
  A lightweight web framework for Dart.

### Unstable
  This library isn't stable now, it doesn't has any test. Any discussion welcome!

## Features
- Basic Web Server
- Plugin support
- Router
- Context support

## Usage
This example show the basic usage of web.dart
````dart
import "package:web.dart/web.dart" as web;

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
void helloWorldHandler(Request request){
    request.res.ok("Hello World");
}
````
Now api documents aren't finished. But you can get a overview of this library.

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