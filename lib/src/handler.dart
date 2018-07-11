import 'dart:async' show Future;
import './request.dart' show Request;

typedef Future RequestHandler(Request request);
