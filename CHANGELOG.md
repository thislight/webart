# CHANGELOG

## 0.2.3
- Fix response of method OPTIONS
- add configure item `allow_global_cors` to Allow Global CORS
- Remove custom sever header
- Add function `allowCORSRequest` allow respond server headers that including some `Access-Control-Allow-*`
- Add `BroadcastResults` to support that return value from a command
- Add `CommandLock` to wait command done
- Add optional param `includingLock` to Command for adding a `CommandLock` to `Command.args['lock']`
- Redo BroadcastResults impl in `Command`, from `Command.broadcastResult` move to `Command.args['_broadcastResult']`
- Remove command `Request.beforeHandling`
- Now command `Application.beforeRequestHandling` will be runned before Routing and Handling

## 0.2.2
- Fix Dart SDK version

## 0.2.1
- Allow `Command` has a `Completer` to return a value
- `ChannelSession.send` will return the future of `Command`'s `Completer` if has
- Fix example
- Add `Application.ready` to touch some events must touch
- some bug fixes 

## 0.2.0
- Release 0.2.0
  - Fix performance problem while running handler, move `waitForResponse` to trash
  - Add EventBus for plugin
  - Redesign route system, allow using third party router
  - Redesign layer system, get `Go` away and make it powerful
  - A bit tests for EventBus
  - Fix error that handler not handled
  - Fix error that handler will be called twice
  - return not found when not handler found
  - Remove `LoggingLayer`
  - `Request.on` changes to async
  - New `MessageChannel`, `ChannelSession`, `ChannelSeesionMessage` and `Command`
  - Return HTTP error 404 when handler not found
  - Router will be fast if uri path is static (for example '/about')
  - Builtin Router now work as a Plugin by `RoutingPlugin`, it also use third party router if given
  - A dirty fix for uri template "" match all uri
  - Package structure changed, all of Layer moved to single 'package:webart/layer.dart'
  - Small change for example.
  - Code opz.,remove unused imports and functions
  - Mark EvevntBus as deprecated, it will be removed when 0.2.0 released.
  - Update logging system, supported debug mode.Just add `'debug': true` to config.
  - Mark Layer system as deprecated
  - Remove deprecated entries
  - Some fixes update
  - Fix some error while run on strong mode
  - Add some tests
  - Edit README

## 0.2.0-beta.5
- Fix some error while run on strong mode
- Add some tests
- Edit README

## 0.2.0-beta.4
- Some fixes update

## 0.2.0-beta.3
- Remove deprecated entries

## 0.2.0-beta.2
- Mark Layer system as deprecated

## 0.2.0-beta.1
- Update logging system, supported debug mode.Just add `'debug': true` to config.

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