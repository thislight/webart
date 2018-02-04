import 'package:test/test.dart';


@TestOn('vm')


import 'package:webart/src/plugin.dart' show EventBus,originBack;


void main(){
    group('EventBus', () {
        tearDown((){
            EventBus.printInfo();
            EventBus.renew();
        });
        test('can listen and happen event', () {
            var p = false;
            EventBus.on("testEvent").then(originBack((_) async => p = true));
            EventBus.happen("testEvent", []);
              expect(p, equals(true));
          });
          test('newEventHandlerWillBeAdded event will happen when add new event',(){
              var p = false;
              EventBus.on('eventbus.newEventHandlerWillBeAdded').then(originBack((_) => p = true));
             EventBus.on('testEvent').then(originBack((_) => p));
             expect(p, equals(true));
          });
      });
}