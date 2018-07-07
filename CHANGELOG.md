# CHANGELOG

## 0.2.0-beta.0
- New `MessageChannel`, `ChannelSession`, `ChannelSeesionMessage` and `Command`
- Return HTTP error 404 when handler not found
- Router will be fast if uri path is static (for example '/about')
- Builtin Router now work as a Plugin by `RoutingPlugin`, it also use third party router if given
- A dirty fix for uri template "" match all uri
- Package structure changed, all of Layer moved to single 'package:webart/layer.dart'
- Small change for example.
- Code opz.,remove unused imports and functions
- Mark EvevntBus as deprecated, it will be removed when 0.2.0 released.

## 0.2.0-alpha.6
- Remove `LoggingLayer`
- `Request.on` changes to async

## 0.2.0-alpha.5
- return not found when not handler found

## 0.2.0-alpha.4
- Fix error that handler will be called twice

## 0.2.0-alpha.3
- Fix error that handler not handled

## 0.2.0-alpha.2
- Add EventBus for plugin
- Redesign route system, allow using third party router
- Redesign layer system, get `Go` away and make it powerful
- A bit tests for EventBus

## 0.2.0-alpha.1
- Fix performance problem while running handler, move `waitForResponse` to trash

## 0.1.0
- First version