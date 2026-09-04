import 'dart:async';
import 'package:dio/dio.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';

abstract class APIServiceBase {
  final Dio _dio;
  TokenProvider? tokenProvider;

  APIServiceBase(this._dio, {this.tokenProvider});

  Future<APIResponse<T>> get<T>(
      String url, T Function(dynamic json) deserialize,
      {Map<String, dynamic>? headers}) async {
    try {
      Options? options = _getOptionsWithAuthorization();

      if (headers != null) {
        options ??= Options(headers: {});
        headers.forEach((key, value) {
          options!.headers![key] = value;
        });
      }

      Response response = await _dio.get(url, options: options);
      dynamic jsonData = response.data;
      T data = deserialize(jsonData);
      return APIResponse<T>(statusCode: response.statusCode!, body: data);
    } catch (error) {
      if (error is DioException) {
        return _fromDioException(error);
      }
      return APIResponse<T>(error: error);
    }
  }

  Future<APIResponse<T>> postAndDeserialize<T>(String url,
      Map<String, dynamic> body, T Function(dynamic json) deserialize) async {
    try {
      Options? options = _getOptionsWithAuthorization();
      Response response = await _dio.post(url, options: options, data: body);
      dynamic jsonData = response.data;
      T data = deserialize(jsonData);
      return APIResponse<T>(statusCode: response.statusCode!, body: data);
    } catch (error) {
      if (error is DioException) {
        return _fromDioException(error);
      }
      return APIResponse<T>(error: error);
    }
  }

  APIResponse<T> _fromDioException<T>(DioException de) {
    var response = de.response;
    if (response == null) {
      return APIResponse<T>(error: de);
    }
    return APIResponse<T>(
      statusCode: response.statusCode!,
      errorBody: response.data,
    );
  }

  Future<APIResponse<T>> post<T>(String url, Map<String, dynamic> body) async {
    try {
      Options? options = _getOptionsWithAuthorization();
      Response<T> response = await _dio.post(url, options: options, data: body);
      return APIResponse<T>(
          statusCode: response.statusCode!, body: response.data);
    } catch (error) {
      if (error is DioException) {
        return _fromDioException(error);
      }
      return APIResponse<T>(error: error);
    }
  }

  Future<APIResponse<T>> postMany<T>(
      String url, List<Map<String, dynamic>> body) async {
    try {
      Options? options = _getOptionsWithAuthorization();
      Response<T> response = await _dio.post(url, options: options, data: body);
      return APIResponse<T>(
          statusCode: response.statusCode!, body: response.data);
    } catch (error) {
      if (error is DioException) {
        return _fromDioException(error);
      }
      return APIResponse<T>(error: error);
    }
  }

  Future<APIResponse<List<T>>> postManyAndDeserializeMany<T>(
      String url,
      List<Map<String, dynamic>> body,
      List<T> Function(dynamic json) deserialize) async {
    try {
      Options? options = _getOptionsWithAuthorization();
      Response response = await _dio.post(url, options: options, data: body);
      List<T> deserialized = deserialize(response.data);
      return APIResponse<List<T>>(
          statusCode: response.statusCode!, body: deserialized);
    } catch (error) {
      if (error is DioException) {
        return _fromDioException(error);
      }
      return APIResponse<List<T>>(error: error);
    }
  }

  Future<APIResponse<T>> patch<T>(String url, Map<String, dynamic> body) async {
    try {
      Options? options = _getOptionsWithAuthorization();
      Response<T> response =
          await _dio.patch(url, options: options, data: body);
      return APIResponse<T>(
          statusCode: response.statusCode!, body: response.data);
    } catch (error) {
      if (error is DioException) {
        return _fromDioException(error);
      }
      return APIResponse<T>(error: error);
    }
  }

  Options? _getOptionsWithAuthorization() {
    if (tokenProvider == null) {
      return null;
    }

    String? token = tokenProvider?.getToken();

    if (token == null) {
      return null;
    }

    return Options(headers: {"Authorization": "Bearer $token"});
  }
}
