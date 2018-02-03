import 'package:test/test.dart';


@TestOn('vm')


import 'package:webart/src/plugin.dart' show EventBus;


void main(){
    group('EventBus', () {
        tearDown((){
            EventBus.renew();
        });
        test('can listen and happen event', () {
            var p = false;
            EventBus.on("testEvent").then(() => p = true);
            EventBus.happen("testEvent", []);
              expect(p, equals(true));
          });
          test('newEventHandlerWillBeAdded event will happen when add new event',(){
              var p = false;
              EventBus.on('eventbus.newEventHandlerWillBeAdded').then(() => p = true);
             EventBus.on('testEvent').then(() => p);
             expect(p, equals(true));
          });
      });
}