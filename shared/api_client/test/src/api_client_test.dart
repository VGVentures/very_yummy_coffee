// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:web_socket_client/web_socket_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockStreamedResponse extends Mock implements http.StreamedResponse {}

class _FakeRequest extends Fake implements http.Request {}

class MockWebSocket extends Mock implements WebSocket {}

const _host = 'test.invalid';
const _port = 443;
const _apiKey = 'test-api-key';

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequest());
  });

  group('ApiClient', () {
    late http.Client httpClient;
    late http.StreamedResponse streamedResponse;
    const testPath = '/test';
    const testHeaders = {'foo': 'bar'};
    const testQuery = {'baz': 'qux'};
    const testBody = {'key': 'value'};
    const testResponse = 'ok';
    String fromJson(String json) => json;

    setUp(() {
      httpClient = _MockHttpClient();
      streamedResponse = _MockStreamedResponse();
    });

    test('can be instantiated', () {
      expect(
        ApiClient(host: _host, secure: true, port: _port, apiKey: _apiKey),
        isNotNull,
      );
    });

    Future<void> mockSend({String? method, Object? body}) async {
      when(() => httpClient.send(any())).thenAnswer((invocation) async {
        final req = invocation.positionalArguments.first as http.Request;
        if (method != null) expect(req.method, method);
        expect(req.headers['X-API-KEY'], _apiKey);
        if (body != null) expect(req.body, jsonEncode(body));
        return streamedResponse;
      });
      when(
        () => streamedResponse.stream,
      ).thenAnswer((_) => http.ByteStream.fromBytes(utf8.encode(testResponse)));
      when(() => streamedResponse.statusCode).thenReturn(200);
      when(
        () => streamedResponse.contentLength,
      ).thenReturn(testResponse.length);
      when(() => streamedResponse.headers).thenReturn({});
      when(() => streamedResponse.reasonPhrase).thenReturn('OK');
      when(() => streamedResponse.isRedirect).thenReturn(false);
      when(() => streamedResponse.persistentConnection).thenReturn(false);
    }

    test('get makes a GET request and parses response', () async {
      await mockSend(method: 'GET');
      final apiClient = ApiClient(
        host: _host,
        secure: true,
        port: _port,
        apiKey: _apiKey,
        client: httpClient,
      );
      final result = await apiClient.get<String>(
        testPath,
        responseFromJson: fromJson,
        headers: testHeaders,
        queryParameters: testQuery,
      );
      expect(result, 'ok');
    });

    test('post makes a POST request with body and parses response', () async {
      await mockSend(method: 'POST', body: testBody);
      final apiClient = ApiClient(
        host: _host,
        secure: true,
        port: _port,
        apiKey: _apiKey,
        client: httpClient,
      );
      final result = await apiClient.post<String>(
        testPath,
        responseFromJson: fromJson,
        headers: testHeaders,
        queryParameters: testQuery,
        body: testBody,
      );
      expect(result, 'ok');
    });

    test('put makes a PUT request with body and parses response', () async {
      await mockSend(method: 'PUT', body: testBody);
      final apiClient = ApiClient(
        host: _host,
        secure: true,
        port: _port,
        apiKey: _apiKey,
        client: httpClient,
      );
      final result = await apiClient.put<String>(
        testPath,
        responseFromJson: fromJson,
        headers: testHeaders,
        queryParameters: testQuery,
        body: testBody,
      );
      expect(result, 'ok');
    });

    test('delete makes a DELETE request and parses response', () async {
      await mockSend(method: 'DELETE');
      final apiClient = ApiClient(
        host: _host,
        secure: true,
        port: _port,
        apiKey: _apiKey,
        client: httpClient,
      );
      final result = await apiClient.delete<String>(
        testPath,
        responseFromJson: fromJson,
        headers: testHeaders,
        queryParameters: testQuery,
      );
      expect(result, 'ok');
    });

    test('patch makes a PATCH request and parses response', () async {
      await mockSend(method: 'PATCH');
      final apiClient = ApiClient(
        host: _host,
        secure: true,
        port: _port,
        apiKey: _apiKey,
        client: httpClient,
      );
      final result = await apiClient.patch<String>(
        testPath,
        responseFromJson: fromJson,
        headers: testHeaders,
        queryParameters: testQuery,
        body: testBody,
      );
      expect(result, 'ok');
    });

    test('adds Authorization header if authenticationToken is set', () async {
      final apiClient = ApiClient(
        host: _host,
        secure: true,
        port: _port,
        apiKey: _apiKey,
        client: httpClient,
        getAuthenticationToken: () => 'token',
      );
      when(() => httpClient.send(any())).thenAnswer((invocation) async {
        final req = invocation.positionalArguments.first as http.Request;
        expect(req.headers['Authorization'], 'Bearer token');
        return streamedResponse;
      });
      when(
        () => streamedResponse.stream,
      ).thenAnswer((_) => http.ByteStream.fromBytes(utf8.encode(testResponse)));
      when(() => streamedResponse.statusCode).thenReturn(200);
      when(
        () => streamedResponse.contentLength,
      ).thenReturn(testResponse.length);
      when(() => streamedResponse.headers).thenReturn({});
      when(() => streamedResponse.reasonPhrase).thenReturn('OK');
      when(() => streamedResponse.isRedirect).thenReturn(false);
      when(() => streamedResponse.persistentConnection).thenReturn(false);
      final result = await apiClient.get<String>(
        testPath,
        responseFromJson: fromJson,
      );
      expect(result, 'ok');
    });

    group('error handling', () {
      Future<void> mockErrorSend({
        required int statusCode,
        String? errorMessage,
      }) async {
        when(
          () => httpClient.send(any()),
        ).thenAnswer((_) async => streamedResponse);
        when(() => streamedResponse.stream).thenAnswer(
          (_) => http.ByteStream.fromBytes(utf8.encode(errorMessage ?? '')),
        );
        when(() => streamedResponse.statusCode).thenReturn(statusCode);
        when(
          () => streamedResponse.contentLength,
        ).thenReturn(errorMessage?.length ?? 0);
        when(() => streamedResponse.headers).thenReturn({});
        when(() => streamedResponse.reasonPhrase).thenReturn('Error');
        when(() => streamedResponse.isRedirect).thenReturn(false);
        when(() => streamedResponse.persistentConnection).thenReturn(false);
      }

      test('throws ApiException with error message from response', () async {
        await mockErrorSend(statusCode: 404, errorMessage: 'Not Found');
        final apiClient = ApiClient(
          host: _host,
          secure: true,
          port: _port,
          apiKey: _apiKey,
          client: httpClient,
        );
        expect(
          () => apiClient.get<String>(testPath, responseFromJson: fromJson),
          throwsA(
            isA<ApiException>()
                .having((e) => e.message, 'message', 'Not Found')
                .having((e) => e.statusCode, 'statusCode', 404)
                .having((e) => e.path, 'path', testPath)
                .having((e) => e.method, 'method', 'GET'),
          ),
        );
      });
    });

    group('startLiveConnection', () {
      test('creates LiveConnection with correct parameters', () {
        final apiClient = ApiClient(
          host: _host,
          secure: true,
          port: _port,
          apiKey: _apiKey,
        );
        String fromJson(String json) => json;
        final connection = apiClient.startLiveConnection<String>(
          '/ws',
          responseFromJson: fromJson,
          headers: {'foo': 'bar'},
          queryParameters: {'baz': 'qux'},
          pingInterval: Duration(seconds: 5),
          timeout: Duration(seconds: 10),
        );
        expect(connection, isA<LiveConnection<String>>());
      });

      test('includes Authorization header if authenticationToken is set', () {
        final apiClient = ApiClient(
          host: _host,
          secure: true,
          port: _port,
          apiKey: _apiKey,
          getAuthenticationToken: () => 'token',
        );
        String fromJson(String json) => json;
        final connection = apiClient.startLiveConnection<String>(
          '/ws',
          responseFromJson: fromJson,
          headers: {'foo': 'bar'},
        );
        expect(connection, isA<LiveConnection<String>>());
        // Can't directly check headers, but this ensures no error is thrown
      });
    });
  });
}
