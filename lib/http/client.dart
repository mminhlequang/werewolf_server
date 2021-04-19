import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

class AppClients extends DioForNative {
  static AppClients _instance;

  factory AppClients({String baseUrl, BaseOptions options}) {
    if (_instance == null)
      _instance = AppClients._(baseUrl: baseUrl, options: options);
    if (options != null) _instance.options = options;
    _instance.options.baseUrl = baseUrl;
    return _instance;
  }

  AppClients._({String baseUrl, BaseOptions options}) : super(options) {
    this.interceptors.add(InterceptorsWrapper(
          onRequest: _requestInterceptor,
          onResponse: _responseInterceptor,
          onError: _errorInterceptor,
        ));
    this.options.baseUrl = baseUrl;
  }

  _requestInterceptor(RequestOptions options) {
    options.connectTimeout = 5000;
    options.receiveTimeout = 5000;
    return options;
  }

  _responseInterceptor(Response response) {
    log("Response ${response.request.uri}: ${response.statusCode}\nData: ${response.data}");
    return response;
  }

  _errorInterceptor(DioError dioError) {
    log("${dioError.type} - Error ${dioError.message}");
    return dioError;
  }
}
