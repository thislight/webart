import 'package:test/test.dart';


@TestOn('vm')


import 'package:webart/src/plugin.dart' show EventBus,originBack;


void main(){
    group('EventBus', () {
        tearDown((){
            EventBus.printInfo();
            EventBus.renew();
        });
        test('can listen and happen event', () async {
            var p = false;
            await EventBus.on("testEvent").then(originBack((_) => p = true));
            await EventBus.happen("testEvent", []);
              expect(p, equals(true));
          });
          test('newEventHandlerWillBeAdded event will happen when add new event',() async{
              var p = false;
              await (EventBus.on('eventbus.newEventHandlerWillBeAdded').then(originBack((_) => p = true)));
             await (EventBus.on('testEvent').then(originBack((_) => null)));
             expect(p, equals(true));
          });
      });
}