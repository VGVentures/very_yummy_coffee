import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:http/http.dart' as http;

/// A function that converts a JSON object to a value.
typedef FromJson<T> = T Function(String body);

/// {@template api_client}
/// An client for the a REST API.
/// {@endtemplate}
class ApiClient {
  /// {@macro api_client}
  ApiClient({
    required String host,
    required bool secure,
    required int? port,
    required String apiKey,
    FutureOr<String?> Function()? getAuthenticationToken,
    http.Client? client,
  }) : _host = host,
       _secure = secure,
       _port = port,
       _client = client ?? http.Client(),
       _apiKey = apiKey,
       _getAuthenticationToken = getAuthenticationToken;

  final http.Client _client;
  final String _host;
  final bool _secure;
  final int? _port;
  final String _apiKey;

  /// The authentication token for the signed in user..
  final FutureOr<String?> Function()? _getAuthenticationToken;

  /// Starts a live connection to the API.
  LiveConnection<From> startLiveConnection<From>(
    String path, {
    required FromJson<From> responseFromJson,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
    Duration? pingInterval,
    Backoff? backoff,
    Duration? timeout,
  }) {
    final authenticationToken = _getAuthenticationToken?.call();
    return LiveConnection(
      scheme: _secure ? 'wss' : 'ws',
      host: _host,
      port: _port,
      path: '/api$path',
      responseFromJson: responseFromJson,
      headers: {
        if (authenticationToken != null)
          'Authorization': 'Bearer $authenticationToken',
        ...headers,
      },
      queryParameters: queryParameters,
      pingInterval: pingInterval,
      backoff: backoff,
      timeout: timeout,
    );
  }

  /// Makes a GET request to the API.
  Future<T> get<T>(
    String path, {
    required FromJson<T> responseFromJson,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
  }) async {
    return _makeRequest<T>(
      path,
      method: 'GET',
      responseFromJson: responseFromJson,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// Makes a POST request to the API.
  Future<T> post<T>(
    String path, {
    required FromJson<T> responseFromJson,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
    Map<String, dynamic>? body,
  }) async {
    return _makeRequest<T>(
      path,
      method: 'POST',
      responseFromJson: responseFromJson,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Makes a PUT request to the API.
  Future<T> put<T>(
    String path, {
    required FromJson<T> responseFromJson,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
    Map<String, dynamic>? body,
  }) async {
    return _makeRequest<T>(
      path,
      method: 'PUT',
      responseFromJson: responseFromJson,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Makes a DELETE request to the API.
  Future<T> delete<T>(
    String path, {
    required FromJson<T> responseFromJson,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
  }) async {
    return _makeRequest<T>(
      path,
      method: 'DELETE',
      responseFromJson: responseFromJson,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// Makes a PATCH request to the API.
  Future<T> patch<T>(
    String path, {
    required FromJson<T> responseFromJson,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
    Map<String, dynamic>? body,
  }) async {
    return _makeRequest<T>(
      path,
      method: 'PATCH',
      responseFromJson: responseFromJson,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<T> _makeRequest<T>(
    String path, {
    required String method,
    required FromJson<T> responseFromJson,
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
  }) async {
    final request = http.Request(
      method,
      Uri(
        scheme: _secure ? 'https' : 'http',
        host: _host,
        port: _port,
        path: 'api$path',
        queryParameters: queryParameters,
      ),
    );
    request.headers.addAll(headers);
    request.headers['X-API-KEY'] = _apiKey;
    final authenticationToken = _getAuthenticationToken?.call();
    if (authenticationToken != null) {
      request.headers['Authorization'] = 'Bearer $authenticationToken';
    }
    if (body != null) {
      request.body = jsonEncode(body);
    }
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode >= 400) {
      throw ApiException(
        message: response.body,
        path: path,
        method: method,
        statusCode: response.statusCode,
      );
    }
    return responseFromJson(response.body);
  }
}
